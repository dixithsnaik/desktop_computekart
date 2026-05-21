import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart';

import 'shell_config.dart';

/// A single integrated terminal: xterm emulator + PTY process.
class TerminalSession {
  TerminalSession({
    required this.id,
    required String initialTitle,
    required this.shell,
    this.onOutput,
    this.onExit,
    int maxScrollbackLines = 10000,
  }) : title = initialTitle.obs,
       focusNode = FocusNode(debugLabel: 'terminal-$id') {
    terminal = Terminal(
      maxLines: maxScrollbackLines,
      platform: _targetPlatform(),
      onOutput: _onTerminalOutput,
      onResize: _handleTerminalResize,
    );
    terminal.onTitleChange = (newTitle) {
      if (newTitle.trim().isNotEmpty) {
        title.value = newTitle.trim();
      }
    };
    controller = TerminalController();
  }

  static const int _defaultCols = 80;
  static const int _defaultRows = 24;

  final String id;
  final RxString title;
  final String shell;
  final void Function(String)? onOutput;
  final void Function(int)? onExit;

  final FocusNode focusNode;
  final GlobalKey<TerminalViewState> viewKey = GlobalKey<TerminalViewState>();

  late final Terminal terminal;
  late final TerminalController controller;

  final RxBool isRunning = false.obs;
  final RxString status = 'ready'.obs;

  Pty? _pty;
  StreamSubscription<Uint8List>? _outputSub;
  bool _launchInProgress = false;
  String? _pendingInput;

  int? get pid => _pty?.pid;

  int get _ptyCols =>
      terminal.viewWidth >= 2 ? terminal.viewWidth : _defaultCols;

  int get _ptyRows =>
      terminal.viewHeight >= 2 ? terminal.viewHeight : _defaultRows;

  /// Start the PTY process (safe to call multiple times).
  Future<void> ensureStarted() async {
    if (_pty != null || _launchInProgress) return;

    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      status.value = 'unsupported';
      terminal.write(
        '\r\nTerminal is only available on desktop platforms.\r\n',
      );
      return;
    }

    _launchInProgress = true;
    status.value = 'starting';

    try {
      await _startPty();
    } finally {
      _launchInProgress = false;
    }
  }

  Future<void> _startPty() async {
    final chain = ShellResolver.fallbackChain(shell);
    Object? lastError;

    for (var i = 0; i < chain.length; i++) {
      final config = chain[i];
      if (!config.exists) continue;

      try {
        if (i > 0) {
          terminal.write(
            '\r\n--- Trying fallback: ${config.displayName} ---\r\n',
          );
        }

        await _spawnPty(config);
        title.value = config.displayName;
        return;
      } catch (e, st) {
        lastError = e;
        debugPrint('Terminal spawn failed (${config.executable}): $e\n$st');
        terminal.write('\r\nFailed to start ${config.displayName}: $e\r\n');
        _cleanupPty();
      }
    }

    isRunning.value = false;
    status.value = 'error';
    terminal.write(
      '\r\nCould not start any shell. Last error: $lastError\r\n'
      'Tip: Select Command Prompt or PowerShell 7 from the dropdown.\r\n',
    );
  }

  Future<void> _spawnPty(ShellConfig config) async {
    final cols = _ptyCols.clamp(2, 999);
    final rows = _ptyRows.clamp(2, 999);

    // FIX: Pass Platform.environment down completely! This provides the necessary
    // OS security contexts and variables to avoid the Windows 8009001d cryptography initialization error.
    _pty = Pty.start(
      config.executable,
      arguments: config.arguments,
      rows: rows,
      columns: cols,
      workingDirectory:
          Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'],
      environment: Platform.environment,
    );

    isRunning.value = true;
    status.value = 'running';

    _outputSub = _pty!.output.listen(_onPtyOutput);

    unawaited(
      _pty!.exitCode.then((code) {
        isRunning.value = false;
        final formatted = ShellResolver.formatExitCode(code);
        status.value = 'exited ($formatted)';
        _outputSub?.cancel();
        _outputSub = null;
        _pty = null;
        if (code != 0) {
          terminal.write('\r\n[Process exited with code $formatted]\r\n');
        }
        onExit?.call(code);
      }),
    );

    _flushPendingInput();
  }

  void _cleanupPty() {
    _outputSub?.cancel();
    _outputSub = null;
    try {
      _pty?.kill(ProcessSignal.sigterm);
    } catch (_) {}
    _pty = null;
    isRunning.value = false;
  }

  void _onPtyOutput(Uint8List data) {
    if (data.isEmpty) return;
    final text = utf8.decode(data, allowMalformed: true);
    terminal.write(text);
    onOutput?.call(text);
  }

  void _onTerminalOutput(String data) {
    final pty = _pty;
    if (pty == null) return;
    pty.write(Uint8List.fromList(utf8.encode(data)));
  }

  void focusTerminal() {
    focusNode.requestFocus();
    viewKey.currentState?.requestKeyboard();
  }

  void _handleTerminalResize(
    int width,
    int height,
    int pixelWidth,
    int pixelHeight,
  ) {
    if (_pty != null) {
      if (width >= 2 && height >= 2) {
        _pty!.resize(height.clamp(2, 999), width.clamp(2, 999));
      }
      return;
    }

    // FIX: Defers PTY startup out of the immediate Flutter rendering layout loop frame context
    // using a PostFrameCallback microtask. This stops the Obx layout crash dead in its tracks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ensureStarted());
    });
  }

  Future<void> sendCommand(String command, {bool addNewline = true}) async {
    final trimmed = command.trimRight();
    if (trimmed.isEmpty) return;

    final payload = addNewline && !trimmed.endsWith('\n')
        ? '$trimmed\r\n'
        : trimmed;

    if (_pty != null) {
      _pty!.write(Uint8List.fromList(utf8.encode(payload)));
      return;
    }

    _pendingInput = payload;
    await ensureStarted();
    _flushPendingInput();
  }

  void _flushPendingInput() {
    final pending = _pendingInput;
    if (pending == null || _pty == null) return;
    _pendingInput = null;
    _pty!.write(Uint8List.fromList(utf8.encode(pending)));
  }

  void clearScreen() {
    if (_pty != null) {
      _pty!.write(Uint8List.fromList([0x0c]));
    } else {
      terminal.buffer.clear();
    }
  }

  void kill({ProcessSignal signal = ProcessSignal.sigterm}) {
    try {
      _pty?.kill(signal);
    } catch (_) {}
    isRunning.value = false;
    status.value = 'killed';
  }

  Future<void> restart() async {
    stop();
    await ensureStarted();
  }

  void stop() {
    _outputSub?.cancel();
    _outputSub = null;
    try {
      _pty?.kill(ProcessSignal.sigterm);
    } catch (_) {}
    _pty = null;
    isRunning.value = false;
    status.value = 'stopped';
  }

  void dispose() {
    stop();
    focusNode.dispose();
    controller.dispose();
  }

  static TerminalTargetPlatform _targetPlatform() {
    if (kIsWeb) return TerminalTargetPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return TerminalTargetPlatform.android;
      case TargetPlatform.iOS:
        return TerminalTargetPlatform.ios;
      case TargetPlatform.fuchsia:
        return TerminalTargetPlatform.fuchsia;
      case TargetPlatform.linux:
        return TerminalTargetPlatform.linux;
      case TargetPlatform.macOS:
        return TerminalTargetPlatform.macos;
      case TargetPlatform.windows:
        return TerminalTargetPlatform.windows;
    }
  }
}
