class SoilModel {
  final String soilType;
  final String soilTypeHindi;
  final String pHLevel;
  final String soilTexture;
  final String soilColor;
  final String soilHealth;
  final int healthScore;
  final String moistureLevel;
  final String organicMatter;
  final String composition;
  final String nitrogenLevel;
  final String phosphorusLevel;
  final String potassiumLevel;
  final String advisory;

  SoilModel({
    required this.soilType,
    required this.soilTypeHindi,
    required this.pHLevel,
    required this.soilTexture,
    required this.soilColor,
    required this.soilHealth,
    required this.healthScore,
    required this.moistureLevel,
    required this.organicMatter,
    required this.composition,
    required this.nitrogenLevel,
    required this.phosphorusLevel,
    required this.potassiumLevel,
    required this.advisory,
  });

  factory SoilModel.fromJson(Map<String, dynamic> json) {
    return SoilModel(
      soilType: json['soil_type'] ?? 'Unknown',
      soilTypeHindi: json['soil_type_hindi'] ?? '',
      pHLevel: json['ph_level'] ?? 'N/A',
      soilTexture: json['soil_texture'] ?? 'Unknown',
      soilColor: json['soil_color'] ?? 'Unknown',
      soilHealth: json['soil_health'] ?? 'Unknown',
      healthScore: _toInt(json['health_score']),
      moistureLevel: json['moisture_level'] ?? 'Unknown',
      organicMatter: json['organic_matter'] ?? 'Unknown',
      composition: json['composition'] ?? 'N/A',
      nitrogenLevel: json['nitrogen_level'] ?? 'Unknown',
      phosphorusLevel: json['phosphorus_level'] ?? 'Unknown',
      potassiumLevel: json['potassium_level'] ?? 'Unknown',
      advisory: json['advisory'] ?? 'No advisory',
    );
  }

