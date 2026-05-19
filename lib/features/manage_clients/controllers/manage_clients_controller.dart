import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/wsl_execution_service.dart';

class ManageClientsController extends GetxController {
  final clients = <Map<String, dynamic>>[].obs;
  final selectedClient = Rxn<Map<String, dynamic>>();
  final isLoading = true.obs;

  @override void onInit() { super.onInit(); fetchClients(); }

  Future<void> fetchClients() async {
    isLoading.value = true;
    try { final api = Get.find<ApiService>(); final res = await api.call('GET', ApiConstants.getAllCliSessionDetails); clients.value = List<Map<String, dynamic>>.from(res['cli_session_details'] ?? []); } catch (_) {}
    isLoading.value = false;
  }

  void selectClient(Map<String, dynamic> c) { selectedClient.value = selectedClient.value?['cli_id'] == c['cli_id'] ? null : c; }

  Future<String?> addClient() async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('GET', ApiConstants.getCliVerificationToken);
      final token = res['cli_verification_token'] ?? res['token'];
      if (token != null) {
        return token.toString();
      }
      return res['command'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> deleteClient(String cliId) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.deleteCliSession, data: {'cli_id': cliId}); selectedClient.value = null; await fetchClients(); return 'Client deleted'; } catch (e) { return 'Error: $e'; }
  }
}
