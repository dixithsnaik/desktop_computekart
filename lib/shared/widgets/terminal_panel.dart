import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/terminal_service.dart';
import '../../core/theme/app_colors.dart';
import 'terminal/terminal_header.dart';
import 'terminal/terminal_session_view.dart';

/// VS Code–style integrated terminal panel (xterm + PTY).
class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  double _fontSize = 13.0;
  String _newSessionShell = '';

  @override
  void initState() {
    super.initState();
    final svc = Get.find<TerminalService>();
    _newSessionShell = svc.defaultShell;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (svc.sessions.isEmpty) {
        svc.createSession(shell: _newSessionShell);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<TerminalService>();
    final palette = AppPalette(
      isDark: Theme.of(context).brightness == Brightness.dark,
    );

    return ColoredBox(
      color: palette.bgSurface,
      child: Column(
        children: [
          TerminalHeader(
            fontSize: _fontSize,
            onFontSizeChanged: (v) => setState(() => _fontSize = v),
            onShellChanged: (shell) => _newSessionShell = shell,
            onNewTerminal: () {
              final session = svc.createSession(shell: _newSessionShell);
              svc.setActiveSession(session.id);
            },
            onKillTerminal: () => svc.killActiveSession(),
            onRestartTerminal: () => svc.restartActiveSession(),
            onClearTerminal: () => svc.getActiveSession()?.clearScreen(),
          ),
          Expanded(
            child: Obx(() {
              if (svc.sessions.isEmpty) {
                return Center(
                  child: Text(
                    'No terminal sessions',
                    style: TextStyle(color: palette.textMuted),
                  ),
                );
              }

              final session = svc.getActiveSession();
              if (session == null) {
                return const SizedBox.shrink();
              }

              return TerminalSessionView(
                key: ValueKey('${session.id}-$_fontSize'),
                session: session,
                fontSize: _fontSize,
              );
            }),
          ),
          _StatusBar(svc: svc, palette: palette),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.svc, required this.palette});

  final TerminalService svc;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: palette.bgSurfaceMuted,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Obx(() {
        final session = svc.getActiveSession();
        if (session == null) return const SizedBox.shrink();

        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: session.isRunning.value ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              session.status.value,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            if (session.pid != null)
              Text(
                'PID: ${session.pid}',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        );
      }),
    );
  }
}
