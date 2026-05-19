import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/app_table.dart';

import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../controllers/tunnels_controller.dart';

class TunnelsView extends GetView<TunnelsController> {
  const TunnelsView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('Tunnels', style: AppTextStyles.h2(p.textPrimary)), const Spacer(),
        ElevatedButton.icon(onPressed: () => _showCreate(context, p), icon: const Icon(Icons.add, size: 16), label: const Text('Create Tunnel'))]),
      const SizedBox(height: 20),
      Expanded(child: Obx(() => AppTable<Map<String, dynamic>>(
        columns: [
          AppTableColumn(header: 'Tunnel No', cell: (r, _) => Text('${r['tunnelNo'] ?? '-'}', style: AppTextStyles.body(p.textPrimary)), width: 100),
          AppTableColumn(header: 'Tunnel Name', cell: (r, _) => Text(r['tunnelName'] ?? '-', style: AppTextStyles.body(p.textPrimary))),
          AppTableColumn(header: 'URL', cell: (r, _) {
            final url = 'https://${r['tunnelNo']}-${r['username']}.computekart.com';
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(child: SelectableText(url, style: AppTextStyles.mono(AppColors.lime600))),
              const SizedBox(width: 4),
              InkWell(onTap: () { Clipboard.setData(ClipboardData(text: url)); AppToast.success(context, 'URL copied'); }, child: Icon(Icons.copy, size: 12, color: AppColors.lime600)),
            ]);
          }),
          AppTableColumn(header: 'Token', cell: (r, _) => InkWell(onTap: () { Clipboard.setData(ClipboardData(text: r['tunnelToken'] ?? '')); AppToast.success(context, 'Token copied'); }, child: Row(mainAxisSize: MainAxisSize.min, children: [Expanded(child: Text(r['tunnelToken'] ?? '', style: AppTextStyles.mono(p.textPrimary), overflow: TextOverflow.ellipsis)), const SizedBox(width: 4), Icon(Icons.copy, size: 12, color: AppColors.lime600)])), width: 180),
          AppTableColumn(header: 'Actions', width: 80, cell: (r, _) => Row(mainAxisSize: MainAxisSize.min, children: [
            InkWell(onTap: () => _showEdit(context, p, r), child: Icon(Icons.edit, size: 16, color: AppColors.blue500)),
            const SizedBox(width: 8),
            InkWell(onTap: () => ActionConfirmModal.show(context, message: 'Delete this tunnel?', onConfirm: () async { final res = await controller.deleteTunnel(r['tunnelId']); if (context.mounted) AppToast.info(context, res ?? 'Deleted'); }), child: Icon(Icons.delete, size: 16, color: AppColors.red500)),
          ])),
        ],
        data: controller.tunnels,
        isLoading: controller.isLoading.value,
        emptyMessage: 'No tunnels yet',
      ))),
    ])));
  }

  void _showCreate(BuildContext context, AppPalette p) {
    String name = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Create Tunnel'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(onChanged: (v) => name = v, decoration: const InputDecoration(hintText: 'Tunnel Name')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async { Navigator.pop(ctx); final r = await controller.createTunnel(tunnelName: name); if (context.mounted) AppToast.success(context, r ?? 'Created'); }, child: const Text('Create'))],
    ));
  }

  void _showEdit(BuildContext context, AppPalette p, Map<String, dynamic> tunnel) {
    String name = tunnel['tunnelName'] ?? '';
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Edit Tunnel'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(onChanged: (v) => name = v, decoration: const InputDecoration(hintText: 'Tunnel Name'), controller: TextEditingController(text: name)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async { Navigator.pop(ctx); final r = await controller.editTunnel(tunnelId: tunnel['tunnelId'], tunnelName: name); if (context.mounted) AppToast.success(context, r ?? 'Updated'); }, child: const Text('Save'))],
    ));
  }
}
