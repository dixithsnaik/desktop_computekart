import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_toast.dart';
import '../controllers/dashboard_controller.dart';

class DashboardCreateModal extends StatefulWidget {
  final AppPalette palette;
  const DashboardCreateModal({super.key, required this.palette});

  @override
  State<DashboardCreateModal> createState() => _DashboardCreateModalState();
}

class _DashboardCreateModalState extends State<DashboardCreateModal> {
  final _controller = Get.find<DashboardController>();

  String graphName = '';
  String graphType = 'time_series';
  int defaultTimeRange = 60;
  int refreshIntervalSeconds = 30;

  final List<Map<String, dynamic>> seriesList = [];

  @override
  void initState() {
    super.initState();
    _controller.fetchEntityOptions().then((_) {
      if (mounted) {
        setState(() {
          _addSeries();
        });
      }
    });
  }

  void _addSeries() {
    final hisVms = _controller.entityOptions['hisVms'] as List? ?? [];
    final providerIds = hisVms.map((v) => v['provider_id']).toSet().toList();

    seriesList.add({
      'entityType': 'vm',
      'metricName': '',
      'aggregation': 'sum',
      'filters': {
        'provider_id': providerIds,
        'entity_name': 'all_vms',
      },
      'yAxisPosition': 'left',
    });
  }

  void _removeSeries(int idx) {
    setState(() {
      seriesList.removeAt(idx);
    });
  }

  List<String> _getMetricsFor(String type) {
    if (type == 'vm') {
      return ['vm_cpu_used', 'vm_ram_allocated', 'vm_cpu_allocated', 'vm_ram_used', 'vm_state'];
    } else if (type == 'provider') {
      return ['active_vms', 'inactive_vms', 'provider_heartbeat'];
    }
    return [];
  }

