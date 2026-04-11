import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for submitting user reports.
class ReportRepository {
  ReportRepository();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> submitReport({
    required String reporterId,
    required String reporterEmail,
    required String reportedUserId,
    required String reason,
    String? additionalDetails,
    String? momentId,
  }) async {
    final ref = _db.collection('reports').doc();

    await ref.set({
      'id': ref.id,
      'reporterId': reporterId,
      'reporterEmail': reporterEmail,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'additionalDetails': additionalDetails,
      'momentId': momentId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
