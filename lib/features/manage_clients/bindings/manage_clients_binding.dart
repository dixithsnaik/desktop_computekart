import 'package:get/get.dart';
import '../controllers/manage_clients_controller.dart';
class ManageClientsBinding extends Bindings { @override void dependencies() { Get.lazyPut(() => ManageClientsController()); } }
