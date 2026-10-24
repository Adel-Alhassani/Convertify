import 'package:convertify/core/constant/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeRewardedAdController extends GetxController {
  static const _testRewardedAdId = "ca-app-pub-3940256099942544/1033173712";
  RewardedAd? _ad;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    _ad?.dispose();
    super.onClose();
  }

  void _load() {
    final adUnitId = AppConfig.isTestAd
        ? _testRewardedAdId
        : dotenv.env["HOME_AD_REWARDED_ID"];
    if (adUnitId == null || adUnitId.isEmpty) return;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  /// Shows the ad and runs [onReward] once the user earns it. If no ad is
  /// loaded, runs [onReward] straight away so the user is never blocked.
  Future<void> showThen(Future<void> Function() onReward) async {
    final ad = _ad;
    if (ad == null) {
      await onReward();
      return;
    }
    _ad = null;
    var rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
        if (rewarded) onReward();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _load();
        onReward();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => rewarded = true);
  }
}
