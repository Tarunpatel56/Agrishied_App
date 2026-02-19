class MarketModel {
  final String cropName;
  final String currentPrice; // Kept as String for flexible display
  final String unit;
  final String trend;
  final String marketName;
  final String lastUpdated;

  MarketModel({
    required this.cropName,
    required this.currentPrice,
    required this.unit,
    required this.trend,
    required this.marketName,
    required this.lastUpdated,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      cropName: json['crop_name'] ?? "N/A",
      currentPrice: json['current_price']?.toString() ?? "N/A",
      unit: json['unit'] ?? "Quintal",
      trend: json['trend'] ?? "Live",
      marketName: json['market_name'] ?? "N/A",
      lastUpdated: json['last_updated'] ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_name': cropName,
      'current_price': currentPrice,
      'unit': unit,
      'trend': trend,
      'market_name': marketName,
      'last_updated': lastUpdated,
    };
  }
}