import 'package:get/get.dart';
import '../controllers/manage_providers_controller.dart';
class ManageProvidersBinding extends Bindings { @override void dependencies() { Get.lazyPut(() => ManageProvidersController()); } }
