import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'terminal_service.dart';

enum WslTaskStatus { running, completed, failed, cancelled }

class WslStep {
  final String id;
  final String label;
  final RxString status = 'pending'.obs; // pending | running | done | failed
  int? startMs;
  int? endMs;

  WslStep({required this.id, required this.label});

  Duration? get duration => (startMs != null && endMs != null)
      ? Duration(milliseconds: endMs! - startMs!)
      : null;
}

class WslTask {
  final String id;
  final String title;
  final String command;
  final Rx<WslTaskStatus> status = WslTaskStatus.running.obs;
  final RxString lastLogLine = 'Initializing...'.obs;
  final RxList<String> logs = <String>[].obs;
  final RxList<WslStep> steps = <WslStep>[].obs;
  final RxDouble progress = 0.0.obs; // 0.0 .. 1.0
  final List<int> _completedStepDurations = [];
  int? exitCode;
  int? startMs;

  WslTask({
    required this.id,
    required this.title,
    required this.command,
    List<WslStep>? initialSteps,
  }) {
    if (initialSteps != null) {
      steps.addAll(initialSteps);
    }
  }

  void addLog(String data, {bool isError = false}) {
    final lines = data.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      lastLogLine.value = lines.last;
      logs.addAll(lines);
    }
  }

  void cancel() {
    if (status.value == WslTaskStatus.running) {
      final ts = Get.find<TerminalService>();
      ts.find(id)?.kill();
      status.value = WslTaskStatus.cancelled;
      addLog('\n[Task cancelled by user]');
    }
  }

  String estimatedRemaining() {
    if (_completedStepDurations.isEmpty) return 'estimating...';
    final avg =
        _completedStepDurations.reduce((a, b) => a + b) /
        _completedStepDurations.length;
    final remaining = steps.where((s) => s.status.value != 'done').length;
    final remMs = (avg * remaining).round();
    final secs = (remMs / 1000).ceil();
    return '${secs}s';
  }

  void _markStepRunning(int index) {
    if (index < 0 || index >= steps.length) return;
    final s = steps[index];
    if (s.status.value == 'pending') {
      s.status.value = 'running';
      s.startMs = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void _markStepDone(int index) {
    if (index < 0 || index >= steps.length) return;
    final s = steps[index];
    if (s.status.value != 'done') {
      s.status.value = 'done';
      s.endMs = DateTime.now().millisecondsSinceEpoch;
      if (s.startMs != null && s.endMs != null) {
        _completedStepDurations.add(s.endMs! - s.startMs!);
      }
      _recalculateProgress();
    }
  }

  void _recalculateProgress() {
    final total = steps.length;
    if (total == 0) return;
    final done = steps.where((s) => s.status.value == 'done').length;
    final running = steps.where((s) => s.status.value == 'running').length;
    final p = (done + running * 0.5) / total;
    progress.value = p.clamp(0.0, 1.0);
  }
}

class WslExecutionService extends GetxService {
  final tasks = <WslTask>[].obs;
  final RxBool isPanelOpen = false.obs;

  void togglePanel() {
    isPanelOpen.value = !isPanelOpen.value;
  }

  WslTask executeCommandInBackground({
    required String title,
    required String command,
    List<WslStep>? initialSteps,
  }) {
    final ts = Get.find<TerminalService>();
    final shell = Platform.isWindows ? 'cmd' : 'bash';

    late WslTask task;

    final session = ts.createSession(
      shell: shell,
      title: title,
      onOutput: (text) {
        task.addLog(text);
        _tryParseAndUpdateSteps(task, text);
      },
      onExit: (code) {
        task.exitCode = code;
        if (task.status.value == WslTaskStatus.running) {
          if (code == 0) {
            task.status.value = WslTaskStatus.completed;
            task.addLog('\n[Process completed successfully]');
            for (var i = 0; i < task.steps.length; i++) {
              task._markStepDone(i);
            }
            task.progress.value = 1.0;
          } else {
            task.status.value = WslTaskStatus.failed;
            task.addLog('\n[Process failed with exit code $code]');
            for (var i = 0; i < task.steps.length; i++) {
              if (task.steps[i].status.value == 'running') {
                task.steps[i].status.value = 'failed';
              }
            }
          }
        }
      },
    );

    task = WslTask(
      id: session.id, // The task ID matches the TerminalSession ID
      title: title,
      command: command,
      initialSteps: initialSteps,
    );

    tasks.insert(0, task);
    
    task.addLog('\$ $command');
    task.startMs = DateTime.now().millisecondsSinceEpoch;
    if (task.steps.isNotEmpty) {
      task.steps[0].status.value = 'pending';
      task._markStepRunning(0);
    }

    // Sequence the command execution via TerminalService
    if (Platform.isWindows) {
      Future.delayed(const Duration(milliseconds: 600), () {
        ts.sendToInstance(session.id, 'wsl');
      });
      Future.delayed(const Duration(milliseconds: 2200), () {
        ts.sendToInstance(session.id, command);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        ts.sendToInstance(session.id, command);
      });
    }

    return task;
  }

  void _tryParseAndUpdateSteps(WslTask task, String line) {
    final text = line.toLowerCase();
    final mapping = {
      'cleanup': ['cleanup', 'remove', 'cleaning'],
      'tunnel': ['tunnel', 'tunnel client', 'wireguard', 'wg-quick'],
      'image': ['vm image', 'downloading vm', '.img', 'image'],
      'package': ['downloading package', 'downloading mega', 'package'],
      'deps': [
        'dependencies',
        'apt-get install',
        'yum install',
        'installing dependencies',
      ],
      'java': ['java', 'openjdk', 'install java', 'custom java'],
      'final': [
        'finalizing',
        'installation completed',
        'completed successfully',
        'finished',
      ],
    };

    final ids = task.steps.map((s) => s.id).toList();
    for (var entry in mapping.entries) {
      final id = entry.key;
      final keywords = entry.value;
      for (var k in keywords) {
        if (text.contains(k)) {
          final idx = ids.indexOf(id);
          if (idx != -1) {
            for (var i = 0; i < idx; i++) {
              task._markStepDone(i);
            }
            task._markStepRunning(idx);
            task._markStepDone(idx);
            if (idx + 1 < task.steps.length) task._markStepRunning(idx + 1);
            return;
          }
        }
      }
    }
  }

  void removeTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
  }
}
