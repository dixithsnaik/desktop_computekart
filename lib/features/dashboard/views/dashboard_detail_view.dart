import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/desktop_layout.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_toast.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_create_modal.dart';

class DashboardDetailView extends GetView<DashboardController> {
  const DashboardDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette(isDark: isDark);
    return DesktopLayout(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        InkWell(onTap: () => Get.back(), child: Icon(Icons.arrow_back, size: 20, color: p.textMuted)),
        const SizedBox(width: 12),
        Text('Dashboard', style: AppTextStyles.h2(p.textPrimary)),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => _showCreateGraph(context, p), icon: const Icon(Icons.add, size: 16), label: const Text('Add Graph')),
      ]),
      const SizedBox(height: 20),
      Expanded(child: Obx(() {
        if (controller.isLoadingGraphs.value) return const Center(child: LoadingIndicator());
        if (controller.graphs.isEmpty) return Center(child: Text('No graphs yet. Add one!', style: AppTextStyles.body(p.textMuted)));
        return GridView.builder(gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 600, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 400),
          itemCount: controller.graphs.length, itemBuilder: (_, i) => _GraphCard(graph: controller.graphs[i], palette: p, controller: controller, isDark: isDark));
      })),
    ])));
  }

  void _showCreateGraph(BuildContext context, AppPalette p) {
    showDialog(
      context: context,
      builder: (ctx) => DashboardCreateModal(palette: p),
    );
  }
}

class _GraphCard extends StatelessWidget {
  final Map<String, dynamic> graph; final AppPalette palette; final DashboardController controller; final bool isDark;
  const _GraphCard({required this.graph, required this.palette, required this.controller, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final graphId = graph['graphId'];
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: palette.bgSurface, border: Border.all(color: AppColors.lime300), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(graph['graphName'] ?? 'Untitled', style: AppTextStyles.h4(palette.textPrimary))),
          InkWell(onTap: () async { final r = await controller.deleteGraph(graphId); if (context.mounted) AppToast.info(context, r ?? 'Deleted'); }, child: Icon(Icons.delete_outline, size: 16, color: palette.textMuted)),
        ]),
        const SizedBox(height: 8),
        Expanded(child: Obx(() {
          final data = controller.graphDataMap[graphId];
          if (data == null) return const Center(child: LoadingIndicator(size: 24));
          return _buildChart(data, palette, isDark);
        })),
      ]));
  }

  Widget _buildChart(dynamic data, AppPalette p, bool isDark) {
    final series = data['series'] as List? ?? [];
    if (series.isEmpty) return Center(child: Text('No data', style: AppTextStyles.body(p.textMuted).copyWith(fontStyle: FontStyle.italic)));

    final allSpots = <int, List<FlSpot>>{};
    double minX = double.maxFinite;
    double maxX = -double.maxFinite;

    double minY = double.maxFinite;
    double maxY = -double.maxFinite;

    for (int si = 0; si < series.length; si++) {
      final points = series[si]['data'] as List? ?? [];
      allSpots[si] = points.map<FlSpot?>((e) {
        if (e is List && e.length > 1) {
          final tStr = e[0].toString();
          double ts = 0;
          final maybeDouble = double.tryParse(tStr);
          if (maybeDouble != null) {
            ts = maybeDouble;
          } else {
            final dt = DateTime.tryParse(tStr);
            if (dt != null) ts = dt.millisecondsSinceEpoch / 1000.0;
          }
          final val = double.tryParse(e[1].toString()) ?? 0;
          if (ts < minX) minX = ts;
          if (ts > maxX) maxX = ts;
          if (val < minY) minY = val;
          if (val > maxY) maxY = val;
          return FlSpot(ts, val);
        }
        return null;
      }).whereType<FlSpot>().toList();
      // sort spots by x
      allSpots[si]?.sort((a, b) => a.x.compareTo(b.x));
    }

    if (minX >= maxX) {
      minX -= 1;
      maxX += 1;
    }
    
    double yRange = maxY - minY;
    if (yRange == 0) {
      yRange = maxY == 0 ? 2 : maxY.abs(); 
    }
    minY -= yRange * 0.15;
    maxY += yRange * 0.15;

    final validSpots = allSpots.entries.where((e) => e.value.isNotEmpty).toList();
    if (validSpots.isEmpty) {
      return Center(child: Text('No data points in this range', style: AppTextStyles.body(p.textMuted).copyWith(fontStyle: FontStyle.italic)));
    }

    return LineChart(LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 0.5), drawVerticalLine: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (maxX - minX) > 0 ? (maxX - minX) / 5 : 1,
            getTitlesWidget: (value, meta) {
              final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}', style: AppTextStyles.bodySmall(p.textMuted)),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => p.bgSurfaceMuted,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot spot) {
              final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt() * 1000);
              final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              return LineTooltipItem(
                '$timeStr\n${spot.y}',
                TextStyle(color: spot.bar.color ?? Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: validSpots.map((e) => LineChartBarData(
        spots: e.value,
        isCurved: true,
        color: AppColors.chartColors[e.key % AppColors.chartColors.length],
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, color: AppColors.chartColors[e.key % AppColors.chartColors.length].withValues(alpha: 0.1))
      )).toList(),
    ));
  }
}
