import 'package:cloud_firestore/cloud_firestore.dart';

class PolicyModel {
  final String? policyId;
  final String farmerId;
  final String enrollmentId;
  final String cropType;
  final double areaAcres;
  final double premiumAmount;
  final String gpsLocation;
  final double triggerDamagePercent;
  final String status; // Active, Expired, Claimed
  final String createdAt;
  final String? blockchainHash;

  PolicyModel({
    this.policyId,
    required this.farmerId,
    required this.enrollmentId,
    required this.cropType,
    required this.areaAcres,
    required this.premiumAmount,
    required this.gpsLocation,
    this.triggerDamagePercent = 70.0,
    this.status = 'Active',
    required this.createdAt,
    this.blockchainHash,
  });

  factory PolicyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PolicyModel(
      policyId: doc.id,
      farmerId: data['farmerId'] ?? '',
      enrollmentId: data['enrollmentId'] ?? '',
      cropType: data['cropType'] ?? '',
      areaAcres: (data['areaAcres'] ?? 0).toDouble(),
      premiumAmount: (data['premiumAmount'] ?? 0).toDouble(),
      gpsLocation: data['gpsLocation'] ?? '',
      triggerDamagePercent: (data['triggerDamagePercent'] ?? 70).toDouble(),
      status: data['status'] ?? 'Active',
      createdAt: data['created_at'] ?? '',
      blockchainHash: data['blockchainHash'],
    );
  }

  Map<String, dynamic> toJson() => {
        'farmerId': farmerId,
        'enrollmentId': enrollmentId,
        'cropType': cropType,
        'areaAcres': areaAcres,
        'premiumAmount': premiumAmount,
        'gpsLocation': gpsLocation,
        'triggerDamagePercent': triggerDamagePercent,
        'status': status,
        'created_at': createdAt,
        'blockchainHash': blockchainHash,
        'timestamp': FieldValue.serverTimestamp(),
      };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PREMIUM CALCULATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// Base rate: ₹500/acre × crop risk multiplier
  static double calculatePremium(String cropType, double areaAcres) {
    const double baseRate = 500.0; // ₹500 per acre

    // Crop-specific risk multipliers
    final Map<String, double> riskMultipliers = {
      'wheat': 1.0,
      'rice': 1.2,
      'cotton': 1.5,
      'sugarcane': 1.3,
      'soybean': 1.1,
      'potato': 1.4,
      'onion': 1.6,
      'kanda': 1.6, // Onion in Hindi
      'tomato': 1.5,
      'maize': 1.0,
      'corn': 1.0,
      'groundnut': 1.2,
      'chilli': 1.4,
      'turmeric': 1.3,
      'banana': 1.2,
      'grapes': 1.8,
      'mango': 1.1,
      'pomegranate': 1.5,
    };

    final multiplier = riskMultipliers[cropType.toLowerCase()] ?? 1.2;
    return baseRate * areaAcres * multiplier;
  }

  /// Get crop risk level for display
  static String getCropRiskLevel(String cropType) {
    final premium = calculatePremium(cropType, 1.0);
    if (premium >= 800) return 'High Risk';
    if (premium >= 600) return 'Medium Risk';
    return 'Low Risk';
  }

  static Color getCropRiskColor(String cropType) {
    final premium = calculatePremium(cropType, 1.0);
    if (premium >= 800) return const Color(0xFFE53935);
    if (premium >= 600) return const Color(0xFFFF9800);
    return const Color(0xFF43A047);
  }

  /// List of supported crops
  static const List<String> supportedCrops = [
    'Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Soybean',
    'Potato', 'Onion', 'Tomato', 'Maize', 'Groundnut',
    'Chilli', 'Turmeric', 'Banana', 'Grapes', 'Mango', 'Pomegranate',
  ];
}
