import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/search_input.dart';
import '../../../shared/widgets/app_table.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../controllers/client_services_controller.dart';

class ClientServicesView extends GetView<ClientServicesController> {
  const ClientServicesView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('VM Instances', style: AppTextStyles.h2(p.textPrimary)),
      const SizedBox(height: 16),
      Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: Column(children: [
          Obx(() => SearchInput(value: controller.searchInput.value, onChanged: (v) => controller.searchInput.value = v, hint: 'Search by VM Name')),
          Expanded(child: Obx(() => AppTable<Map<String, dynamic>>(
            columns: [
              AppTableColumn(header: 'Provider', cell: (r, _) => Text(r['providerId']?.toString() ?? 'N/A', style: AppTextStyles.mono(p.textPrimary))),
              AppTableColumn(header: 'VM Name', cell: (r, _) => Text(r['vmName'] ?? '', style: AppTextStyles.body(p.textPrimary))),
              AppTableColumn(header: 'Status', cell: (r, _) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: r['status'] == 'active' ? AppColors.lime600 : p.textMuted)), const SizedBox(width: 6), Text(r['status'] == 'active' ? 'Active' : 'Inactive', style: AppTextStyles.bodySmall(r['status'] == 'active' ? AppColors.lime600 : p.textMuted))])),
            ],
            data: controller.activeVms,
            isLoading: controller.isLoadingList.value,
            emptyMessage: 'No VMs available',
            onRowClick: (r, _) => controller.selectVM(r),
            isRowSelected: (r) => controller.selectedVM.value?['internalVmName'] == r['internalVmName'],
          ))),
        ])),
        const SizedBox(width: 20),
        SizedBox(width: 350, child: _DetailPanel(controller: controller, palette: p, context: context)),
      ])),
    ])));
  }
}

class _DetailPanel extends StatelessWidget {
  final ClientServicesController controller; final AppPalette palette; final BuildContext context;
  const _DetailPanel({required this.controller, required this.palette, required this.context});
  @override
  Widget build(BuildContext _) {
    return Obx(() {
      final vm = controller.selectedVM.value;
      return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: palette.bgSurface, border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(10)),
        child: vm == null
          ? Center(child: Text('Select a VM to see its details', style: AppTextStyles.body(palette.textMuted).copyWith(fontStyle: FontStyle.italic)))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Text('VM Details', style: AppTextStyles.h4(palette.textPrimary))),
              Divider(color: palette.border), const SizedBox(height: 8),
              if (controller.isLoadingAction.value) const LoadingIndicator(),
              if (vm['vcpus'] != null) _row('vCPUs', '${vm['vcpus']} vCPUs'),
              if (vm['ram'] != null) _row('RAM', '${(int.tryParse(vm['ram'].toString()) ?? 0) ~/ 1024} GB'),
              if (vm['storage'] != null) _row('Storage', '${(int.tryParse(vm['storage'].toString()) ?? 0) ~/ 1024} GB'),
              const SizedBox(height: 12),
              if (vm['wireguard_ip'] != null) ...[
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: palette.bgWrapper, borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _mono('WG IP', vm['wireguard_ip']),
                    _mono('WG Pubkey', vm['wireguard_public_key']),
                    _mono('WG Endpoint', vm['wireguard_endpoint']),
                  ])),
                const SizedBox(height: 12),
              ],
              Row(children: [
                _actionBtn('Start', AppColors.lime600, vm['status'] != 'active', () => _doAction('start')),
                const SizedBox(width: 8),
                _actionBtn('Stop', AppColors.blue600, vm['status'] == 'active', () => _doAction('stop')),
                const SizedBox(width: 8),
                _actionBtn('Delete', AppColors.red600, vm['status'] != 'active', () => _doAction('delete')),
              ]),
            ]));
    });
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text(label, style: AppTextStyles.bodyMedium(palette.textSecondary))), Text(value, style: AppTextStyles.bodyMedium(palette.textPrimary))]));
  Widget _mono(String label, String? value) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTextStyles.labelUppercase(palette.textMuted)), Text(value ?? '', style: AppTextStyles.monoSmall(palette.textPrimary))]));

  Widget _actionBtn(String label, Color color, bool enabled, VoidCallback onTap) => Expanded(child: ElevatedButton(
    onPressed: enabled ? onTap : null,
    style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, disabledBackgroundColor: color.withValues(alpha: 0.3)),
    child: Text(label, style: const TextStyle(fontSize: 12))));

  void _doAction(String type) {
    ActionConfirmModal.show(context, message: 'Are you sure you want to $type this VM?', onConfirm: () async {
      final msg = await controller.vmAction(type);
      if (context.mounted) AppToast.info(context, msg);
    });
  }
}
