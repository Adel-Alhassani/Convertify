import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeBannerAdController extends GetxController{
    BannerAd? homeBannerAd;
    RxBool isHomeAdBannerLoaded = false.obs;
    final bool _isTest = true;
  final String _testAdBannerId = "ca-app-pub-3940256099942544/9214589741";
  final String? _homeAdBannerId = dotenv.env["HOME_AD_BANNER_ID"];

  
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
    if (isHomeAdBannerLoaded.value) {
      homeBannerAd!.dispose();
    }
  }
   String _getHomeBannerAdId() {
    return _isTest ? _testAdBannerId : _homeAdBannerId!;
  }

  void loadHomeBanner() {
    homeBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _getHomeBannerAdId(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isHomeAdBannerLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest())
      ..load();
  }

}