  void _submit() async {
    if (graphName.isEmpty) {
      AppToast.error(context, 'Graph name is required');
      return;
    }
    if (seriesList.isEmpty) {
      AppToast.error(context, 'At least one series is required');
      return;
    }
    for (var i = 0; i < seriesList.length; i++) {
      final s = seriesList[i];
      if (s['metricName'] == null || s['metricName'].isEmpty) {
        AppToast.error(context, 'Metric name is required for series ${i + 1}');
        return;
      }
    }

    final hisVms = _controller.entityOptions['hisVms'] as List? ?? [];
    final hisProviders = _controller.entityOptions['hisProviders'] as List? ?? [];

    final userProviderIds = hisProviders.map((p) => p['value']).toSet().toList();
    final vmsProviderIds = hisVms.map((v) => v['provider_id']).toSet().toList();

    final mappedSeries = seriesList.map((s) {
      final filters = Map<String, dynamic>.from(s['filters']);
      final pid = filters['provider_id'];
      final ename = filters['entity_name'];

      dynamic finalPid;
      if (pid == 'all_providers') {
        finalPid = jsonEncode(userProviderIds);
      } else if (ename == 'all_vms') {
        finalPid = jsonEncode(vmsProviderIds);
      } else {
        finalPid = pid;
      }

      final mappedFilters = <String, dynamic>{
        'provider_id': finalPid,
      };

      if (ename != null && ename != 'all_vms' && ename != 'provider_all_vms' && pid != null && pid != 'all_providers') {
        mappedFilters['entity_name'] = ename;
      }

      return {
        'metricId': '',
        'metricName': s['metricName'],
        'entityType': (pid != 'all_providers' && ename != 'provider_all_vms') ? 'vm' : s['entityType'],
        'aggregation': s['aggregation'],
        'filters': mappedFilters,
        'groupBy': [],
        'yAxisPosition': s['yAxisPosition'],
      };
    }).toList();

    final payload = {
      'dashboardId': _controller.currentDashboardId.value,
      'graphName': graphName,
      'graphType': graphType,
      'defaultTimeRange': '$defaultTimeRange|0',
      'refreshIntervalSeconds': refreshIntervalSeconds,
      'settings': '{}',
      'series': mappedSeries,
    };

    Navigator.pop(context);
    final r = await _controller.createGraph(payload);
    if (mounted) AppToast.success(context, r ?? 'Created');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Dialog(
      backgroundColor: p.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Create Graph', style: AppTextStyles.h3(p.textPrimary)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: p.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) => graphName = v,
                            decoration: const InputDecoration(labelText: 'Graph Name', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => defaultTimeRange = int.tryParse(v) ?? 60,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Default Time Range (min)', border: OutlineInputBorder()),
                            controller: TextEditingController(text: '60'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Series', style: AppTextStyles.h4(p.textPrimary)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => _addSeries()),
                          child: Text('+ Add series', style: AppTextStyles.bodyMedium(AppColors.lime600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...seriesList.asMap().entries.map((e) {
                      final idx = e.key;
                      final s = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: p.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Series ${idx + 1}', style: AppTextStyles.bodySemibold(p.textPrimary)),
                                if (seriesList.length > 1)
                                  InkWell(
                                    onTap: () => _removeSeries(idx),
                                    child: Text('Remove', style: AppTextStyles.bodySmall(AppColors.red500)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: s['entityType'],
                                    decoration: const InputDecoration(labelText: 'Entity Type', border: OutlineInputBorder()),
                                    items: const [
                                      DropdownMenuItem(value: 'vm', child: Text('VM')),
                                      DropdownMenuItem(value: 'provider', child: Text('Provider')),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        s['entityType'] = v;
                                        s['metricName'] = '';
                                        if (v == 'vm') {
                                          final hisVms = _controller.entityOptions['hisVms'] as List? ?? [];
                                          s['filters']['provider_id'] = hisVms.map((vm) => vm['provider_id']).toSet().toList();
                                          s['filters']['entity_name'] = 'all_vms';
                                        } else if (v == 'provider') {
                                          s['filters']['provider_id'] = 'all_providers';
                                          s['filters']['entity_name'] = 'provider_all_vms';
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTargetDropdown(idx, s, p)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: (s['metricName'] != null && s['metricName'].isNotEmpty) ? s['metricName'] : null,
                                    decoration: const InputDecoration(labelText: 'Metric', border: OutlineInputBorder()),
                                    items: _getMetricsFor(s['entityType']).map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                    onChanged: (v) {
                                      setState(() => s['metricName'] = v ?? '');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: s['aggregation'],
                                    decoration: const InputDecoration(labelText: 'Aggregation', border: OutlineInputBorder()),
                                    items: const [
                                      DropdownMenuItem(value: 'sum', child: Text('Sum')),
                                      DropdownMenuItem(value: 'avg', child: Text('Average')),
                                    ],
                                    onChanged: (v) => setState(() => s['aggregation'] = v ?? 'sum'),
                                  ),
                                ),
                              ],
                            ),
                            if (s['entityType'] == 'provider' && s['filters']['provider_id'] != 'all_providers') ...[
                              const SizedBox(height: 12),
                              _buildProviderVmDropdown(idx, s, p),
                            ]
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime500, foregroundColor: Colors.white),
                  child: const Text('Create & Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetDropdown(int idx, Map<String, dynamic> s, AppPalette p) {
    final type = s['entityType'];
    if (type == 'vm') {
      final hisVms = _controller.entityOptions['hisVms'] as List? ?? [];
      final items = [
        const DropdownMenuItem(value: 'all_vms', child: Text('All VMs')),
        ...hisVms.map((v) => DropdownMenuItem(value: v['value'].toString(), child: Text(v['label'].toString()))),
      ];
      return DropdownButtonFormField<String>(
        value: s['filters']['entity_name'],
        decoration: InputDecoration(labelText: 'Select VM', border: const OutlineInputBorder()),
        items: items,
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            s['filters']['entity_name'] = v;
            if (v == 'all_vms') {
              s['aggregation'] = 'sum';
            } else {
              s['aggregation'] = 'avg';
              final found = hisVms.firstWhere((element) => element['value'] == v, orElse: () => {});
              if (found.isNotEmpty) {
                s['filters']['provider_id'] = found['provider_id'];
              }
            }
          });
        },
      );
    } else {
      final hisProviders = _controller.entityOptions['hisProviders'] as List? ?? [];
      final items = [
        const DropdownMenuItem(value: 'all_providers', child: Text('All Providers')),
        ...hisProviders.map((p) => DropdownMenuItem(value: p['value'].toString(), child: Text(p['label'].toString()))),
      ];
      return DropdownButtonFormField<String>(
        value: s['filters']['provider_id'],
        decoration: InputDecoration(labelText: 'Select Provider', border: const OutlineInputBorder()),
        items: items,
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            s['filters']['provider_id'] = v;
            if (v == 'all_providers') {
              s['aggregation'] = 'sum';
            } else {
              s['filters']['entity_name'] = 'provider_all_vms';
              s['aggregation'] = 'sum';
            }
          });
        },
      );
    }
  }

  Widget _buildProviderVmDropdown(int idx, Map<String, dynamic> s, AppPalette p) {
    final hisProviders = _controller.entityOptions['hisProviders'] as List? ?? [];
    final providerId = s['filters']['provider_id'];
    final provider = hisProviders.firstWhere((element) => element['value'] == providerId, orElse: () => {});
    final allVms = (provider['allVms'] as List?) ?? [];

    final items = [
      const DropdownMenuItem(value: 'provider_all_vms', child: Text('All provider VMs')),
      ...allVms.map((vm) => DropdownMenuItem(value: vm['vm_id'].toString(), child: Text(vm['vm_name'].toString()))),
    ];

    return DropdownButtonFormField<String>(
      value: s['filters']['entity_name'],
      decoration: InputDecoration(labelText: "Select provider's VM", border: const OutlineInputBorder()),
      items: items,
      onChanged: (v) {
        if (v == null) return;
        setState(() {
          s['filters']['entity_name'] = v;
          if (v == 'provider_all_vms') {
            s['aggregation'] = 'sum';
          } else {
            s['aggregation'] = 'avg';
          }
        });
      },
    );
  }
}
