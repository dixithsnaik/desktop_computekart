import 'package:flutter/material.dart';

import '../sidebar/app_sidebar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/wsl_execution_service.dart';
import 'package:get/get.dart';
import '../widgets/downloads_panel.dart';
import '../widgets/terminal_panel.dart';
import '../../core/services/terminal_service.dart';

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
          Obx(() {
            final ts = Get.find<TerminalService>();
            return Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: ts.isPanelOpen.value ? const TerminalPanel() : child,
                ),
              ],
            );
          }),
          Obx(() {
            final dm = Get.find<WslExecutionService>();
            final ts = Get.find<TerminalService>();

            const terminalHeight = 260.0;

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
