import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/wsl_execution_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/terminal_service.dart';
import '../../shared/sidebar/app_sidebar.dart';
import 'dart:io';

class DownloadsPanel extends StatelessWidget {
  const DownloadsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = Get.find<WslExecutionService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDark: isDark);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: palette.bgSurface,
        border: Border(left: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Row(
              children: [
                Text(
                  'Background Tasks',
                  style: AppTextStyles.h4(palette.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: palette.textMuted, size: 20),
                  onPressed: dm.togglePanel,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (dm.tasks.isEmpty) {
                return Center(
                  child: Text(
                    'No active tasks',
                    style: AppTextStyles.body(palette.textMuted),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: dm.tasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = dm.tasks[index];
                  return _TaskItem(task: task, palette: palette);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final WslTask task;
  final AppPalette palette;

  const _TaskItem({required this.task, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.bgSurfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: palette.brand0a, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.bodySemibold(palette.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                if (task.status.value == WslTaskStatus.running) {
                  return InkWell(
                    onTap: () => task.cancel(),
                    child: Icon(
                      Icons.cancel,
                      color: palette.textMuted,
                      size: 16,
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: () =>
                        Get.find<WslExecutionService>().removeTask(task.id),
                    child: Icon(
                      Icons.close,
                      color: palette.textMuted,
                      size: 16,
                    ),
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.status.value == WslTaskStatus.running)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Obx(
                      () => LinearProgressIndicator(
                        backgroundColor: palette.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.lime500,
                        ),
                        value: task.progress.value > 0
                            ? task.progress.value
                            : null,
                      ),
                    ),
                  ),
                Text(
                  task.lastLogLine.value,
                  style: AppTextStyles.mono(
                    palette.textSecondary,
                  ).copyWith(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (task.status.value == WslTaskStatus.running)
                      Obx(
                        () => Text(
                          task.progress.value > 0
                              ? 'Running • ${(task.progress.value * 100).toStringAsFixed(0)}% (ETA ${task.estimatedRemaining()})'
                              : 'Running...',
                          style: AppTextStyles.bodySmall(AppColors.lime600),
                        ),
                      )
                    else if (task.status.value == WslTaskStatus.completed)
                      Text(
                        'Completed',
                        style: AppTextStyles.bodySmall(AppColors.lime600),
                      )
                    else if (task.status.value == WslTaskStatus.failed)
                      Text(
                        'Failed',
                        style: AppTextStyles.bodySmall(AppColors.red500),
                      )
                    else if (task.status.value == WslTaskStatus.cancelled)
                      Text(
                        'Cancelled',
                        style: AppTextStyles.bodySmall(palette.textMuted),
                      ),

                    const Spacer(),

                    // Show Logs Button
                    InkWell(
                      onTap: () {
                        final ts = Get.find<TerminalService>();
                        // Start CMD as the PTY shell, then enter WSL inside it.
                        final shell = Platform.isWindows ? 'cmd' : 'bash';
                        final inst = ts.createSession(
                          shell: shell,
                          title: task.title,
                        );
                        if (Platform.isWindows) {
                          // Step 1: enter WSL from CMD
                          Future.delayed(const Duration(milliseconds: 600), () {
                            ts.sendToInstance(inst.id, 'wsl');
                          });
                          // Step 2: send the task command inside WSL
                          Future.delayed(const Duration(milliseconds: 2200), () {
                            ts.sendToInstance(inst.id, task.command);
                          });
                        } else {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            ts.sendToInstance(inst.id, task.command);
                          });
                        }
                        // Navigate to the Terminal view and focus the session.
                        Get.find<SidebarController>().navigateTo(AppRoutes.terminal);
                      },
                      child: Text(
                        'Open In Terminal',
                        style: AppTextStyles.bodySmall(AppColors.blue500),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
