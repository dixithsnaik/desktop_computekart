import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/search_input.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/app_provider_card.dart';
import '../controllers/providers_controller.dart';

class ProvidersView extends GetView<ProvidersController> {
  const ProvidersView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Providers', style: AppTextStyles.h2(p.textPrimary)),
      const SizedBox(height: 16),
      Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left
        SizedBox(width: 360, child: Column(children: [
          Obx(() => SearchInput(value: controller.searchInput.value, onChanged: (v) => controller.searchInput.value = v, hint: 'Search by Provider Name')),
          Expanded(child: Obx(() {
            if (controller.isLoading.value) return const LoadingIndicator();
            return ListView.builder(itemCount: controller.providers.length, itemBuilder: (_, i) {
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
            });
          })),
        ])),
        const SizedBox(width: 24),
        // Right
        Expanded(child: Obx(() {
          final sp = controller.selectedProvider.value;
          if (sp == null) return Center(child: Text('Select a provider to see details.', style: AppTextStyles.body(p.textMuted)));
          return _VMConfigForm(controller: controller, palette: p);
        })),
      ])),
    ])));
  }
}

class _VMConfigForm extends StatelessWidget {
  final ProvidersController controller; final AppPalette palette;
  const _VMConfigForm({required this.controller, required this.palette});
  @override
  Widget build(BuildContext context) {
    final sp = controller.selectedProvider.value!;
    final vcpus = [2, 4, 8, 16, 32, 64]; final rams = [2048, 4096, 8192, 16384, 32768, 65536]; final images = ['linux']; final storage = [2, 5, 10, 20, 50, 100, 200, 500, 1000];
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(sp['providerName'] ?? '', style: AppTextStyles.h3(palette.textPrimary)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: palette.bgSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: palette.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field('VM Name', 'vm_name', controller, palette),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _dropdown('vCPUs', 'vcpus', vcpus.map((v) => DropdownMenuItem(value: v.toString(), child: Text('$v'))).toList(), controller, palette)),
            const SizedBox(width: 12),
            Expanded(child: _dropdown('RAM', 'ram', rams.map((v) => DropdownMenuItem(value: v.toString(), child: Text('${v ~/ 1024} GB'))).toList(), controller, palette)),
            const SizedBox(width: 12),
            Expanded(child: _dropdown('Storage', 'storage', storage.map((v) => DropdownMenuItem(value: v.toString(), child: Text('$v GB'))).toList(), controller, palette)),
          ]),
          const SizedBox(height: 12),
          _dropdown('Image', 'vm_image', images.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), controller, palette),
          const SizedBox(height: 16),
          Row(children: [
            ElevatedButton(onPressed: () async { final r = await controller.queryVM(); if (context.mounted && r != null) AppToast.info(context, r); }, child: const Text('Query VM')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () async { final r = await controller.requestVM(); if (context.mounted && r != null) AppToast.success(context, r); }, child: const Text('Request VM')),
          ]),
          const SizedBox(height: 12),
          _field('Remarks', 'remarks', controller, palette),
        ])),
    ]));
  }

  Widget _field(String label, String key, ProvidersController c, AppPalette p) {
    return Obx(() => TextField(onChanged: (v) => c.updateField(key, v), controller: TextEditingController(text: c.formData[key]?.toString() ?? ''),
      style: AppTextStyles.body(p.textPrimary), decoration: InputDecoration(hintText: label)));
  }

  Widget _dropdown(String label, String key, List<DropdownMenuItem<String>> items, ProvidersController c, AppPalette p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label(p.textSecondary)),
      const SizedBox(height: 4),
      Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: p.border), borderRadius: BorderRadius.circular(8), color: p.bgSurface),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: c.formData[key]?.toString().isEmpty ?? true ? null : c.formData[key]?.toString(), items: [DropdownMenuItem(value: '', child: Text('Select', style: AppTextStyles.body(p.textMuted))), ...items], onChanged: (v) => c.updateField(key, v), isExpanded: true, dropdownColor: p.bgSurface, style: AppTextStyles.body(p.textPrimary)))))
    ]);
  }
}
