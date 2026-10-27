class MarketModel {
  final String id;
  final String cropName;
  final String cropNameHindi;
  final String currentPrice;
  final String minPrice;
  final String maxPrice;
  final String modalPrice;
  final String unit;
  final String trend;
  final String trendPct;
  final String marketName;
  final String state;
  final String district;
  final String priceType;
  final String dataSource;
  final String lastUpdated;
  final int arrivalQuintals;

  static const Map<String, String> _cropHindiMap = {
    'wheat': 'गेहूं',
    'rice': 'चावल / धान',
    'paddy': 'धान',
    'maize': 'मक्का',
    'corn': 'मक्का',
    'soybean': 'सोयाबीन',
    'cotton': 'कपास',
    'mustard': 'सरसों',
    'sugarcane': 'गन्ना',
    'chickpea': 'चना',
    'gram': 'चना',
    'potato': 'आलू',
    'tomato': 'टमाटर',
    'onion': 'प्याज',
    'garlic': 'लहसुन',
    'groundnut': 'मूंगफली',
    'coriander': 'धनिया',
    'cumin': 'जीरा',
    'turmeric': 'हल्दी',
    'ginger': 'अदरक',
    'chilli': 'मिर्च',
    'chili': 'मिर्च',
    'moong': 'मूंग',
    'urad': 'उड़द',
    'arhar': 'अरहर / तुअर',
    'tur': 'तुअर',
    'barley': 'जौ',
    'millet': 'बाजरा',
    'bajra': 'बाजरा',
    'jowar': 'ज्वार',
  };

  MarketModel({
    this.id = '',
    required this.cropName,
    this.cropNameHindi = '',
    required this.currentPrice,
    this.minPrice = '',
    this.maxPrice = '',
    this.modalPrice = '',
    required this.unit,
    required this.trend,
    this.trendPct = '',
    required this.marketName,
    this.state = '',
    this.district = '',
    this.priceType = 'Actual Reported Market Price',
    this.dataSource = 'Agmarknet / Mandi Board',
    required this.lastUpdated,
    this.arrivalQuintals = 0,
  });

  String localizedCropName(bool isHi) {
    if (!isHi) return cropName;
    if (cropNameHindi.isNotEmpty) return cropNameHindi;
    final lower = cropName.trim().toLowerCase();
    for (var entry in _cropHindiMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return cropName;
  }

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    final cName = json['crop_name'] ?? json['commodity'] ?? "N/A";
    final cNameHi = json['crop_name_hindi'] ?? json['crop_name_hi'] ?? json['commodity_hi'] ?? '';
    return MarketModel(
      id: json['id']?.toString() ?? '',
      cropName: cName,
      cropNameHindi: cNameHi.toString(),
      currentPrice: json['current_price']?.toString() ?? json['modal_price']?.toString() ?? "N/A",
      minPrice: json['min_price']?.toString() ?? '',
      maxPrice: json['max_price']?.toString() ?? '',
      modalPrice: json['modal_price']?.toString() ?? json['current_price']?.toString() ?? '',
      unit: json['unit'] ?? "₹/Quintal",
      trend: json['trend'] ?? "Stable",
      trendPct: json['trend_pct']?.toString() ?? '',
      marketName: json['market_name'] ?? json['mandi'] ?? "APMC Mandi",
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      priceType: json['price_type']?.toString() ?? 'Actual Reported Market Price',
      dataSource: json['data_source']?.toString() ?? 'Agmarknet / Mandi Board',
      lastUpdated: json['last_updated'] ?? "Latest",
      arrivalQuintals: (json['arrival_quintals'] is int)
          ? json['arrival_quintals']
          : int.tryParse(json['arrival_quintals']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_name': cropName,
      'current_price': currentPrice,
      'min_price': minPrice,
      'max_price': maxPrice,
      'modal_price': modalPrice,
      'unit': unit,
      'trend': trend,
      'trend_pct': trendPct,
      'market_name': marketName,
      'state': state,
      'district': district,
      'price_type': priceType,
      'data_source': dataSource,
      'last_updated': lastUpdated,
      'arrival_quintals': arrivalQuintals,
    };
  }
}