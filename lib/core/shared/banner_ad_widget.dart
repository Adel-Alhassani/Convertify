import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Widget bannerAdWidget(BannerAd bannerAd) {
  return StatefulBuilder(
    builder: (context, setState) => Container(
      width: bannerAd.size.width.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: bannerAd),
    ),
  );
}
