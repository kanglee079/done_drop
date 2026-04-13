import 'package:get/get.dart';
import 'package:done_drop/core/models/recap.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';

/// Handles the generation and presentation of the Sunday Weekly Recap
class WeeklyRecapController extends GetxController {
  WeeklyRecapController(this._momentRepo);

  final MomentRepository _momentRepo;

  final RxBool isLoading = true.obs;
  final Rx<WeeklyRecap?> currentRecap = Rx<WeeklyRecap?>(null);

  Future<void> generateWeeklyRecap(String userId) async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      // Find the start of the week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // In a real implementation we would fetch proofs for the week:
      // final weekProofs = await _momentRepo.getMomentsBetween(userId, startOfWeek, endOfWeek);
      final List<Moment> weekProofs = []; // placeholder

      // We'd aggregate stats
      final totalProofs = weekProofs.length;
      final avgConsistency = totalProofs > 0 ? 0.85 : 0.0; // placeholder calculated rate

      currentRecap.value = WeeklyRecap(
        id: 'recap_${now.millisecondsSinceEpoch}',
        ownerId: userId,
        weekKey: '${now.year}-W${((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil()}',
        totalMoments: totalProofs,
        streakDays: 0,
        highlightMomentIds: weekProofs.take(3).map((m) => m.id).toList(),
        createdAt: now,
        bestDay: now,
        totalProofsCaptured: totalProofs,
        consistencyScore: avgConsistency,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load weekly recap');
    } finally {
      isLoading.value = false;
    }
  }
}
