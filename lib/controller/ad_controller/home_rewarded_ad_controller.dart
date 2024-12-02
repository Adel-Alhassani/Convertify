import 'package:convertify/core/constant/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeRewardedAdController extends GetxController {
  RewardedAd? homeRewardedAd;
  RxBool isHomeRewardedAd = false.obs;
  final String _testRewardedAdId = "ca-app-pub-3940256099942544/1033173712";
  final String? _homeRewardedAdId = dotenv.env["HOME_AD_REWARDED_ID"];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadRewardedAd();
  }

  String _getHomeRewardedAdId() {
    return AppConfig.isTestAd ? _testRewardedAdId : _homeRewardedAdId!;
  }

  void _loadRewardedAd() {
    RewardedAd.load(
        adUnitId: _getHomeRewardedAdId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => homeRewardedAd = ad,
            onAdFailedToLoad: (error) => homeRewardedAd = null));
  }

  Future<void> showRewardedAd(
      {required void Function(AdWithoutView, RewardItem)
          onUserEarnedReward}) async {
    if (homeRewardedAd != null) {
      homeRewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      // homeRewardedAd!.setImmersiveMode(true);
      await homeRewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
      homeRewardedAd = null;
    }
  }
}
