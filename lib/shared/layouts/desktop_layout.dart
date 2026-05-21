import 'package:flutter/material.dart';

import '../sidebar/app_sidebar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/wsl_execution_service.dart';
import 'package:get/get.dart';
import '../widgets/downloads_panel.dart';

/// The main desktop shell — sidebar + content area.
/// Replaces React's PageWrapper (Navbar + content + Footer).
class DesktopLayout extends StatelessWidget {
  final Widget child;
  const DesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDark: isDark);

    return Scaffold(
      backgroundColor: palette.bgWrapper,
      body: Stack(
        children: [
          Row(
            children: [
              const AppSidebar(),
              Expanded(child: child),
            ],
          ),
          Obx(() {
            final dm = Get.find<WslExecutionService>();

            if (dm.isPanelOpen.value) {
              return const Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: DownloadsPanel(),
              );
            }

            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
