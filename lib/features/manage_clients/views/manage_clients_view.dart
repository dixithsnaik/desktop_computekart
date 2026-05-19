import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/wsl_terminal_modal.dart';
import '../../../core/services/wsl_execution_service.dart';
import '../controllers/manage_clients_controller.dart';

class ManageClientsView extends GetView<ManageClientsController> {
  const ManageClientsView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Manage CLIs', style: AppTextStyles.h2(p.textPrimary)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final cmd = await controller.addClient();
                    if (context.mounted && cmd != null) {
                      ActionConfirmModal.show(
                        context,
                        message: 'Run this command to connect your CLI:',
                        command: cmd,
                        showCopyToken: true,
                        showConfirm: false,
                        cancelLabel: 'Close',
                        onRunHere: () {
                          Get.find<WslExecutionService>()
                              .executeCommandInBackground(
                                title: 'Installing CLI',
                                command: cmd,
                                initialSteps: [
                                  WslStep(
                                    id: 'cleanup',
                                    label: 'Cleanup previous installs',
                                  ),
                                  WslStep(
                                    id: 'tunnel',
                                    label: 'Downloading tunnel client',
                                  ),
                                  WslStep(
                                    id: 'package',
                                    label: 'Downloading package',
                                  ),
                                  WslStep(
                                    id: 'deps',
                                    label: 'Installing dependencies',
                                  ),
                                  WslStep(
                                    id: 'final',
                                    label: 'Finalizing installation',
                                  ),
                                ],
                              );
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add CLI'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value)
                  return const Center(child: LoadingIndicator());
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: ListView.builder(
                        itemCount: controller.clients.length,
                        itemBuilder: (_, i) {
                          final c = controller.clients[i];
                          return Obx(() {
                            final sel =
                                controller.selectedClient.value?['cli_id'] ==
                                c['cli_id'];
                            return _CliTile(
                              cli: c,
                              sel: sel,
                              p: p,
                              onTap: () => controller.selectClient(c),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Obx(() {
                        final sc = controller.selectedClient.value;
                        if (sc == null)
                          return Center(
                            child: Text(
                              'Select a CLI session',
                              style: AppTextStyles.body(p.textMuted),
                            ),
                          );
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: p.bgSurface,
                            border: Border.all(color: p.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CLI Details',
                                style: AppTextStyles.h3(p.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              _copyRow(
                                'CLI ID',
                                sc['cli_id'] ?? '',
                                p,
                                context,
                              ),
                              if (sc['wireguard_endpoint'] != null)
                                _copyRow(
                                  'WG Endpoint',
                                  sc['wireguard_endpoint'],
                                  p,
                                  context,
                                ),
                              if (sc['wireguard_public_key'] != null)
                                _copyRow(
                                  'WG Public Key',
                                  sc['wireguard_public_key'],
                                  p,
                                  context,
                                ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: sc['cli_status'] == true
                                          ? AppColors.lime500
                                          : AppColors.red500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sc['cli_status'] == true
                                        ? 'Active'
                                        : 'Inactive',
                                    style: AppTextStyles.bodySemibold(
                                      sc['cli_status'] == true
                                          ? AppColors.lime600
                                          : AppColors.red500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ActionConfirmModal.show(
                                    context,
                                    message: 'Delete this CLI session?',
                                    onConfirm: () async {
                                      final r = await controller.deleteClient(
                                        sc['cli_id'],
                                      );
                                      if (context.mounted)
                                        AppToast.info(context, r ?? 'Deleted');
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red500,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _copyRow(String label, String value, AppPalette p, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelUppercase(p.textMuted)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: AppTextStyles.mono(p.textPrimary),
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  AppToast.success(ctx, 'Copied!');
                },
                child: Icon(Icons.copy, size: 14, color: p.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CliTile extends StatefulWidget {
  final Map<String, dynamic> cli;
  final bool sel;
  final AppPalette p;
  final VoidCallback onTap;
  const _CliTile({
    required this.cli,
    required this.sel,
    required this.p,
    required this.onTap,
  });
  @override
  State<_CliTile> createState() => _CliTileState();
}

class _CliTileState extends State<_CliTile> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.sel
                ? AppColors.lime100
                : _h
                ? widget.p.bgSurfaceMuted
                : widget.p.bgSurface,
            border: Border.all(
              color: widget.sel ? AppColors.lime500 : widget.p.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.cli['cli_status'] == true
                      ? AppColors.lime500
                      : AppColors.red500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.cli['cli_id'] ?? '',
                  style: AppTextStyles.bodyMedium(
                    widget.sel
                        ? AppColors.lightTextPrimary
                        : widget.p.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
