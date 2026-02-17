class CropModel {
  final String cropType;
  final int healthScore;
  final String growthStage;
  final int estimatedAge;
  final int daysToHarvest;
  final String expectedHarvest;
  final int riskPercent;
  final String advisory;

  CropModel({
    required this.cropType,
    required this.healthScore,
    required this.growthStage,
    required this.estimatedAge,
    required this.daysToHarvest,
    required this.expectedHarvest,
    required this.riskPercent,
    required this.advisory,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      cropType: json['crop_type'],
      healthScore: json['health_score'],
      growthStage: json['growth_stage'],
      estimatedAge: json['estimated_age'],
      daysToHarvest: json['days_to_harvest'],
      expectedHarvest: json['expected_harvest'],
      riskPercent: json['risk_percent'],
      advisory: json['advisory'],
    );
  }
}