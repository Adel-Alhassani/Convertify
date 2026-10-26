package com.devadel.convertify

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.FutureTask

/**
 * Converted files live in a folder the user picks once with the system folder
 * picker (Storage Access Framework). They show up in file managers, survive a
 * reinstall, and no storage permission is needed. Dart side:
 * lib/service/folder_storage.dart.
 */
class MainActivity : FlutterActivity() {
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingPick: MethodChannel.Result? = null

    private var widgetChannel: MethodChannel? = null
    /** The widget tap that started the app, until Dart asks for it. */
    private var pendingLaunch: Map<String, String?>? = null
    private var restored = false

    override fun onCreate(savedInstanceState: Bundle?) {
        // A recreated activity still carries the original widget intent.
        restored = savedInstanceState != null
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(::onCall)

        if (!restored) pendingLaunch = takeWidgetLaunch(intent)
        widgetChannel = MethodChannel(messenger, WIDGET_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "takeLaunch") {
                    result.success(pendingLaunch)
                    pendingLaunch = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    /** A widget tap while the app is already running. */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val launch = takeWidgetLaunch(intent) ?: return
        widgetChannel?.invokeMethod("launch", launch) ?: run { pendingLaunch = launch }
    }

    private fun takeWidgetLaunch(intent: Intent?): Map<String, String?>? {
        if (intent?.action != ConvertWidgetProvider.ACTION_CONVERT) return null
        // Reopened from recents: the tap was already handled.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        intent.action = Intent.ACTION_MAIN
        return mapOf(
            "from" to intent.getStringExtra(ConvertWidgetProvider.EXTRA_FROM),
            "to" to intent.getStringExtra(ConvertWidgetProvider.EXTRA_TO),
        )
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickFolder" -> pickFolder(result)
            "hasAccess" -> background(result) { hasAccess(call.uri("treeUri")) }
            "list" -> background(result) {
                try {
                    list(call.uri("treeUri"))
                } catch (e: Exception) {
                    throw FolderUnavailable(e)
                }
            }
            "write" -> background(result) {
                write(call.uri("treeUri"), call.arg("name"), call.arg("sourcePath"))
            }
            "delete" -> background(result) { delete(call.uri("uri")) }
            "open" -> background(result) {
                val uri = call.uri("uri")
                if (!exists(uri)) return@background "missing"
                val intent = Intent(Intent.ACTION_VIEW)
                    .setDataAndType(uri, mimeOf(call.arg("name")))
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                onMain {
                    try {
                        startActivity(intent)
                        "done"
                    } catch (e: ActivityNotFoundException) {
                        "no_app"
                    }
                }
            }
            "share" -> background(result) {
                val uri = call.uri("uri")
                val name: String = call.arg("name")
                if (!exists(uri)) throw FileNotFoundException(uri.toString())
                val send = Intent(Intent.ACTION_SEND)
                    .setType(mimeOf(name))
                    .putExtra(Intent.EXTRA_STREAM, uri)
                    .putExtra(Intent.EXTRA_SUBJECT, name)
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                send.clipData = ClipData.newRawUri(name, uri)
                onMain { startActivity(Intent.createChooser(send, null)) }
                null
            }
            else -> result.notImplemented()
        }
    }

    // ---- picking ----

