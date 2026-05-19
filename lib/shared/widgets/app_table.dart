import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'loading_indicator.dart';

class AppTableColumn<T> {
  final String header;
  final String? accessor;
  final Widget Function(T row, int index)? cell;
  final double? width;
  const AppTableColumn({required this.header, this.accessor, this.cell, this.width});
}

class AppTable<T> extends StatelessWidget {
  final List<AppTableColumn<T>> columns;
  final List<T> data;
  final bool isLoading;
  final String emptyMessage;
  final void Function(T row, int index)? onRowClick;
  final bool Function(T row)? isRowSelected;

  const AppTable({super.key, required this.columns, required this.data, this.isLoading = false, this.emptyMessage = 'No data available', this.onRowClick, this.isRowSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    if (isLoading) return const Padding(padding: EdgeInsets.all(32), child: LoadingIndicator());

    return Container(
      decoration: BoxDecoration(color: p.bgSurface, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(color: p.bgSurfaceMuted, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: columns.map((c) => c.width != null ? SizedBox(width: c.width, child: Text(c.header.toUpperCase(), style: AppTextStyles.labelUppercase(p.textSecondary))) : Expanded(child: Text(c.header.toUpperCase(), style: AppTextStyles.labelUppercase(p.textSecondary)))).toList())),
        if (data.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(emptyMessage, style: AppTextStyles.body(p.textMuted).copyWith(fontStyle: FontStyle.italic)))
        else ...data.asMap().entries.map((e) => _Row<T>(row: e.value, idx: e.key, columns: columns, p: p, isDark: isDark, selected: isRowSelected?.call(e.value) ?? false, onTap: onRowClick != null ? () => onRowClick!(e.value, e.key) : null, border: e.key < data.length - 1)),
      ]),
    );
  }
}

class _Row<T> extends StatefulWidget {
  final T row; final int idx; final List<AppTableColumn<T>> columns; final AppPalette p; final bool isDark, selected, border; final VoidCallback? onTap;
  const _Row({required this.row, required this.idx, required this.columns, required this.p, required this.isDark, required this.selected, this.onTap, this.border = true});
  @override State<_Row<T>> createState() => _RowS<T>();
}

class _RowS<T> extends State<_Row<T>> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false), cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(color: widget.selected ? (widget.isDark ? widget.p.bgWrapper : AppColors.lime100) : _h ? (widget.isDark ? widget.p.bgWrapper : AppColors.lime200.withValues(alpha: 0.3)) : Colors.transparent, border: widget.border ? Border(bottom: BorderSide(color: widget.p.border, width: 0.5)) : null),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: widget.columns.map((c) { final ch = c.cell != null ? c.cell!(widget.row, widget.idx) : Text(_val(widget.row, c.accessor), style: AppTextStyles.body(widget.p.textPrimary)); return c.width != null ? SizedBox(width: c.width, child: ch) : Expanded(child: ch); }).toList()),
        )));
  }
  String _val(T r, String? a) { if (a == null) return ''; try { final m = r as dynamic; return (m is Map ? m[a] : '')?.toString() ?? ''; } catch(_) { return ''; } }
}
