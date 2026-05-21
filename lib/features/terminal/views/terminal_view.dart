import 'package:flutter/material.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/terminal_panel.dart';

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopLayout(child: TerminalPanel());
  }
}
