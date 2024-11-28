import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  BannerAd? bannerAd;
  RxBool isHomeBannerLoaded = false.obs;
  final bool _isTest = true;
  final String _testAdHomeBannerId = "ca-app-pub-3940256099942544/9214589741";
  final String? _appAdHomeBannerId = dotenv.env["HOME_BANNER_ID"];

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
    if (isHomeBannerLoaded.value) {
      bannerAd!.dispose();
    }
  }

  String _getHomeBanner() {
    return _isTest ? _testAdHomeBannerId : _appAdHomeBannerId!;
  }

  void loadHomeBanner() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _getHomeBanner(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isHomeBannerLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest())
      ..load();
  }
}
