import 'package:convertify/core/constant/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// One banner ad. Register it with a tag per screen, e.g.
/// `Get.put(BannerAdController("HOME_AD_BANNER_ID"), tag: "home")`.
class BannerAdController extends GetxController {
  BannerAdController(this._envKey);

  static const _testAdUnitId = "ca-app-pub-3940256099942544/9214589741";
  final String _envKey;

  BannerAd? bannerAd;
  final RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    final adUnitId =
        AppConfig.isTestAd ? _testAdUnitId : dotenv.env[_envKey];
    if (adUnitId == null || adUnitId.isEmpty) return;
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => isLoaded.value = true,
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }
}
