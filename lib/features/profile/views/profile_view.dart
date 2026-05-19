import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_provider_card.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Obx(() {
      if (controller.isLoading.value) return const Center(child: LoadingIndicator());
      final u = controller.user.value ?? {};
      return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Profile', style: AppTextStyles.h2(p.textPrimary)),
        const SizedBox(height: 20),
        // Header card
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: u['profileImage'] != null && (u['profileImage'] as String).isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(u['profileImage'], fit: BoxFit.cover, width: 80, height: 80, errorBuilder: (ctx, err, st) => _initials(u)))
                : _initials(u)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(u['profileName'] ?? u['username'] ?? '', style: AppTextStyles.h3(p.textPrimary)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.lime200, borderRadius: BorderRadius.circular(6)), child: Text('Provider', style: AppTextStyles.caption(AppColors.greenDark).copyWith(fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 4),
              Text(u['email'] ?? '', style: AppTextStyles.body(p.textMuted)),
            ])),
          ])),
        const SizedBox(height: 20),
        // Tabs
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _tab('Projects', controller.isProvider.value, () => controller.isProvider.value = true, p),
              const SizedBox(width: 24),
              _tab('Clients', !controller.isProvider.value, () => controller.isProvider.value = false, p),
            ]),
            const SizedBox(height: 16),
            Obx(() => controller.isProvider.value ? _providerGrid(p) : _clientGrid(p)),
          ])),
      ]));
    }));
  }

  Widget _initials(Map u) => Center(child: Text(Helpers.getInitials(u['profileName'] ?? u['username']), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)));

  Widget _tab(String label, bool active, VoidCallback onTap, AppPalette p) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? AppColors.lime500 : Colors.transparent, width: 2))),
      child: Text(label, style: AppTextStyles.bodySemibold(active ? p.textPrimary : p.textMuted))));
  }

  Widget _providerGrid(AppPalette p) {
    if (controller.providers.isEmpty) return Text('No providers', style: AppTextStyles.body(p.textMuted));
    final isDark = p.isDark;
    return Wrap(
      spacing: 16, 
      runSpacing: 16, 
      children: controller.providers.map((prov) => SizedBox(
        width: 380,
        height: 280,
        child: AppProviderCard(
          provider: prov, 
          palette: p,
          isDark: isDark,
        ),
      )).toList()
    );
  }

  Widget _clientGrid(AppPalette p) {
    if (controller.clients.isEmpty) return Text('No clients', style: AppTextStyles.body(p.textMuted));
    return Wrap(spacing: 12, runSpacing: 12, children: controller.clients.map((c) => Container(width: 280, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c['cli_id'] ?? '', style: AppTextStyles.h4(p.textPrimary)),
        const SizedBox(height: 6),
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c['cli_status'] == true ? AppColors.lime500 : AppColors.red500)),
          const SizedBox(width: 6),
          Text(c['cli_status'] == true ? 'Active' : 'Inactive', style: AppTextStyles.bodySmall(c['cli_status'] == true ? AppColors.lime600 : AppColors.red500)),
        ]),
      ]))).toList());
  }
}
