import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const AppDropdown({super.key, this.label, this.value, required this.items, required this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      if (label != null) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(label!, style: AppTextStyles.label(p.textSecondary))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(value: value, items: items, onChanged: enabled ? onChanged : null, isExpanded: true, dropdownColor: p.bgSurface, style: AppTextStyles.body(p.textPrimary), icon: Icon(Icons.expand_more, size: 18, color: p.textMuted)),
        ),
      ),
    ]);
  }
}
