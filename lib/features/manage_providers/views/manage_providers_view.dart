import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/sidebar/app_sidebar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_provider_card.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../../../core/services/wsl_execution_service.dart';
import '../controllers/manage_providers_controller.dart';

class ManageProvidersView extends GetView<ManageProvidersController> {
  const ManageProvidersView({super.key});
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
                Text(
                  'Manage Providers',
                  style: AppTextStyles.h2(p.textPrimary),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final cmd = await controller.addProvider();
                    if (context.mounted && cmd != null) {
                      ActionConfirmModal.show(
                        context,
                        message: 'Run this command on your provider server:',
                        command: cmd,
                        showCopyToken: true,
                        showConfirm: false,
                        cancelLabel: 'Close',
                        onRunHere: () {
                          Get.find<WslExecutionService>()
                              .executeCommandInBackground(
                                title: 'Installing Provider Node',
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
                                    id: 'image',
                                    label: 'Downloading VM image',
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
                                    id: 'java',
                                    label: 'Installing custom Java',
                                  ),
                                  WslStep(
                                    id: 'final',
                                    label: 'Finalizing installation',
                                  ),
                                ],
                              );
                          // Navigate to terminal so the user sees live output.
                          Get.find<SidebarController>().navigateTo(AppRoutes.terminal);
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Provider'),
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
                        itemCount: controller.providers.length,
                        itemBuilder: (_, i) {
                          final prov = controller.providers[i];
                          return Obx(() {
                            final sel =
                                controller
                                    .selectedProvider
                                    .value?['providerId'] ==
                                prov['providerId'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => controller.selectProvider(prov),
                                child: AppProviderCard(
                                  provider: prov,
                                  isActive: sel,
                                  palette: p,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() {
                        final sp = controller.selectedProvider.value;
                        if (sp == null)
                          return Center(
                            child: Text(
                              'Select a provider',
                              style: AppTextStyles.body(p.textMuted),
                            ),
                          );
                        return SingleChildScrollView(
                          child: Container(
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
                                  sp['providerName'] ?? '',
                                  style: AppTextStyles.h3(p.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                if (sp['providerAllowedVcpu'] != null)
                                  _info(
                                    'Max vCPUs',
                                    '${sp['providerAllowedVcpu']}',
                                    p,
                                  ),
                                if (sp['providerAllowedRam'] != null)
                                  _info(
                                    'Max RAM',
                                    '${(int.tryParse(sp['providerAllowedRam'].toString()) ?? 0) ~/ 1024} GB',
                                    p,
                                  ),
                                if (sp['providerAllowedVms'] != null)
                                  _info(
                                    'Max VMs',
                                    '${sp['providerAllowedVms']}',
                                    p,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 280,
                      child: Obx(() {
                        if (controller.selectedProvider.value == null)
                          return const SizedBox();
                        if (controller.isLoadingClients.value)
                          return const Center(child: LoadingIndicator());
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: p.bgSurface,
                            border: Border.all(color: p.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clients',
                                style: AppTextStyles.h4(p.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              if (controller.providerClients.isEmpty)
                                Text(
                                  'No clients',
                                  style: AppTextStyles.body(p.textMuted),
                                ),
                              ...controller.providerClients.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: c['status'] == true
                                              ? AppColors.lime500
                                              : AppColors.red500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          c['clientName'] ??
                                              c['clientId'] ??
                                              '',
                                          style: AppTextStyles.body(
                                            p.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _info(String label, String value, AppPalette p) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(label, style: AppTextStyles.bodyMedium(p.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyMedium(p.textPrimary)),
      ],
    ),
  );
}
