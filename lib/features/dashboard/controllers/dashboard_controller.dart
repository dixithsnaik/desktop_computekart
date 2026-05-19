import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/helpers.dart';

class DashboardController extends GetxController {
  final dashboards = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final currentDashboardId = RxnString();
  final graphs = <Map<String, dynamic>>[].obs;
  final graphDataMap = <String, dynamic>{}.obs;
  final isLoadingGraphs = false.obs;
  final entityOptions = <String, dynamic>{'hisVms': [], 'hisProviders': []}.obs;

  @override void onInit() { 
    super.onInit(); 
    fetchDashboards(); 
    final id = Get.parameters['id'];
    if (id != null) {
      currentDashboardId.value = id;
      fetchGraphs(id);
    }
  }

  Future<void> fetchDashboards() async {
    isLoading.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('GET', ApiConstants.listDashboards);
      if (res is List) {
        dashboards.value = List<Map<String, dynamic>>.from(res);
      } else {
        dashboards.value = List<Map<String, dynamic>>.from(res['dashboards'] ?? []);
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<String?> createDashboard(String name) async {
    try {
      final api = Get.find<ApiService>();
      await api.call('POST', ApiConstants.createDashboard, data: {'dashboardName': name, 'dashboardDescription': ''});
      await fetchDashboards(); return 'Dashboard created';
    } catch (e) { return 'Error: $e'; }
  }

  Future<String?> deleteDashboard(String id) async {
    try {
      final api = Get.find<ApiService>();
      await api.call('POST', ApiConstants.deleteDashboard, data: {'dashboardId': id});
      await fetchDashboards(); return 'Dashboard deleted';
    } catch (e) { return 'Error: $e'; }
  }

  void openDashboard(String id) {
    currentDashboardId.value = id;
    fetchGraphs(id);
    Get.toNamed('/dashboard/view?id=$id');
  }

  Future<void> fetchGraphs(String dashboardId) async {
    isLoadingGraphs.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.listGraphsForDashboard, data: {'dashboardId': dashboardId});
      if (res is List) {
        graphs.value = List<Map<String, dynamic>>.from(res);
      } else {
        graphs.value = List<Map<String, dynamic>>.from(res['graphs'] ?? []);
      }
      for (final g in graphs) { await _fetchGraphPoints(g); }
    } catch (_) {}
    isLoadingGraphs.value = false;
  }

  Future<void> _fetchGraphPoints(Map<String, dynamic> graph) async {
    final graphId = graph['graphId'];
    try {
      final api = Get.find<ApiService>();
      final timeRange = Helpers.normalizeTimeRange(graph['defaultTimeRange']?.toString());
      final normalizedPayload = Map<String, dynamic>.from(graph);
      normalizedPayload['defaultTimeRange'] = timeRange;
      
      final res = await api.call('POST', ApiConstants.getGraphPoints, data: normalizedPayload);
      graphDataMap[graphId] = res;
    } catch (_) {
      graphDataMap[graphId] = {'series': []};
    }
    graphDataMap.refresh();
  }

  Future<String?> deleteGraph(String graphId) async {
    try {
      final api = Get.find<ApiService>();
      await api.call('POST', ApiConstants.deleteGraph, data: {'graphId': graphId});
      if (currentDashboardId.value != null) await fetchGraphs(currentDashboardId.value!);
      return 'Graph deleted';
    } catch (e) { return 'Error: $e'; }
  }

  Future<void> fetchEntityOptions() async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.getServiceDetailsForUser);
      final hisVms = (res['hisvms'] as List? ?? []).map((vm) => {'label': vm['vmName'] ?? vm['internalVmName'], 'value': vm['internalVmName'], 'provider_id': vm['providerId']}).toList();
      final hisProviders = (res['hisproviders'] as List? ?? []).map((p) => {'label': p['providerName'], 'value': p['providerId'], 'allVms': (p['vmsInThisProvider'] as List? ?? []).map((vm) => {'vm_id': vm['vmId'], 'vm_name': vm['vmName'] ?? vm['vmId']}).toList()}).toList();
      entityOptions.value = {'hisVms': hisVms, 'hisProviders': hisProviders};
    } catch (_) {}
  }

  Future<String?> createGraph(Map<String, dynamic> payload) async {
    try {
      final api = Get.find<ApiService>();
      await api.call('POST', ApiConstants.createGraphWithSeries, data: payload);
      if (currentDashboardId.value != null) await fetchGraphs(currentDashboardId.value!);
      return 'Graph created';
    } catch (e) { return 'Error: $e'; }
  }
}
