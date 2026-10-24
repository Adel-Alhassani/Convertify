import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/view/screen/convert_screen.dart';
import 'package:convertify/view/screen/files_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom navigation with labelled tabs. Replaces persistent_bottom_nav_bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    return PopScope(
      // Back on the Files tab returns to Convert instead of closing the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            ConvertScreen(onOpenFiles: () => _go(1)),
            FilesScreen(onOpenConvert: () => _go(0)),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final busy = convert.isBusy;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _go,
            destinations: [
              NavigationDestination(
                key: const Key("tab_convert"),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: "tab_convert".tr,
              ),
              NavigationDestination(
                key: const Key("tab_files"),
                // A dot while something is converting, so users know where
                // to look if they leave the convert tab.
                icon: Badge(
                  isLabelVisible: busy,
                  smallSize: 9,
                  child: const Icon(Icons.folder_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: busy,
                  smallSize: 9,
                  child: const Icon(Icons.folder_rounded),
                ),
                label: "tab_files".tr,
              ),
            ],
          );
        }),
      ),
    );
  }
}
