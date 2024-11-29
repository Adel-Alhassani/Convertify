import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  BannerAd? bannerAd;
  RxBool isAdBannerLoaded = false.obs;
  final bool _isTest = true;
  final String _testAdBannerId = "ca-app-pub-3940256099942544/9214589741";
  final String? _appAdBannerId = dotenv.env["AD_BANNER_ID"];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadHomeBanner();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (isAdBannerLoaded.value) {
      bannerAd!.dispose();
    }
  }

  String _getHomeBanner() {
    return _isTest ? _testAdBannerId : _appAdBannerId!;
  }

  void loadHomeBanner() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _getHomeBanner(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isAdBannerLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest())
      ..load();
  }
}
