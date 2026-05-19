import 'package:get/get.dart';
import '../controllers/client_services_controller.dart';
class ClientServicesBinding extends Bindings { @override void dependencies() { Get.lazyPut(() => ClientServicesController()); } }
