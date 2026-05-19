import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/action_confirm_modal.dart';
import '../controllers/dashboard_controller.dart';

class DashboardListView extends GetView<DashboardController> {
  const DashboardListView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Analytics', style: AppTextStyles.h2(p.textPrimary)),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => _showCreate(context, p), icon: const Icon(Icons.add, size: 16), label: const Text('Create Dashboard')),
      ]),
      const SizedBox(height: 20),
      Expanded(child: Obx(() {
        if (controller.isLoading.value) return const Center(child: LoadingIndicator());
        if (controller.dashboards.isEmpty) return Center(child: Text('No dashboards yet. Create one!', style: AppTextStyles.body(p.textMuted)));
        return GridView.builder(gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 140),
          itemCount: controller.dashboards.length, itemBuilder: (_, i) => _DashboardCard(dashboard: controller.dashboards[i], palette: p, controller: controller));
      })),
    ])));
  }

  void _showCreate(BuildContext context, AppPalette p) {
    String name = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Create Dashboard'), content: TextField(onChanged: (v) => name = v, decoration: const InputDecoration(hintText: 'Dashboard Name')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () async { Navigator.pop(ctx); if (name.isNotEmpty) { final r = await controller.createDashboard(name); if (context.mounted) AppToast.success(context, r ?? 'Created'); } }, child: const Text('Create'))],
    ));
  }
}

class _DashboardCard extends StatefulWidget {
  final Map<String, dynamic> dashboard; final AppPalette palette; final DashboardController controller;
  const _DashboardCard({required this.dashboard, required this.palette, required this.controller});
  @override State<_DashboardCard> createState() => _DashboardCardState();
}
class _DashboardCardState extends State<_DashboardCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
      child: GestureDetector(onTap: () => widget.controller.openDashboard(widget.dashboard['dashboardId']),
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: widget.palette.bgSurface, border: Border.all(color: _h ? AppColors.lime400 : widget.palette.border), borderRadius: BorderRadius.circular(12), boxShadow: _h ? [BoxShadow(color: AppColors.lime400.withValues(alpha: 0.1), blurRadius: 12)] : null),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.dashboard_outlined, size: 20, color: AppColors.lime500), const SizedBox(width: 8), Expanded(child: Text(widget.dashboard['dashboardName'] ?? '', style: AppTextStyles.h4(widget.palette.textPrimary), overflow: TextOverflow.ellipsis))]),
            const Spacer(),
            Row(children: [
              Text('View →', style: AppTextStyles.bodySemibold(AppColors.lime600)),
              const Spacer(),
              InkWell(onTap: () => ActionConfirmModal.show(context, message: 'Delete this dashboard?', onConfirm: () async { final r = await widget.controller.deleteDashboard(widget.dashboard['dashboardId']); if (context.mounted) AppToast.info(context, r ?? 'Deleted'); }), child: Icon(Icons.delete_outline, size: 18, color: widget.palette.textMuted)),
            ]),
          ]))));
  }
}
