package com.devadel.convertify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Home-screen widget: "Convert a file" plus quick conversions. Each tap opens
 * the app with the file picker; MainActivity hands the tap to Dart
 * (lib/service/widget_launches.dart).
 */
class ConvertWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = RemoteViews(context.packageName, R.layout.widget_convert).apply {
            setOnClickPendingIntent(R.id.widget_convert_button, launch(context, 0, null, null))
            QUICK.forEachIndexed { i, (viewId, from, to) ->
                setOnClickPendingIntent(viewId, launch(context, i + 1, from, to))
            }
        }
        for (id in ids) manager.updateAppWidget(id, views)
    }

    companion object {
        const val ACTION_CONVERT = "com.devadel.convertify.action.CONVERT"
        const val EXTRA_FROM = "from"
        const val EXTRA_TO = "to"

        // Same pairs as the first chips in FormatInfo.popularConversions.
        private val QUICK = listOf(
            Triple(R.id.widget_quick_1, "docx", "pdf"),
            Triple(R.id.widget_quick_2, "heic", "jpg"),
            Triple(R.id.widget_quick_3, "mp4", "mp3"),
        )

        private fun launch(context: Context, requestCode: Int, from: String?, to: String?): PendingIntent {
            val intent = Intent(context, MainActivity::class.java)
                .setAction(ACTION_CONVERT)
                .putExtra(EXTRA_FROM, from)
                .putExtra(EXTRA_TO, to)
                // Reuse the running app instead of stacking a second one.
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            return PendingIntent.getActivity(
                context, requestCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
