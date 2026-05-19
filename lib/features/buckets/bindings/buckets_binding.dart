import 'package:get/get.dart';
import '../controllers/buckets_controller.dart';
class BucketsBinding extends Bindings { @override void dependencies() { Get.lazyPut(() => BucketsController()); } }
