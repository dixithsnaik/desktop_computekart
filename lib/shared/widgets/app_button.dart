import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const AppButton({super.key, required this.label, this.onPressed, this.variant = AppButtonVariant.primary, this.icon, this.loading = false, this.expand = false});

  @override State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  Color get _bg { switch (widget.variant) { case AppButtonVariant.primary: return _hovered ? AppColors.lime500 : AppColors.lime400; case AppButtonVariant.secondary: return Colors.transparent; case AppButtonVariant.danger: return _hovered ? AppColors.red600 : AppColors.red500; case AppButtonVariant.ghost: return Colors.transparent; } }
  Color get _fg { switch (widget.variant) { case AppButtonVariant.primary: return Colors.black; case AppButtonVariant.secondary: return AppColors.lightTextPrimary; case AppButtonVariant.danger: return Colors.white; case AppButtonVariant.ghost: return AppColors.lightTextPrimary; } }
  Border? get _border { if (widget.variant == AppButtonVariant.secondary) return Border.all(color: AppColors.lightBorder); return null; }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    return MouseRegion(onEnter: (_) => setState(() => _hovered = true), onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: disabled ? null : widget.onPressed,
        child: AnimatedContainer(duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: disabled ? _bg.withValues(alpha: 0.5) : _bg, border: _border, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.loading) ...[SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _fg)), const SizedBox(width: 8)]
            else if (widget.icon != null) ...[Icon(widget.icon, size: 16, color: _fg), const SizedBox(width: 6)],
            Text(widget.label, style: AppTextStyles.button(_fg)),
          ]),
        )));
  }
}