  Map<String, dynamic> toJson() => {
        'soil_type': soilType,
        'soil_type_hindi': soilTypeHindi,
        'ph_level': pHLevel,
        'soil_texture': soilTexture,
        'soil_color': soilColor,
        'soil_health': soilHealth,
        'health_score': healthScore,
        'moisture_level': moistureLevel,
        'organic_matter': organicMatter,
        'composition': composition,
        'nitrogen_level': nitrogenLevel,
        'phosphorus_level': phosphorusLevel,
        'potassium_level': potassiumLevel,
        'advisory': advisory,
      };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class PlantRecommendation {
  final String plantName;
  final String plantNameHindi;
  final String suitability;
  final String plantType;
  final int growthDays;
  final String plantAgeInfo;
  final String sunlightNeeds;
  final String waterNeeds;
  final String fertilizerNeeds;
  final String soilPreparation;
  final String plantingMethod;
  final List<String> careSteps;
  final String commonDiseases;
  final String harvestInfo;
  final List<String> benefits;
  final String bestSeason;
  final String difficultyLevel;
  final String description;

  PlantRecommendation({
    required this.plantName,
    required this.plantNameHindi,
    required this.suitability,
    required this.plantType,
    required this.growthDays,
    required this.plantAgeInfo,
    required this.sunlightNeeds,
    required this.waterNeeds,
    required this.fertilizerNeeds,
    required this.soilPreparation,
    required this.plantingMethod,
    required this.careSteps,
    required this.commonDiseases,
    required this.harvestInfo,
    required this.benefits,
    required this.bestSeason,
    required this.difficultyLevel,
    required this.description,
  });

  factory PlantRecommendation.fromJson(Map<String, dynamic> json) {
    return PlantRecommendation(
      plantName: json['plant_name'] ?? 'Unknown',
      plantNameHindi: json['plant_name_hindi'] ?? '',
      suitability: json['suitability'] ?? 'Moderate',
      plantType: json['plant_type'] ?? 'Plant',
      growthDays: _toInt(json['growth_days']),
      plantAgeInfo: json['plant_age_info'] ?? 'N/A',
      sunlightNeeds: json['sunlight_needs'] ?? 'N/A',
      waterNeeds: json['water_needs'] ?? 'N/A',
      fertilizerNeeds: json['fertilizer_needs'] ?? 'N/A',
      soilPreparation: json['soil_preparation'] ?? 'N/A',
      plantingMethod: json['planting_method'] ?? 'N/A',
      careSteps: List<String>.from(json['care_steps'] ?? []),
      commonDiseases: json['common_diseases'] ?? 'N/A',
      harvestInfo: json['harvest_info'] ?? 'N/A',
      benefits: List<String>.from(json['benefits'] ?? []),
      bestSeason: json['best_season'] ?? 'All Season',
      difficultyLevel: json['difficulty_level'] ?? 'Medium',
      description: json['description'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'plant_name': plantName,
        'plant_name_hindi': plantNameHindi,
        'suitability': suitability,
        'plant_type': plantType,
        'growth_days': growthDays,
        'plant_age_info': plantAgeInfo,
        'sunlight_needs': sunlightNeeds,
        'water_needs': waterNeeds,
        'fertilizer_needs': fertilizerNeeds,
        'soil_preparation': soilPreparation,
        'planting_method': plantingMethod,
        'care_steps': careSteps,
        'common_diseases': commonDiseases,
        'harvest_info': harvestInfo,
        'benefits': benefits,
        'best_season': bestSeason,
        'difficulty_level': difficultyLevel,
        'description': description,
      };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class CropRecommendation {
  final String cropName;
  final String cropNameHindi;
  final String suitability;
  final String season;
  final String bestPlantingMonth;
  final int growthDurationDays;
  final String cropAgeStages;
  final String seedQuantity;
  final List<String> soilPreparationSteps;
  final String fertilizerSchedule;
  final String irrigationSchedule;
  final String pesticideNeeds;
  final String weedManagement;
  final String expectedYield;
  final String expectedProfit;
  final List<String> benefits;
  final List<String> drawbacks;
  final List<String> growthRequirements;
  final String harvestMethod;
  final String marketDemand;
  final String description;

  CropRecommendation({
    required this.cropName,
    required this.cropNameHindi,
    required this.suitability,
    required this.season,
    required this.bestPlantingMonth,
    required this.growthDurationDays,
    required this.cropAgeStages,
    required this.seedQuantity,
    required this.soilPreparationSteps,
    required this.fertilizerSchedule,
    required this.irrigationSchedule,
    required this.pesticideNeeds,
    required this.weedManagement,
    required this.expectedYield,
    required this.expectedProfit,
    required this.benefits,
    required this.drawbacks,
    required this.growthRequirements,
    required this.harvestMethod,
    required this.marketDemand,
    required this.description,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['crop_name'] ?? 'Unknown',
      cropNameHindi: json['crop_name_hindi'] ?? '',
      suitability: json['suitability'] ?? 'Moderate',
      season: json['season'] ?? 'All Season',
      bestPlantingMonth: json['best_planting_month'] ?? 'N/A',
      growthDurationDays: _toInt(json['growth_duration_days']),
      cropAgeStages: json['crop_age_stages'] ?? 'N/A',
      seedQuantity: json['seed_quantity'] ?? 'N/A',
      soilPreparationSteps: List<String>.from(json['soil_preparation_steps'] ?? []),
      fertilizerSchedule: json['fertilizer_schedule'] ?? 'N/A',
      irrigationSchedule: json['irrigation_schedule'] ?? 'N/A',
      pesticideNeeds: json['pesticide_needs'] ?? 'N/A',
      weedManagement: json['weed_management'] ?? 'N/A',
      expectedYield: json['expected_yield'] ?? 'N/A',
      expectedProfit: json['expected_profit'] ?? 'N/A',
      benefits: List<String>.from(json['benefits'] ?? []),
      drawbacks: List<String>.from(json['drawbacks'] ?? []),
      growthRequirements: List<String>.from(json['growth_requirements'] ?? []),
      harvestMethod: json['harvest_method'] ?? 'N/A',
      marketDemand: json['market_demand'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'crop_name_hindi': cropNameHindi,
        'suitability': suitability,
        'season': season,
        'best_planting_month': bestPlantingMonth,
        'growth_duration_days': growthDurationDays,
        'crop_age_stages': cropAgeStages,
        'seed_quantity': seedQuantity,
        'soil_preparation_steps': soilPreparationSteps,
        'fertilizer_schedule': fertilizerSchedule,
        'irrigation_schedule': irrigationSchedule,
        'pesticide_needs': pesticideNeeds,
        'weed_management': weedManagement,
        'expected_yield': expectedYield,
        'expected_profit': expectedProfit,
        'benefits': benefits,
        'drawbacks': drawbacks,
        'growth_requirements': growthRequirements,
        'harvest_method': harvestMethod,
        'market_demand': marketDemand,
        'description': description,
      };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
