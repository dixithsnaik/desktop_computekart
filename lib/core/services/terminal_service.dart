import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'terminal/shell_config.dart';
import 'terminal/terminal_session.dart';

/// Manages multiple integrated terminal sessions (tabs).
class TerminalService extends GetxService {
  final sessions = <TerminalSession>[].obs;
  final RxBool isPanelOpen = false.obs;
  final activeSessionId = Rxn<String>();

  /// Default shell for new terminals (platform auto-detect).
  String get defaultShell => ShellResolver.defaultKind.name;

  void togglePanel() {
    isPanelOpen.value = !isPanelOpen.value;
    if (isPanelOpen.value) {
      if (sessions.isEmpty) {
        createSession();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final active = getActiveSession();
        active?.ensureStarted();
        active?.focusTerminal();
      });
    }
  }

  /// Legacy alias used by downloads panel and other callers.
  TerminalSession createInstance({
    String? title,
    String? shell,
  }) =>
      createSession(title: title, shell: shell);

  TerminalSession createSession({
    String? title,
    String? shell,
  }) {
    final shellId = shell ?? defaultShell;
    final config = ShellResolver.resolve(shellId);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final session = TerminalSession(
      id: id,
      initialTitle: title ?? config.displayName,
      shell: shellId,
    );
    sessions.insert(0, session);
    activeSessionId.value = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      session.ensureStarted();
    });
    return session;
  }

  void closeSession(String id) {
    final session = find(id);
    if (session == null) return;
    session.dispose();
    sessions.removeWhere((s) => s.id == id);
    if (activeSessionId.value == id) {
      activeSessionId.value =
          sessions.isNotEmpty ? sessions.first.id : null;
    }
    if (sessions.isEmpty && isPanelOpen.value) {
      createSession();
    }
  }

  TerminalSession? find(String id) =>
      sessions.firstWhereOrNull((s) => s.id == id);

  void setActiveSession(String id) {
    final session = find(id);
    if (session == null) return;
    activeSessionId.value = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      session.focusTerminal();
    });
  }

  /// Run a command in a specific terminal session (e.g. from downloads panel).
  Future<void> sendToInstance(String id, String command) async {
    final session = find(id);
    if (session == null) return;
    setActiveSession(id);
    await session.sendCommand(command);
  }

  TerminalSession? getActiveSession() {
    final id = activeSessionId.value;
    if (id != null) return find(id);
    return sessions.isNotEmpty ? sessions.first : null;
  }

  void killActiveSession() {
    getActiveSession()?.kill();
  }

  Future<void> restartActiveSession() async {
    await getActiveSession()?.restart();
  }

  @override
  void onClose() {
    for (final session in List<TerminalSession>.from(sessions)) {
      session.dispose();
    }
    sessions.clear();
    super.onClose();
  }
}
