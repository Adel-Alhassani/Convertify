# Convertify

Android app for converting documents, images, audio and video files, built with Flutter and the [CloudConvert](https://cloudconvert.com) API. English and Arabic (RTL), light and dark mode.

## Setup

1. Create `.env` in the project root:

   ```
   API_KEY=<your CloudConvert API key>
   # Only needed when AppConfig.isAdDisabled is false:
   HOME_AD_BANNER_ID=
   MY_FILES_AD_BANNER_ID=
   HOME_AD_REWARDED_ID=
   ```

2. `flutter pub get`
3. `flutter run`

> **Security:** `.env` is bundled into the APK, so anyone can extract the API key. Before publishing, move job creation behind your own backend (a small Cloud Function or Worker) and point `FileService` at it.

## How it's organised

```
lib/
  main.dart                    DI setup and GetMaterialApp
  controller/
    convert_controller.dart    convert flow state machine (idle → ready → uploading → converting → done | failed)
    files_controller.dart      converted files: list, search, expiry, save / share / open
    config_controller.dart     language
  service/file_service.dart    CloudConvert client (Dio)
  data/preferences_helper.dart SharedPreferences persistence
  core/
    theme/                     design tokens (AppColors) and Material 3 theme
    constant/format_info.dart  badge colours, suggestions, format descriptions
    localization/              en + ar strings
  view/
    app_shell.dart             bottom navigation
    screen/                    Convert and Files tabs
    widget/                    convert flow views, file tiles, shared widgets
```

Controllers take their dependencies through constructors, so tests can pass fakes:

```dart
final files = FilesController(prefs: PreferencesHelper(fakePrefs), service: fakeService);
final convert = ConvertController(prefs: prefs, files: files, service: fakeService);
```

## Testing

- `flutter test` runs the unit tests in `test/`.
- Key widgets have stable `Key`s for integration or Appium tests: `browse_files_button`, `choose_format_button`, `format_<ext>`, `convert_button`, `cancel_conversion_button`, `save_to_device_button`, `try_again_button`, `convert_another_button`, `tab_convert`, `tab_files`.
