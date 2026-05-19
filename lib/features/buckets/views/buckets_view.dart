import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/app_table.dart';

import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../controllers/buckets_controller.dart';

class BucketsView extends GetView<BucketsController> {
  const BucketsView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Storage / Buckets', style: AppTextStyles.h2(p.textPrimary)),
      const SizedBox(height: 12),
      // Path bar
      Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          InkWell(onTap: () { controller.currentPath.value = '/'; controller.pathParts.clear(); controller.fetchFiles(); }, child: Icon(Icons.home, size: 18, color: p.textMuted)),
          ...controller.pathParts.asMap().entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.chevron_right, size: 16, color: p.textMuted),
            InkWell(onTap: () => controller.navigateToIndex(e.key), child: Text(e.value, style: AppTextStyles.bodyMedium(AppColors.lime600))),
          ])),
        ]))),
      const SizedBox(height: 12),
      // Toolbar
      Wrap(spacing: 8, children: [
        _toolBtn(Icons.create_new_folder_outlined, 'New Folder', () => _showMkdir(context, p), p),
        _toolBtn(Icons.upload_file, 'Upload', () async { final r = await controller.uploadFiles(); if (context.mounted && r != null) AppToast.success(context, r); }, p),
        Obx(() => controller.selectedFiles.isNotEmpty ? _toolBtn(Icons.delete_outline, 'Delete (${controller.selectedFiles.length})', () => ActionConfirmModal.show(context, message: 'Delete selected files?', onConfirm: () async { final r = await controller.deleteFiles(); if (context.mounted) AppToast.info(context, r ?? 'Done'); }), p, color: AppColors.red500) : const SizedBox()),
      ]),
      const SizedBox(height: 12),
      // File table
      Expanded(child: Obx(() => AppTable<Map<String, dynamic>>(
        columns: [
          AppTableColumn(header: '', width: 40, cell: (r, _) {
            if (r['type'] == 'directory') return const SizedBox();
            return Obx(() => Checkbox(value: controller.selectedFiles.contains(r['name']), onChanged: (_) => controller.toggleSelect(r['name']), activeColor: AppColors.lime500));
          }),
          AppTableColumn(header: 'Name', cell: (r, _) => Row(children: [
            Icon(r['type'] == 'directory' ? Icons.folder : Icons.insert_drive_file, size: 18, color: r['type'] == 'directory' ? AppColors.lime500 : p.textMuted),
            const SizedBox(width: 8),
            Text(r['name'] ?? '', style: AppTextStyles.body(p.textPrimary)),
          ])),
          AppTableColumn(header: 'Size', cell: (r, _) => Text(r['size']?.toString() ?? '-', style: AppTextStyles.bodySmall(p.textMuted)), width: 100),
          AppTableColumn(header: 'Actions', width: 60, cell: (r, _) => r['type'] == 'directory' ? const SizedBox() : InkWell(onTap: () => _showRename(context, p, r['name'] ?? ''), child: Icon(Icons.edit, size: 14, color: p.textMuted))),
        ],
        data: controller.files,
        isLoading: controller.isLoading.value,
        emptyMessage: 'This directory is empty',
        onRowClick: (r, _) { if (r['type'] == 'directory') controller.navigateToDir(r['name']); },
      ))),
    ])));
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap, AppPalette p, {Color? color}) {
    return OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 16, color: color), label: Text(label, style: TextStyle(color: color)));
  }

  void _showMkdir(BuildContext context, AppPalette p) {
    String name = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Create Folder'),
      content: TextField(onChanged: (v) => name = v, decoration: const InputDecoration(hintText: 'Folder Name')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () async { Navigator.pop(ctx); if (name.isNotEmpty) { final r = await controller.createDirectory(name); if (context.mounted) AppToast.success(context, r ?? 'Created'); } }, child: const Text('Create'))],
    ));
  }

  void _showRename(BuildContext context, AppPalette p, String oldName) {
    String newName = oldName;
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Rename'),
      content: TextField(onChanged: (v) => newName = v, controller: TextEditingController(text: oldName)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () async { Navigator.pop(ctx); final r = await controller.renameFile(oldName, newName); if (context.mounted) AppToast.success(context, r ?? 'Renamed'); }, child: const Text('Rename'))],
    ));
  }
}
