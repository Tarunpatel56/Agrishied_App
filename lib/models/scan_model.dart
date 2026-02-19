class ScanModel {
  final String cropName;
  final String cropNameHindi;
  final String age;
  final String stage;
  final int healthScore;
  final String healthStatus;
  final String pros;
  final String cons;
  final String requirements;
  final String products;
  final String disease;
  final String diseaseCause;
  final String diseasePrevention;
  final String treatment;
  final String irrigationAdvice;
  final String fertilizerRecommendation;
  final String growthTips;
  final String harvestReadiness;
  final int harvestDays;
  final String harvestDate;
  final int totalLifecycle;
  final String confidence;

  ScanModel({
    required this.cropName,
    this.cropNameHindi = '',
    required this.age,
    required this.stage,
    this.healthScore = 0,
    required this.healthStatus,
    required this.pros,
    required this.cons,
    required this.requirements,
    required this.products,
    required this.disease,
    this.diseaseCause = 'N/A',
    this.diseasePrevention = 'N/A',
    required this.treatment,
    this.irrigationAdvice = 'N/A',
    this.fertilizerRecommendation = 'N/A',
    this.growthTips = 'N/A',
    this.harvestReadiness = 'N/A',
    this.harvestDays = 0,
    this.harvestDate = 'N/A',
    this.totalLifecycle = 0,
    required this.confidence,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      cropName: json['crop_name']?.toString() ?? 'Unknown',
      cropNameHindi: json['crop_name_hindi']?.toString() ?? '',
      age: json['age']?.toString() ?? 'N/A',
      stage: json['stage']?.toString() ?? 'N/A',
      healthScore: _parseInt(json['health_score']),
      healthStatus: json['health_status']?.toString() ?? 'N/A',
      pros: json['pros']?.toString() ?? 'No data',
      cons: json['cons']?.toString() ?? 'No data',
      requirements: json['requirements']?.toString() ?? 'N/A',
      products: json['growth_products']?.toString() ?? 'N/A',
      disease: json['disease']?.toString() ?? 'No disease detected',
      diseaseCause: json['disease_cause']?.toString() ?? 'N/A',
      diseasePrevention: json['disease_prevention']?.toString() ?? 'N/A',
      treatment: json['treatment']?.toString() ?? 'No treatment needed',
      irrigationAdvice: json['irrigation_advice']?.toString() ?? 'N/A',
      fertilizerRecommendation: json['fertilizer_recommendation']?.toString() ?? 'N/A',
      growthTips: json['growth_tips']?.toString() ?? 'N/A',
      harvestReadiness: json['harvest_readiness']?.toString() ?? 'N/A',
      harvestDays: _parseInt(json['harvest_days']),
      harvestDate: json['harvest_date']?.toString() ?? 'N/A',
      totalLifecycle: _parseInt(json['total_lifecycle']),
      confidence: json['confidence']?.toString() ?? '0',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}