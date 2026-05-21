import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/wsl_execution_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class WslTerminalModal extends StatefulWidget {
  final String title;
  final String? command;
  final WslTask? existingTask;

  const WslTerminalModal({
    super.key,
    required this.title,
    this.command,
    this.existingTask,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String command,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WslTerminalModal(title: title, command: command),
    );
  }

  static void showForTask(BuildContext context, WslTask task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WslTerminalModal(title: task.title, existingTask: task),
    );
  }

  @override
  State<WslTerminalModal> createState() => _WslTerminalModalState();
}

class _WslTerminalModalState extends State<WslTerminalModal> {
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  bool _isRunning = true;
  int? _exitCode;
  Process? _process;

  String? _originalTaskId;
  String? _originalCommand;

  @override
  void initState() {
    super.initState();

    if (widget.existingTask != null) {
      _bindToTask(widget.existingTask!);
    } else if (widget.command != null) {
      _startExecution();
    }
  }

  void _startExecution() {
    _addLog('\$ ${widget.command}\n');

    final service = Get.find<WslExecutionService>();

    service.executeCommandInBackground(
      title: widget.title,
      command: widget.command!,
    );

    final task = service.tasks.first;
    _bindToTask(task);
    _originalCommand = widget.command;
    _originalTaskId = task.id;
  }

  void _bindToTask(WslTask task) {
    _logs.clear();
    _logs.addAll(_normalizeLogs(task.logs));

    _isRunning = task.status.value == WslTaskStatus.running;
    _exitCode = task.exitCode;
    _process = task.process;

    ever(task.lastLogLine, (_) {
      if (!mounted) return;

      setState(() {
        _mergeLogs(task.logs);
      });

      _scrollLogsToBottom();
    });

    ever(task.status, (status) {
      if (!mounted) return;

      setState(() {
        _isRunning = status == WslTaskStatus.running;
        _exitCode = task.exitCode;
      });
    });

    ever(task.steps, (_) {
      if (mounted) setState(() {});
    });
  }

  void _restartCommand() {
    if (_originalCommand == null) return;
    final service = Get.find<WslExecutionService>();
    service.executeCommandInBackground(
      title: widget.title,
      command: _originalCommand!,
    );
    final newTask = service.tasks.first;
    _bindToTask(newTask);
    _originalTaskId = newTask.id;
  }

  void _mergeLogs(List<String> incoming) {
    final normalized = _normalizeLogs(incoming);
    _logs.clear();
    _logs.addAll(normalized);
  }

  List<String> _normalizeLogs(List<String> logs) {
    final result = <String>[];
    for (final raw in logs) {
      final log = _cleanLog(raw);
      if (log.contains('\r')) {
        final parts = log.split('\r');
        final liveLine = parts.last;
        if (result.isNotEmpty) {
          result[result.length - 1] = liveLine;
        } else {
          result.add(liveLine);
        }
      } else {
        result.add(log);
      }
    }
    return result;
  }

  void _addLog(String value) {
    if (!mounted) return;

    final cleaned = _cleanLog(value);

    setState(() {
      if (cleaned.contains('\r')) {
        final parts = cleaned.split('\r');
        final last = parts.last;

        if (_logs.isNotEmpty) {
          _logs[_logs.length - 1] = last;
        } else {
          _logs.add(last);
        }
      } else {
        _logs.add(cleaned);
      }
    });

    _scrollLogsToBottom();
  }

  void _scrollLogsToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _cleanLog(String log) {
    return log
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'\x1B\[[0-9;]*[A-Za-z]'), '')
        .trimRight();
  }

  bool _isProgressLog(String log) {
    return log.contains('%') &&
        (log.contains('Received') ||
            log.contains('Total') ||
            log.contains('Dload') ||
            log.contains('Uploading') ||
            log.contains('Downloading'));
  }

  Color _stepColor(String status, AppPalette palette) {
    switch (status) {
      case 'done':
        return AppColors.lime500;
      case 'running':
        return AppColors.lime300;
      case 'failed':
        return AppColors.red500;
      default:
        return palette.textMuted;
    }
  }

  IconData _stepIcon(String status) {
    switch (status) {
      case 'done':
        return Icons.check_circle_rounded;
      case 'running':
        return Icons.downloading_rounded;
      case 'failed':
        return Icons.cancel_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDark: isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 760,
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: MediaQuery.of(context).size.height * .88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF050B14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1B2433)),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildHeader(palette),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF030812),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1B2433)),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: AppColors.lime500,
                          unselectedLabelColor: palette.textMuted,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          indicator: BoxDecoration(
                            color: AppColors.lime500.withOpacity(.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tabs: const [
                            Tab(text: "Progress"),
                            Tab(text: "Live Logs"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildProgressSection(palette),
                            _buildLogsSection(palette),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1B2433))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lime500.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.developer_board_rounded,
              color: AppColors.lime500,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.h3(
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRunning
                      ? 'Installing provider node...'
                      : _exitCode == 0
                          ? 'Task completed successfully'
                          : 'Task failed',
                  style: AppTextStyles.caption(palette.textMuted),
                ),
              ],
            ),
          ),
          if (_isRunning)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(AppColors.lime500),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _exitCode == 0
                    ? AppColors.lime500.withOpacity(.12)
                    : AppColors.red500.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _exitCode == 0 ? 'SUCCESS' : 'FAILED',
                style: TextStyle(
                  color: _exitCode == 0 ? AppColors.lime500 : AppColors.red500,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(width: 16),
          InkWell(
            onTap: _restartCommand,
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AppPalette palette) {
    if (widget.existingTask == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1B2433)),
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: const Color(0xFF141D2B),
              valueColor: AlwaysStoppedAnimation(AppColors.lime500),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing installation...',
              style: AppTextStyles.body(palette.textSecondary),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final progress = widget.existingTask!.progress.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1B2433)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: progress > 0 ? progress : null,
                      backgroundColor: const Color(0xFF141D2B),
                      valueColor: AlwaysStoppedAnimation(AppColors.lime500),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.body(
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView(
                children: widget.existingTask!.steps.map((step) {
                  final color = _stepColor(step.status.value, palette);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color.withOpacity(.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _stepIcon(step.status.value),
                            size: 16,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.label,
                                style: AppTextStyles.body(Colors.white).copyWith(
                                  fontWeight: step.status.value == 'running'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (step.duration != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${step.duration!.inSeconds}s',
                                  style: AppTextStyles.caption(palette.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: palette.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'ETA ${widget.existingTask!.estimatedRemaining()}',
                  style: AppTextStyles.caption(palette.textMuted),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLogsSection(AppPalette palette) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF030812),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1B2433)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1B2433))),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 18,
                  color: AppColors.lime500,
                ),
                const SizedBox(width: 10),
                Text(
                  'Live Logs',
                  style: AppTextStyles.body(
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? AppColors.lime500
                        : (_exitCode == 0 ? AppColors.lime500 : AppColors.red500),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for logs...',
                      style: AppTextStyles.body(palette.textMuted),
                    ),
                  )
                : ListView.builder(
                    controller: _logScrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount: _logs.length,
                    itemBuilder: (_, index) {
                      final log = _cleanLog(_logs[index]);

                      if (log.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final isProgressLine = _isProgressLog(log);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isProgressLine) ...[
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation(AppColors.lime500),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: SelectableText(
                                log,
                                style: AppTextStyles.mono(
                                  isProgressLine
                                      ? AppColors.lime300
                                      : const Color(0xFFB8C4D6),
                                ).copyWith(fontSize: 12.5, height: 1.55),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}