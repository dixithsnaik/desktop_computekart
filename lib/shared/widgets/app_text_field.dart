import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;

  const AppTextField({super.key, this.label, this.hint, required this.value, required this.onChanged, this.readOnly = false, this.obscure = false, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      if (label != null) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(label!, style: AppTextStyles.label(p.textSecondary))),
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        readOnly: readOnly,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: AppTextStyles.body(p.textPrimary),
        decoration: InputDecoration(hintText: hint, filled: true, fillColor: p.bgSurface, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: p.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.lime500, width: 1.5))),
      ),
    ]);
  }
}
