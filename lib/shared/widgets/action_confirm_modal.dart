import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ActionConfirmModal extends StatelessWidget {
  final String message;
  final String? command;
  final bool showCopyToken;
  final bool showConfirm;
  final bool showCancel;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onRunHere;

  const ActionConfirmModal({super.key, required this.message, this.command, this.showCopyToken = false, this.showConfirm = true, this.showCancel = true, this.confirmLabel = 'Yes, Confirm', this.cancelLabel = 'Cancel', this.onConfirm, this.onCancel, this.onRunHere});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return Dialog(
      backgroundColor: p.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 700),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, style: AppTextStyles.h4(p.textPrimary), textAlign: TextAlign.center),
          if (showCopyToken && command != null) ...[
            const SizedBox(height: 16),
            _CopyBlock(command: command!, palette: p),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (onRunHere != null) ElevatedButton.icon(onPressed: () { Navigator.of(context).pop(); onRunHere?.call(); }, icon: const Icon(Icons.play_arrow, size: 16), label: const Text('Run it here'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime500, foregroundColor: Colors.white)),
            if (onRunHere != null && showConfirm) const SizedBox(width: 12),
            if (showConfirm) ElevatedButton(onPressed: () { Navigator.of(context).pop(); onConfirm?.call(); }, style: ElevatedButton.styleFrom(backgroundColor: onRunHere != null ? Colors.transparent : AppColors.lime500, foregroundColor: onRunHere != null ? AppColors.lime500 : Colors.white, side: onRunHere != null ? BorderSide(color: AppColors.lime500) : BorderSide.none, elevation: onRunHere != null ? 0 : null), child: Text(confirmLabel)),
            if ((showConfirm || onRunHere != null) && showCancel) const SizedBox(width: 12),
            if (showCancel) OutlinedButton(onPressed: () { Navigator.of(context).pop(); onCancel?.call(); }, child: Text(cancelLabel)),
          ]),
        ]),
      ),
    );
  }

  static Future<void> show(BuildContext context, {required String message, String? command, bool showCopyToken = false, bool showConfirm = true, bool showCancel = true, String confirmLabel = 'Yes, Confirm', String cancelLabel = 'Cancel', VoidCallback? onConfirm, VoidCallback? onCancel, VoidCallback? onRunHere}) {
    return showDialog(context: context, barrierColor: Colors.black54, builder: (_) => ActionConfirmModal(message: message, command: command, showCopyToken: showCopyToken, showConfirm: showConfirm, showCancel: showCancel, confirmLabel: confirmLabel, cancelLabel: cancelLabel, onConfirm: onConfirm, onCancel: onCancel, onRunHere: onRunHere));
  }
}

class _CopyBlock extends StatefulWidget {
  final String command;
  final AppPalette palette;
  const _CopyBlock({required this.command, required this.palette});
  @override State<_CopyBlock> createState() => _CopyBlockState();
}

class _CopyBlockState extends State<_CopyBlock> {
  bool _copied = false;
  void _copy() { Clipboard.setData(ClipboardData(text: widget.command)); setState(() => _copied = true); Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); }); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: widget.palette.bgSurface, border: Border.all(color: widget.palette.border), borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: SelectableText(widget.command, style: AppTextStyles.mono(widget.palette.textPrimary))),
        const SizedBox(width: 8),
        InkWell(onTap: _copy, borderRadius: BorderRadius.circular(6), child: Padding(padding: const EdgeInsets.all(4), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_copied ? Icons.check : Icons.copy, size: 16, color: _copied ? AppColors.greenFocus : widget.palette.textSecondary), const SizedBox(width: 4), Text(_copied ? 'Copied' : 'Copy', style: AppTextStyles.caption(_copied ? AppColors.greenFocus : widget.palette.textSecondary))]))),
      ]),
    );
  }
}
