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
  final String pestDetected;
  final String pestType;
  final String pestRemovalOrganic;
  final String pestRemovalChemical;
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
    this.pestDetected = 'No pest detected',
    this.pestType = 'N/A',
    this.pestRemovalOrganic = 'N/A',
    this.pestRemovalChemical = 'N/A',
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
      pestDetected: json['pest_detected']?.toString() ?? 'No pest detected',
      pestType: json['pest_type']?.toString() ?? 'N/A',
      pestRemovalOrganic: json['pest_removal_organic']?.toString() ?? 'N/A',
      pestRemovalChemical: json['pest_removal_chemical']?.toString() ?? 'N/A',
      confidence: json['confidence']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'crop_name_hindi': cropNameHindi,
        'age': age,
        'stage': stage,
        'health_score': healthScore,
        'health_status': healthStatus,
        'pros': pros,
        'cons': cons,
        'requirements': requirements,
        'growth_products': products,
        'disease': disease,
        'disease_cause': diseaseCause,
        'disease_prevention': diseasePrevention,
        'treatment': treatment,
        'irrigation_advice': irrigationAdvice,
        'fertilizer_recommendation': fertilizerRecommendation,
        'growth_tips': growthTips,
        'harvest_readiness': harvestReadiness,
        'harvest_days': harvestDays,
        'harvest_date': harvestDate,
        'total_lifecycle': totalLifecycle,
        'pest_detected': pestDetected,
        'pest_type': pestType,
        'pest_removal_organic': pestRemovalOrganic,
        'pest_removal_chemical': pestRemovalChemical,
        'confidence': confidence,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String localizedPros(bool isHi) {
    if (!isHi) {
      if (pros.contains('पत्तियां हरी-भरी हैं') || pros.isEmpty) return 'Good foliage and healthy vegetative growth';
      return pros;
    }
    if (pros == 'No data' || pros.isEmpty) return 'पत्तियां हरी-भरी हैं और बढ़वार सुचारू है।';
    return pros;
  }

  String localizedCons(bool isHi) {
    if (!isHi) {
      if (cons.contains('कोई गंभीर समस्या नहीं') || cons.isEmpty) return 'No significant issues or pests observed';
      return cons;
    }
    if (cons == 'No data' || cons.isEmpty || cons.toLowerCase() == 'no significant issues') {
      return 'कोई गंभीर समस्या या बीमारी नहीं है।';
    }
    return cons;
  }

  String localizedDisease(bool isHi) {
    if (!isHi) {
      if (disease.contains('कोई रोग नहीं') || disease.toLowerCase() == 'healthy') {
        return 'No disease detected (Healthy)';
      }
      return disease;
    }
    if (disease.toLowerCase() == 'no disease detected' || disease.toLowerCase() == 'healthy' || disease == 'N/A' || disease.toLowerCase() == 'none') {
      return 'कोई रोग नहीं मिला (फसल स्वस्थ है)';
    }
    return disease;
  }

  String localizedTreatment(bool isHi) {
    if (!isHi) {
      if (treatment.contains('उपचार की आवश्यकता नहीं')) {
        return 'No treatment needed, crop is healthy.';
      }
      return treatment;
    }
    if (treatment.toLowerCase() == 'no treatment needed' || treatment == 'N/A') {
      return 'उपचार की आवश्यकता नहीं है, फसल सामान्य है।';
    }
    return treatment;
  }

  String localizedPest(bool isHi) {
    if (!isHi) {
      if (pestDetected.contains('कोई कीट नहीं')) {
        return 'No pest detected';
      }
      return pestDetected;
    }
    if (pestDetected.toLowerCase() == 'no pest detected' || pestDetected == 'N/A' || pestDetected.toLowerCase() == 'none') {
      return 'कोई हानिकारक कीट नहीं मिला';
    }
    return pestDetected;
  }
}