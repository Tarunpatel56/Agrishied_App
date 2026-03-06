import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimModel {
  final String? docId;
  final String farmerId;
  final String enrollmentId;
  final String cropName;
  final String disease;
  final String damagePercent;
  final String ipfsHash;
  final String location;
  final String claimType; // 'government' or 'private'
  final String status;
  final String timestamp;
  final Map<String, dynamic>? aiReport;

  ClaimModel({
    this.docId,
    required this.farmerId,
    required this.enrollmentId,
    required this.cropName,
    required this.disease,
    required this.damagePercent,
    required this.ipfsHash,
    required this.location,
    required this.claimType,
    required this.status,
    required this.timestamp,
    this.aiReport,
  });

  factory ClaimModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClaimModel(
      docId: doc.id,
      farmerId: data['farmerId']?.toString() ?? '',
      enrollmentId: data['enrollmentId']?.toString() ?? '',
      cropName: data['cropName']?.toString() ?? '',
      disease: data['disease']?.toString() ?? '',
      damagePercent: data['damagePercent']?.toString() ?? '0',
      ipfsHash: data['ipfsHash']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      claimType: data['claimType']?.toString() ?? 'government',
      status: data['status']?.toString() ?? 'Pending Verification',
      timestamp: data['timestamp']?.toString() ?? '',
      aiReport: data['aiReport'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'farmerId': farmerId,
        'enrollmentId': enrollmentId,
        'cropName': cropName,
        'disease': disease,
        'damagePercent': damagePercent,
        'ipfsHash': ipfsHash,
        'location': location,
        'claimType': claimType,
        'status': status,
        'timestamp': timestamp,
        'aiReport': aiReport,
      };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TRACKING STAGE — Maps status to 4-stage pipeline index
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// Stage 0: Submitted
  /// Stage 1: Blockchain Verified / Submitted_to_Govt
  /// Stage 2: Govt Inspection
  /// Stage 3: Payment Disbursed / Smart_Contract_Approved / Approved
  int get trackingStage {
    switch (status) {
      case 'Pending Verification':
        return 0;
      case 'Submitted_to_Govt':
      case 'Blockchain_Verified':
        return 1;
      case 'Govt_Inspection':
      case 'Under_Review':
        return 2;
      case 'Approved':
      case 'Smart_Contract_Approved':
      case 'Payment_Disbursed':
        return 3;
      case 'Rejected':
        return -1;
      default:
        return 0;
    }
  }

  static const List<String> trackingLabels = [
    'Submitted',
    'Blockchain Verified',
    'Govt Inspection',
    'Payment Disbursed',
  ];

  static const List<String> trackingIcons = [
    '📤',
    '🔗',
    '🏛️',
    '💰',
  ];
}
