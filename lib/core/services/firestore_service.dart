import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نموذج البلاغ
class ReportModel {
  final String? id;
  final String reportType;
  final String stationName;
  final String location;
  final String details;
  final DateTime createdAt;
  final String status; // pending, reviewed, resolved

  ReportModel({
    this.id,
    required this.reportType,
    required this.stationName,
    required this.location,
    required this.details,
    required this.createdAt,
    this.status = 'pending',
  });

  /// تحويل من Map (Firestore)
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reportType: data['reportType'] ?? '',
      stationName: data['stationName'] ?? '',
      location: data['location'] ?? '',
      details: data['details'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  /// تحويل إلى Map (Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'reportType': reportType,
      'stationName': stationName,
      'location': location,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}

/// خدمة Firestore للبلاغات
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// مرجع مجموعة البلاغات
  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  /// إرسال بلاغ جديد
  Future<String?> submitReport(ReportModel report) async {
    try {
      final docRef = await _reportsCollection.add(report.toFirestore());
      debugPrint('Report submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error submitting report: $e');
      return null;
    }
  }

  /// جلب بلاغات المستخدم (اختياري - إذا أردت عرضها)
  Stream<List<ReportModel>> getReportsStream() {
    return _reportsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReportModel.fromFirestore(doc);
          }).toList();
        });
  }

  /// جلب البلاغات مرة واحدة
  Future<List<ReportModel>> getReports() async {
    try {
      final snapshot = await _reportsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ReportModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('Error getting reports: $e');
      return [];
    }
  }

  /// حذف بلاغ
  Future<bool> deleteReport(String reportId) async {
    try {
      await _reportsCollection.doc(reportId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting report: $e');
      return false;
    }
  }

  /// تحديث حالة البلاغ
  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _reportsCollection.doc(reportId).update({'status': status});
      return true;
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }
}
