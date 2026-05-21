import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/terminal/shell_config.dart';
import '../../../core/services/terminal/terminal_session.dart';
import '../../../core/services/terminal_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TerminalHeader extends StatefulWidget {
  const TerminalHeader({
    super.key,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.onShellChanged,
    required this.onNewTerminal,
    required this.onKillTerminal,
    required this.onRestartTerminal,
    required this.onClearTerminal,
  });

  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onShellChanged;
  final VoidCallback onNewTerminal;
  final VoidCallback onKillTerminal;
  final VoidCallback onRestartTerminal;
  final VoidCallback onClearTerminal;

  @override
  State<TerminalHeader> createState() => _TerminalHeaderState();
}

class _TerminalHeaderState extends State<TerminalHeader> {
  late String _selectedShell;

  @override
  void initState() {
    super.initState();
    _selectedShell = Get.find<TerminalService>().defaultShell;
  }

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<TerminalService>();
    final palette = AppPalette(
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
    final shells = ShellResolver.availableOnPlatform();
    final shellIds = shells.map((s) => s.id).toList();
    if (!shellIds.contains(_selectedShell)) {
      _selectedShell = shellIds.first;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.bgSurfaceMuted,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: svc.sessions.map((session) {
                    final isActive =
                        session.id == svc.activeSessionId.value;
                    return _TabChip(
                      session: session,
                      isActive: isActive,
                      palette: palette,
                      onSelect: () => svc.setActiveSession(session.id),
                      onClose: () => svc.closeSession(session.id),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 28,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedShell,
                isDense: true,
                dropdownColor: palette.bgSurface,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                items: shells
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedShell = v);
                  widget.onShellChanged(v);
                },
              ),
            ),
          ),
          _ToolbarIcon(
            tooltip: 'New Terminal',
            icon: Icons.add,
            color: palette.textMuted,
            onPressed: widget.onNewTerminal,
          ),
          _ToolbarIcon(
            tooltip: 'Split Terminal (coming soon)',
            icon: Icons.splitscreen,
            color: palette.textMuted.withValues(alpha: 0.4),
            onPressed: () {},
          ),
          _ToolbarIcon(
            tooltip: 'Kill Terminal',
            icon: Icons.stop_circle_outlined,
            color: palette.textMuted,
            onPressed: widget.onKillTerminal,
          ),
          _ToolbarIcon(
            tooltip: 'Restart Terminal',
            icon: Icons.refresh,
            color: palette.textMuted,
            onPressed: widget.onRestartTerminal,
          ),
          _ToolbarIcon(
            tooltip: 'Clear',
            icon: Icons.clear_all,
            color: palette.textMuted,
            onPressed: widget.onClearTerminal,
          ),
          _ToolbarIcon(
            tooltip: 'Decrease font size',
            icon: Icons.remove,
            color: palette.textMuted,
            onPressed: () {
              final next = (widget.fontSize - 1).clamp(8.0, 32.0);
              widget.onFontSizeChanged(next);
            },
          ),
          Text(
            widget.fontSize.toInt().toString(),
            style: AppTextStyles.body(palette.textMuted).copyWith(fontSize: 11),
          ),
          _ToolbarIcon(
            tooltip: 'Increase font size',
            icon: Icons.add,
            color: palette.textMuted,
            onPressed: () {
              final next = (widget.fontSize + 1).clamp(8.0, 32.0);
              widget.onFontSizeChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.session,
    required this.isActive,
    required this.palette,
    required this.onSelect,
    required this.onClose,
  });

  final TerminalSession session;
  final bool isActive;
  final AppPalette palette;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Material(
        color: isActive ? palette.bgSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final running = session.isRunning.value;
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: running ? Colors.green : Colors.red,
                    ),
                  );
                }),
                Obx(
                  () => Text(
                    session.title.value,
                    style: TextStyle(
                      color: isActive
                          ? palette.textPrimary
                          : palette.textMuted,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18, color: color),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }
}
