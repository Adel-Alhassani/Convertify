class AppConfig {
  static const int fileSizeLimitInMB = 30;

  /// CloudConvert deletes a result after this, so it has to be copied into
  /// the user's folder before then.
  static const Duration downloadLinkLifetime = Duration(hours: 24);

  static const bool isAdDisabled = true;
  static const bool isTestAd = false;
}
