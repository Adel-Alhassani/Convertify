import 'package:convertify/controller/ad_controller/banner_ad_controller.dart';
import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/view/widget/common/banner_ad_slot.dart';
import 'package:convertify/view/widget/convert/done_view.dart';
import 'package:convertify/view/widget/convert/error_view.dart';
import 'package:convertify/view/widget/convert/home_view.dart';
import 'package:convertify/view/widget/convert/progress_view.dart';
import 'package:convertify/view/widget/convert/ready_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The Convert tab: one view per stage of the flow.
class ConvertScreen extends StatelessWidget {
  const ConvertScreen({super.key, required this.onOpenFiles});

  final VoidCallback onOpenFiles;

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final stage = convert.stage.value;
                final Widget child = switch (stage) {
                  ConvertStage.idle => HomeView(onOpenFiles: onOpenFiles),
                  ConvertStage.ready => const ReadyView(),
                  ConvertStage.uploading ||
                  ConvertStage.converting =>
                    const ProgressView(),
                  ConvertStage.done => const DoneView(),
                  ConvertStage.failed => const ErrorView(),
                };
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  child: KeyedSubtree(
                    // Uploading -> converting keeps the same view.
                    key: ValueKey(stage == ConvertStage.uploading
                        ? ConvertStage.converting
                        : stage),
                    child: child,
                  ),
                );
              }),
            ),
            if (Get.isRegistered<BannerAdController>(tag: "home"))
              BannerAdSlot(controller: Get.find<BannerAdController>(tag: "home")),
          ],
        ),
      ),
    );
  }
}
