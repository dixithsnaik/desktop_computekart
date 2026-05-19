import 'package:get/get.dart';
import '../controllers/tunnels_controller.dart';
class TunnelsBinding extends Bindings { @override void dependencies() { Get.lazyPut(() => TunnelsController()); } }
