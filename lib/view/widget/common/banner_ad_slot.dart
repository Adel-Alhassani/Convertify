import 'package:convertify/controller/ad_controller/banner_ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reserves no space until the banner has loaded.
class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key, required this.controller});

  final BannerAdController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ad = controller.bannerAd;
      if (!controller.isLoaded.value || ad == null) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    });
  }
}
