import 'dart:io';

/// Supported shell kinds for integrated terminals.
enum ShellKind {
  pwsh,
  powershell,
  cmd,
  wsl,
  bash,
  zsh,
  fish,
}

/// Executable + arguments for spawning a PTY process.
class ShellConfig {
  const ShellConfig({
    required this.kind,
    required this.displayName,
    required this.executable,
    this.arguments = const [],
  });

  final ShellKind kind;
  final String displayName;
  final String executable;
  final List<String> arguments;

  String get id => kind.name;

  /// Whether this executable exists on disk.
  bool get exists => File(executable).existsSync();
}

/// Resolves platform-appropriate shells (VS Code–style auto-detect).
class ShellResolver {
  ShellResolver._();

  static List<ShellConfig>? _cached;

  /// Prefer PowerShell 7, then CMD, then Windows PowerShell 5.1.
  static ShellKind get defaultKind {
    if (!Platform.isWindows) {
      if (Platform.isMacOS || Platform.isLinux) {
        final shell = Platform.environment['SHELL'];
        if (shell != null && shell.contains('zsh')) return ShellKind.zsh;
        if (shell != null && shell.contains('fish')) return ShellKind.fish;
      }
      return ShellKind.bash;
    }

    final available = availableOnPlatform();
    if (available.any((c) => c.kind == ShellKind.pwsh)) {
      return ShellKind.pwsh;
    }
    if (available.any((c) => c.kind == ShellKind.cmd)) {
      return ShellKind.cmd;
    }
    return ShellKind.powershell;
  }

  /// All shells that exist on this machine.
  static List<ShellConfig> availableOnPlatform() {
    if (_cached != null) return _cached!;

    if (Platform.isWindows) {
      // Exclude WSL shell kind from the user-facing dropdown — WSL is entered
      // programmatically via a `wsl` command sent into a CMD session instead.
      _cached = _windowsShells()
          .where((c) => c.exists && c.kind != ShellKind.wsl)
          .toList();
      if (_cached!.isEmpty) {
        _cached = [
          const ShellConfig(
            kind: ShellKind.cmd,
            displayName: 'Command Prompt',
            executable: r'C:\Windows\System32\cmd.exe',
          ),
        ];
      }
      return _cached!;
    }

    final shell = Platform.environment['SHELL'] ?? '/bin/bash';
    _cached = [
      if (File(shell).existsSync())
        ShellConfig(
          kind: ShellKind.bash,
          displayName: 'Bash',
          executable: shell,
          arguments: const ['-l'],
        ),
      if (File('/bin/zsh').existsSync())
        const ShellConfig(
          kind: ShellKind.zsh,
          displayName: 'Zsh',
          executable: '/bin/zsh',
          arguments: ['-l'],
        ),
      if (File('/usr/bin/fish').existsSync())
        const ShellConfig(
          kind: ShellKind.fish,
          displayName: 'Fish',
          executable: '/usr/bin/fish',
          arguments: ['-l'],
        ),
    ];
    return _cached!;
  }

  static List<ShellConfig> _windowsShells() {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
    final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';

    final pwshCandidates = [
      '$programFiles\\PowerShell\\7\\pwsh.exe',
      '$programFiles\\PowerShell\\7-preview\\pwsh.exe',
      if (localAppData.isNotEmpty)
        '$localAppData\\Microsoft\\WindowsApps\\pwsh.exe',
    ];

    final gitBashCandidates = [
      r'C:\Program Files\Git\bin\bash.exe',
      r'C:\Program Files (x86)\Git\bin\bash.exe',
    ];

    final configs = <ShellConfig>[];

    for (final path in pwshCandidates) {
      configs.add(
        ShellConfig(
          kind: ShellKind.pwsh,
          displayName: 'PowerShell 7',
          executable: path,
          arguments: const ['-NoLogo', '-NoProfile'],
        ),
      );
    }

    configs.addAll([
      const ShellConfig(
        kind: ShellKind.cmd,
        displayName: 'Command Prompt',
        executable: r'C:\Windows\System32\cmd.exe',
      ),
      const ShellConfig(
        kind: ShellKind.powershell,
        displayName: 'Windows PowerShell',
        executable: r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
        // -NoProfile avoids crypto/profile failures (error 8009001d).
        arguments: ['-NoLogo', '-NoProfile'],
      ),
      const ShellConfig(
        kind: ShellKind.wsl,
        displayName: 'WSL',
        executable: r'C:\Windows\System32\wsl.exe',
        arguments: ['-e', 'bash', '-l'],
      ),
    ]);

    for (final path in gitBashCandidates) {
      configs.add(
        ShellConfig(
          kind: ShellKind.bash,
          displayName: 'Git Bash',
          executable: path,
          arguments: const ['--login', '-i'],
        ),
      );
    }

    // Deduplicate by executable path (keep first / highest priority).
    final seen = <String>{};
    return configs.where((c) => seen.add(c.executable.toLowerCase())).toList();
  }

  static ShellConfig resolve(String shellId) {
    final normalized = shellId.toLowerCase();
    final available = availableOnPlatform();

    for (final config in available) {
      if (config.id == normalized || config.kind.name == normalized) {
        return config;
      }
    }

    // Legacy: "powershell" → prefer pwsh when Windows PS 5.1 is broken.
    if (normalized == 'powershell') {
      return available.firstWhere(
        (c) => c.kind == ShellKind.pwsh,
        orElse: () => available.firstWhere(
          (c) => c.kind == ShellKind.cmd,
          orElse: () => available.firstWhere(
            (c) => c.kind == ShellKind.powershell,
            orElse: () => available.first,
          ),
        ),
      );
    }

    return available.firstWhere(
      (c) => c.kind == defaultKind,
      orElse: () => available.first,
    );
  }

  /// Fallback chain when the requested shell fails to start or exits immediately.
  static List<ShellConfig> fallbackChain(String shellId) {
    final primary = resolve(shellId);
    final available = availableOnPlatform();
    final chain = <ShellConfig>[primary];

    for (final config in available) {
      if (config.executable != primary.executable) {
        chain.add(config);
      }
    }
    return chain;
  }

  static String formatExitCode(int code) {
    if (!Platform.isWindows) return code.toString();

    if (code > 0x7FFFFFFF) {
      final signed = code - 0x100000000;
      return '$signed (0x${signed.abs().toRadixString(16)})';
    }
    if (code < 0) {
      return '$code (0x${code.abs().toRadixString(16)})';
    }
    return code.toString();
  }
}