    private fun pickFolder(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "The folder picker is already open", null)
            return
        }
        pendingPick = result
        io.execute {
            createDefaultFolder()
            main.post {
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    // Opens on Download/Convertify; falls back to the picker's
                    // default location when the folder doesn't exist.
                    intent.putExtra(
                        DocumentsContract.EXTRA_INITIAL_URI,
                        DocumentsContract.buildDocumentUri(
                            EXTERNAL_STORAGE_AUTHORITY,
                            "primary:${Environment.DIRECTORY_DOWNLOADS}/$FOLDER_NAME"
                        )
                    )
                }
                try {
                    startActivityForResult(intent, PICK_FOLDER_REQUEST)
                } catch (e: ActivityNotFoundException) {
                    pendingPick = null
                    result.error("no_picker", e.message, null)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != PICK_FOLDER_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingPick ?: return
        pendingPick = null
        val tree = data?.data
        if (resultCode != RESULT_OK || tree == null) {
            result.success(null) // user backed out
            return
        }
        try {
            contentResolver.takePersistableUriPermission(
                tree,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            result.success(tree.toString())
        } catch (e: SecurityException) {
            result.error("folder_unavailable", e.message, null)
        }
    }

    /**
     * Creates Download/Convertify so the picker can open right on it. Android
     * 10+ lets an app add files to Downloads through MediaStore without a
     * permission; adding and removing a placeholder leaves the folder behind.
     * Older versions can't do this, and the user creates it in the picker.
     */
    private fun createDefaultFolder() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        try {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, "convertify-setup")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/$FOLDER_NAME"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?.let { contentResolver.delete(it, null, null) }
        } catch (e: Exception) {
            // Not fatal: the user can still pick or create a folder.
        }
    }

    // ---- folder contents ----

    private fun hasAccess(tree: Uri): Boolean {
        val granted = contentResolver.persistedUriPermissions.any {
            it.uri == tree && it.isReadPermission && it.isWritePermission
        }
        return granted && exists(folderDocument(tree))
    }

    private fun list(tree: Uri): List<Map<String, Any?>> {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree)
        )
        val files = mutableListOf<Map<String, Any?>>()
        val cursor = contentResolver.query(children, COLUMNS, null, null, null)
            ?: throw IllegalStateException("Folder can't be read")
        cursor.use {
            while (it.moveToNext()) {
                val name = it.getString(1) ?: continue
                if (it.getString(4) == Document.MIME_TYPE_DIR || name.startsWith(".")) continue
                files += describe(
                    DocumentsContract.buildDocumentUriUsingTree(tree, it.getString(0)),
                    it
                )
            }
        }
        return files
    }

    private fun write(tree: Uri, name: String, sourcePath: String): Map<String, Any?> {
        val doc = try {
            DocumentsContract.createDocument(
                contentResolver, folderDocument(tree), mimeOf(name), name
            )
        } catch (e: Exception) {
            throw FolderUnavailable(e)
        } ?: throw FolderUnavailable(null)
        try {
            val out = contentResolver.openOutputStream(doc, "w")
                ?: throw IllegalStateException("Can't write $doc")
            out.use { File(sourcePath).inputStream().use { input -> input.copyTo(it) } }
        } catch (e: Exception) {
            runCatching { DocumentsContract.deleteDocument(contentResolver, doc) }
            throw e
        }
        // The provider may have renamed it, e.g. "report (1).pdf".
        val cursor = contentResolver.query(doc, COLUMNS, null, null, null)
            ?: throw IllegalStateException("Can't read $doc")
        return cursor.use {
            it.moveToFirst()
            describe(doc, it)
        }
    }

    /** True when the file is gone, whether deleted here or already removed. */
    private fun delete(uri: Uri): Boolean {
        if (!exists(uri)) return true
        return DocumentsContract.deleteDocument(contentResolver, uri)
    }

    private fun exists(uri: Uri): Boolean = try {
        contentResolver.query(uri, arrayOf(Document.COLUMN_DOCUMENT_ID), null, null, null)
            ?.use { it.moveToFirst() } ?: false
    } catch (e: Exception) {
        false
    }

    private fun folderDocument(tree: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))

    private fun describe(uri: Uri, row: android.database.Cursor): Map<String, Any?> = mapOf(
        "uri" to uri.toString(),
        "name" to row.getString(1),
        "size" to if (row.isNull(2)) null else row.getLong(2),
        "modified" to if (row.isNull(3)) null else row.getLong(3),
    )

    private fun mimeOf(name: String): String {
        val ext = name.substringAfterLast('.', "").lowercase()
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext)
            ?: "application/octet-stream"
    }

    // ---- plumbing ----

    /** Runs [work] off the main thread and replies on it. */
    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        io.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: Exception) {
                val code = when (e) {
                    is FolderUnavailable, is SecurityException -> "folder_unavailable"
                    is FileNotFoundException -> "missing"
                    else -> "io"
                }
                main.post { result.error(code, (e.cause ?: e).message, null) }
            }
        }
    }

    /** Runs [work] on the main thread from a background one and waits. */
    private fun <T> onMain(work: () -> T): T {
        val task = FutureTask<T> { work() }
        main.post(task)
        return try {
            task.get()
        } catch (e: ExecutionException) {
            throw e.cause ?: e
        }
    }

    private fun MethodCall.uri(key: String): Uri = Uri.parse(arg(key))

    private fun <T> MethodCall.arg(key: String): T =
        argument<T>(key) ?: throw IllegalArgumentException("Missing argument $key")

    private class FolderUnavailable(cause: Throwable?) : Exception(cause)

    companion object {
        private const val CHANNEL = "convertify/storage"
        private const val WIDGET_CHANNEL = "convertify/widget"
        private const val PICK_FOLDER_REQUEST = 4101
        private const val FOLDER_NAME = "Convertify"
        private const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"

        private val COLUMNS = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_SIZE,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_MIME_TYPE,
        )
    }
}
