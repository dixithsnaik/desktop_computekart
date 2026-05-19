import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SearchInput extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  const SearchInput({super.key, this.hint = 'Search...', required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.body(p.textPrimary),
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(Icons.search, size: 18, color: p.textMuted),
          filled: true, fillColor: p.bgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.lime500, width: 1.5)),
        ),
      ),
    );
  }
}
