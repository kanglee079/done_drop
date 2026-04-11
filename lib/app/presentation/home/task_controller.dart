import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';

/// Controller for task templates on the Today tab.
class TaskController extends GetxController {
  TaskController(this._momentRepo);
  final MomentRepository _momentRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;

  final RxList<TaskTemplate> tasks = <TaskTemplate>[].obs;
  final RxList<String> completedTaskIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _watchTasks();
  }

  void _watchTasks() {
    final uid = _userId;
    if (uid == null) return;
    tasks.bindStream(_momentRepo.watchTaskTemplates(uid));
  }

  bool isDone(String taskId) => completedTaskIds.contains(taskId);

  Future<void> archiveTask(String taskId) async {
    await _momentRepo.archiveTaskTemplate(taskId);
  }
}
