import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyFilesBannerAdController extends GetxController {
  BannerAd? myFilesBannerAd;
  RxBool isMyFilesAdBannerLoaded = false.obs;
  final bool _isTest = true;
  final String _testAdBannerId = "ca-app-pub-3940256099942544/9214589741";
  final String? _myFilesAdBannerId = dotenv.env["MY_FILES_AD_BANNER_ID"];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadMyFilesBanner();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (isMyFilesAdBannerLoaded.value) {
      myFilesBannerAd!.dispose();
    }
  }
  String _getMyFilesBanner() {
    return _isTest ? _testAdBannerId : _myFilesAdBannerId!;
  }

  void loadMyFilesBanner() {
    myFilesBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _getMyFilesBanner(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isMyFilesAdBannerLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest())
      ..load();
  }
}
