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

import 'package:fl_chart/fl_chart.dart';

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
                          Get.find<SidebarController>().navigateTo(AppRoutes.terminal);
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime500, foregroundColor: Colors.white),
                  label: const Text('Add new Provider'),
                ),
                const SizedBox(width: 16),
                Obx(() => ElevatedButton.icon(
                  onPressed: controller.selectedProvider.value == null ? null : () async {
                    final p = controller.selectedProvider.value!;
                    final res = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('Delete Provider'),
                        content: Text('Are you sure you want to delete ${p['providerName']}?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      )
                    );
                    if (res == true) {
                      final success = await controller.deleteProvider(p['providerId']);
                      if (success) {
                        Get.snackbar('Success', 'Provider deleted', backgroundColor: Colors.green, colorText: Colors.white);
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500, foregroundColor: Colors.white),
                  label: const Text('Delete Provider'),
                )),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: LoadingIndicator());
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT side - Provider List
                    SizedBox(
                      width: 320,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.bgSurface,
                          border: Border.all(color: p.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Providers', style: AppTextStyles.h4(p.textPrimary)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.providers.length,
                                itemBuilder: (_, i) {
                                  final prov = controller.providers[i];
                                  return Obx(() {
                                    final sel = controller.selectedProvider.value?['providerId'] == prov['providerId'];
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // MIDDLE side - Form
                    Expanded(
                      flex: 4,
                      child: Obx(() {
                        final sp = controller.selectedProvider.value;
                        if (sp == null) return Container();
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: p.bgSurface,
                            border: Border.all(color: p.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Setup / Update Provider', style: AppTextStyles.h4(p.textPrimary)),
                                const SizedBox(height: 16),
                                TextFormField(
                                  initialValue: controller.selectedProviderName.value,
                                  onChanged: (val) => controller.selectedProviderName.value = val,
                                  decoration: InputDecoration(
                                    labelText: 'Provider Name',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  initialValue: sp['providerId'] ?? '',
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Provider ID',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown('Select max vCPUs', controller.selectedVcpu, ["1 vCPU", "2 vCPUs", "4 vCPUs", "8 vCPUs", "16 vCPUs", "32 vCPUs", "64 vCPUs"]),
                                const SizedBox(height: 16),
                                _buildDropdown('Select max RAM', controller.selectedRam, ["2 GB", "4 GB", "8 GB", "16 GB", "32 GB", "64 GB"]),
                                const SizedBox(height: 16),
                                _buildDropdown('Select Storage', controller.selectedStorage, ["2 GB", "10 GB", "20 GB", "50 GB", "100 GB", "200 GB", "500 GB"]),
                                const SizedBox(height: 16),
                                _buildDropdown('Select max Networks', controller.selectedNetworks, ["1 Network", "2 Networks", "3 Networks", "4 Networks", "5 Networks", "6 Networks"]),
                                const SizedBox(height: 16),
                                _buildDropdown('Select max VMs', controller.selectedVms, ["1 VM", "2 VMs", "3 VMs", "4 VMs", "5 VMs", "6 VMs"]),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () async {
                                    final err = await controller.saveProviderConfig();
                                    if (err != null) {
                                      Get.snackbar('Error', err, backgroundColor: Colors.red, colorText: Colors.white);
                                    } else {
                                      Get.snackbar('Success', 'Provider updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lime500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                                  ),
                                  child: const Text('Save Provider'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    // RIGHT side - Graph and Clients
                    Expanded(
                      flex: 5,
                      child: Obx(() {
                        if (controller.selectedProvider.value == null) return Container();
                        return Column(
                          children: [
                            // Graph container
                            Expanded(
                              flex: 6,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: p.bgSurface,
                                  border: Border.all(color: p.border),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Provider Metrics', style: AppTextStyles.h4(p.textPrimary)),
                                    const SizedBox(height: 16),
                                    if (controller.isGraphLoading.value)
                                      const Expanded(child: Center(child: LoadingIndicator()))
                                    else if (controller.graphError.value != null)
                                      Expanded(child: Text(controller.graphError.value!, style: const TextStyle(color: Colors.red)))
                                    else if (controller.graphSeries.isEmpty)
                                      const Expanded(child: Text('No data available'))
                                    else
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            gridData: const FlGridData(show: false),
                                            titlesData: const FlTitlesData(show: false),
                                            borderData: FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4)],
                                                isCurved: true,
                                                color: AppColors.lime500,
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: const FlDotData(show: false),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Clients container
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: p.bgSurface,
                                  border: Border.all(color: p.border),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Active Usage by Clients', style: AppTextStyles.h4(p.textPrimary)),
                                    const SizedBox(height: 16),
                                    if (controller.isLoadingClients.value)
                                      const Expanded(child: Center(child: LoadingIndicator()))
                                    else if (controller.providerClients.isEmpty)
                                      Expanded(child: Center(child: Text('No client is using your providers.', style: AppTextStyles.body(p.textMuted))))
                                    else
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: controller.providerClients.length,
                                          itemBuilder: (_, i) {
                                            final c = controller.providerClients[i];
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8, height: 8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: c['status'] == true ? AppColors.lime500 : AppColors.red500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(c['clientName'] ?? c['clientId'] ?? '', style: AppTextStyles.body(p.textPrimary)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildDropdown(String label, RxString rxValue, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Obx(() {
          return DropdownButtonFormField<String>(
            value: rxValue.value.isEmpty ? null : rxValue.value,
            hint: const Text('Select'),
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => rxValue.value = v ?? '',
          );
        }),
      ],
    );
  }
}
