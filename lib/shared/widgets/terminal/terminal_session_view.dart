import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';

import '../../../core/services/terminal/app_terminal_theme.dart';
import '../../../core/services/terminal/terminal_keyboard.dart';
import '../../../core/services/terminal/terminal_session.dart';

/// Renders one [TerminalSession] with xterm (inline typing, no external input).
class TerminalSessionView extends StatefulWidget {
  const TerminalSessionView({
    super.key,
    required this.session,
    required this.fontSize,
  });

  final TerminalSession session;
  final double fontSize;

  @override
  State<TerminalSessionView> createState() => _TerminalSessionViewState();
}

class _TerminalSessionViewState extends State<TerminalSessionView> {
  @override
  void initState() {
    super.initState();
    // FIX: Defer the shell launch completely out of the frame setup lifecycle loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchShell();
    });
  }

  Future<void> _launchShell() async {
    if (!mounted) return;

    // Fire initialization once safely
    await widget.session.ensureStarted();

    // Poll safely for the PID if it takes a moment to spawn across the PTY layer
    for (var attempt = 0; attempt < 30 && mounted; attempt++) {
      if (widget.session.pid != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (mounted) {
      widget.session.focusTerminal();
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    return TerminalKeyboard.forwardPrintable(
      node: node,
      event: event,
      terminal: widget.session.terminal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final textStyle = TerminalStyle(
      fontSize: widget.fontSize,
      height: 1.2,
      fontFamily: 'Cascadia Mono',
      fontFamilyFallback: const [
        'Cascadia Code',
        'Consolas',
        'Menlo',
        'Monaco',
        'Courier New',
        'monospace',
      ],
    );

    // FIX: Removed the unsafe continuous execution checks inside LayoutBuilder.
    // The xterm widget handles its own resizing layout updates natively via 'autoResize: true'.
    return Shortcuts(
      shortcuts: defaultTerminalShortcuts,
      child: TerminalView(
        key: session.viewKey,
        session.terminal,
        controller: session.controller,
        focusNode: session.focusNode,
        theme: Theme.of(context).brightness == Brightness.dark
            ? AppTerminalTheme.dark
            : AppTerminalTheme.light,
        textStyle: textStyle,
        autofocus: false,
        autoResize: true,
        hardwareKeyboardOnly: false,
        deleteDetection: true,
        onKeyEvent: _onKeyEvent,
        onSecondaryTapDown: _onSecondaryTapDown,
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Future<void> _onSecondaryTapDown(
    TapDownDetails details,
    CellOffset offset,
  ) async {
    final session = widget.session;
    final controller = session.controller;
    final selection = controller.selection;

    if (selection != null) {
      final text = session.terminal.buffer.getText(selection);
      controller.clearSelection();
      await Clipboard.setData(ClipboardData(text: text));
      session.focusTerminal();
      return;
    }

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      session.terminal.paste(text);
      session.focusTerminal();
    }
  }
}
