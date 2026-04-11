import 'package:get/get.dart';
import 'package:done_drop/app/presentation/report/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportController());
  }
}
