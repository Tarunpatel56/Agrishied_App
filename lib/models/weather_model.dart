class WeatherModel {
  final double temperature;
  final double tempMax;
  final double tempMin;
  final double rainfall;
  final int humidity;
  final double solarRadiation;
  final double windSpeed;
  final String condition;
  final String status;
  final String advisory;
  final String timestamp;
  final String date;
  final List<WeatherAlert> alerts;
  final CropImpact cropImpact;

  WeatherModel({
    required this.temperature,
    this.tempMax = 0,
    this.tempMin = 0,
    required this.rainfall,
    required this.humidity,
    this.solarRadiation = 0,
    this.windSpeed = 0,
    this.condition = '',
    required this.status,
    required this.advisory,
    required this.timestamp,
    this.date = '',
    this.alerts = const [],
    required this.cropImpact,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      tempMax: (json['temp_max'] ?? 0.0).toDouble(),
      tempMin: (json['temp_min'] ?? 0.0).toDouble(),
      rainfall: (json['rainfall'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0).toInt(),
      solarRadiation: (json['solar_radiation'] ?? 0.0).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
      advisory: json['advisory'] ?? 'N/A',
      timestamp: json['timestamp'] ?? 'N/A',
      date: json['date'] ?? '',
      alerts: (json['alerts'] as List?)
              ?.map((a) => WeatherAlert.fromJson(a))
              .toList() ??
          [],
      cropImpact: CropImpact.fromJson(json['crop_impact'] ?? {}),
    );
  }
}

class WeatherAlert {
  final String type;
  final String message;

  WeatherAlert({required this.type, required this.message});

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      type: json['type'] ?? 'info',
      message: json['message'] ?? '',
    );
  }
}

class CropImpact {
  final String growthSpeed;
  final String diseaseRisk;
  final String irrigationNeed;

  CropImpact({
    required this.growthSpeed,
    required this.diseaseRisk,
    required this.irrigationNeed,
  });

  factory CropImpact.fromJson(Map<String, dynamic> json) {
    return CropImpact(
      growthSpeed: json['growth_speed'] ?? 'Normal',
      diseaseRisk: json['disease_risk'] ?? 'Low',
      irrigationNeed: json['irrigation_need'] ?? 'Normal',
    );
  }
}