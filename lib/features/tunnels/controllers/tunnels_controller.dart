import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class TunnelsController extends GetxController {
  final tunnels = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override void onInit() { super.onInit(); fetchTunnels(); }

  Future<void> fetchTunnels() async {
    isLoading.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.getUserClients);
      if (res is List) {
        tunnels.value = List<Map<String, dynamic>>.from(res);
      } else {
        tunnels.value = List<Map<String, dynamic>>.from(res['tunnel_clients'] ?? res['clients'] ?? []);
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<String?> createTunnel({required String tunnelName}) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.createTunnelClient, data: {'tunnelName': tunnelName}); await fetchTunnels(); return 'Tunnel created'; } catch (e) { return 'Error: $e'; }
  }

  Future<String?> editTunnel({required String tunnelId, required String tunnelName}) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.editTunnel, data: {'tunnelId': tunnelId, 'tunnelName': tunnelName}); await fetchTunnels(); return 'Tunnel updated'; } catch (e) { return 'Error: $e'; }
  }

  Future<String?> deleteTunnel(String tunnelId) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.deleteTunnel, data: {'tunnelId': tunnelId}); await fetchTunnels(); return 'Tunnel deleted'; } catch (e) { return 'Error: $e'; }
  }
}
