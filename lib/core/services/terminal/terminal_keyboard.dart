import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';

/// Desktop keyboard helper — forwards printable keys directly to the PTY.
class TerminalKeyboard {
  TerminalKeyboard._();

  /// Send plain typing characters straight to the shell (bypasses keytab quirks).
  static KeyEventResult forwardPrintable({
    required FocusNode node,
    required KeyEvent event,
    required Terminal terminal,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final hw = HardwareKeyboard.instance;
    if (hw.isControlPressed || hw.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final char = event.character;
    if (char == null || char.isEmpty) return KeyEventResult.ignored;
    if (char == '\n' || char == '\r') return KeyEventResult.ignored;

    if (char.length == 1) {
      final code = char.codeUnitAt(0);
      if (code >= 32 && code != 127) {
        terminal.textInput(char);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
