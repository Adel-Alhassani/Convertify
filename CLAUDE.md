# Convertify

Flutter app (Android first) that converts documents, images, audio and video through the CloudConvert v2 API. English and Arabic (RTL), light and dark themes. State management: GetX.

## Commands

- `flutter pub get`
- `flutter analyze` — must be clean before finishing a change
- `flutter test` — unit tests in `test/`
- `flutter run` — runs on the Android emulator or a USB device

## Architecture

- `lib/main.dart` — `initServices()` registers everything with constructor injection; `MyApp` rebuilds `GetMaterialApp` when the language changes.
- `lib/controller/convert_controller.dart` — the convert flow as a state machine: `ConvertStage { idle, ready, uploading, converting, done, failed }`. Uses a `_run` counter so a cancelled or superseded run can't overwrite newer state. Persists the in-progress job so it resumes after the app is killed.
- `lib/controller/files_controller.dart` — converted files, kept with no time limit and no count limit in a folder the user picks once (normally `Download/Convertify`). The list is read from that folder (reloaded on app resume and pull-to-refresh), plus "pending" results not copied in yet, which are stored in prefs. CloudConvert deletes results after 24 h (`AppConfig.downloadLinkLifetime`), so new results are copied into the folder right after conversion.
- `lib/service/folder_storage.dart` + `android/.../MainActivity.kt` — method channel `convertify/storage` over the Storage Access Framework (folder picker with a persisted tree URI; list / write / delete / open / share). After a reinstall access is lost; picking the same folder again brings the files back.
- Home-screen widget — `android/.../ConvertWidgetProvider.kt` + `res/layout/widget_convert.xml` ("Convert a file" and three quick conversions). Taps reach Dart on channel `convertify/widget` (`lib/service/widget_launches.dart`); `AppShell` switches to Convert and calls `HomeView.pick`. The quick pairs are duplicated from `FormatInfo.popularConversions`, and the widget's strings live in `res/values*/strings.xml`.
- `lib/service/file_service.dart` — CloudConvert client on Dio. Tasks are named `import-file`, `convert-file`, `export-file`. `waitForExport` polls with a timeout and throws on job `error`. All `DioException`s map to app exceptions in `_rethrow`.
- `lib/data/preferences_helper.dart` — SharedPreferences. JSON keys are kept compatible with v1.0 data.
- `lib/core/theme/` — `AppColors` (ThemeExtension, read via `context.colors`) and `AppTheme` (Material 3). Arabic uses the Zain font with a 1.18× type scale.
- `lib/core/constant/format_info.dart` — badge colours, suggested target formats, format descriptions.
- `lib/core/localization/app_locale.dart` — `en` and `ar` strings. Every user-facing string goes through `.tr` / `.trParams`. Don't give a param a name that starts with another param's name (`@n` and `@name` collide).
- `lib/view/` — `app_shell.dart` (NavigationBar), `screen/` (Convert, Files), `widget/convert/` (one view per stage), `widget/files/`, `widget/common/`.

## Conventions

- Errors inside the convert flow are shown inline (`ErrorView`); outside it, `ExceptionsHandler.handle` shows a dialog. User cancels and cancelled picks are silent.
- Converted files go through `FolderStorage` (Storage Access Framework). No storage permissions in the manifest; don't add them back.
- Open the format sheet with `FormatPickerSheet.show()` (no context): the calling view may already be replaced when formats finish loading.
- Key widgets have stable `Key`s for integration/Appium tests (`browse_files_button`, `convert_button`, `format_<ext>`, `open_file_button`, `share_file_button`, `save_to_folder_button`, `choose_folder_button`, …). Keep them when editing.
- Theme button `minimumSize` uses `Size.fromHeight` (full width). Inside a `Row`, wrap buttons in `Expanded` or override `minimumSize`.

## Android build setup

Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20, Java 17, NDK 27.0.12077973 (`ndkVersion` set explicitly in `android/app/build.gradle`). Flutter warns these will soon be unsupported; moving to AGP 9 / Gradle 9 is a separate, planned step (AGP 9 changes the DSL and may need package upgrades, e.g. `file_picker`).

## Known open items

- The CloudConvert API key ships in the APK via `.env` (bundled as an asset). Must move job creation behind a backend before publishing. Never read or print `.env`.
- Release builds are signed with the debug key.
- Old `withOpacity` calls produce deprecation infos on recent Flutter; fine to migrate to `withValues(alpha:)`.
