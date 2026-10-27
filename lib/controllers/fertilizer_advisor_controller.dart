import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class FertilizerAdvisorController extends GetxController {
  final cropController = TextEditingController();
  final areaController = TextEditingController(text: '2.0');

  var selectedCrop = 'Wheat'.obs;
  var selectedGrowthStage = 'Basal / Sowing'.obs;
  var selectedSoilType = 'Alluvial / Loam'.obs;
  var selectedIrrigation = 'Irrigated'.obs;
  var selectedAreaUnit = 'Acre'.obs;
  var cropAgeDays = 25.0.obs;

  var soilTestAvailable = false.obs;
  var nitrogenStatus = 'Medium'.obs;
  var phosphorusStatus = 'Medium'.obs;
  var potassiumStatus = 'Medium'.obs;

  var isLoading = false.obs;
  var prescription = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  String get baseUrl => AppConfig.baseUrl;
  String get currentLang => Get.locale?.languageCode ?? 'hi';

  final List<String> commonCrops = [
    'Wheat',
    'Rice / Paddy',
    'Soybean',
    'Cotton',
    'Maize',
    'Mustard',
    'Sugarcane',
    'Chickpea / Gram',
    'Potato',
    'Tomato',
    'Onion',
    'Garlic',
    'Groundnut',
  ];

  final List<String> growthStages = [
    'Basal / Sowing',
    'Vegetative / First Irrigation',
    'Tillering / Branching',
    'Flowering / Booting',
    'Fruit / Grain Filling',
  ];

  final List<String> soilTypes = [
    'Alluvial / Loam (दोमट)',
    'Black Soil / Regur (काली मिट्टी)',
    'Red / Laterite (लाल मिट्टी)',
    'Sandy Loam (बलुई दोमट)',
    'Clay Loam (चिकनी मिट्टी)',
  ];

  final List<String> areaUnits = ['Acre', 'Hectare', 'Bigha', 'Guntha'];

  final List<String> nutrientLevels = ['Low', 'Medium', 'High'];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['crop_name'] != null && args['crop_name'].toString().isNotEmpty) {
        final cName = args['crop_name'].toString();
        selectedCrop.value = cName;
        cropController.text = cName;
      }
      if (args['crop_age'] != null) {
        cropAgeDays.value = (args['crop_age'] as num).toDouble();
      }
      if (args['area'] != null) {
        areaController.text = args['area'].toString();
      }
      if (args['auto_calc'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateFertilizer();
        });
      }
    }
  }

  Future<void> calculateFertilizer() async {
    final areaText = areaController.text.trim();
    final areaVal = double.tryParse(areaText);
    if (areaVal == null || areaVal <= 0) {
      Get.snackbar(
        'notice'.tr,
        'please_enter_area'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final crop = cropController.text.trim().isNotEmpty
        ? cropController.text.trim()
        : selectedCrop.value;

    isLoading.value = true;
    errorMessage.value = '';
    prescription.value = null;

    try {
      final payload = {
        'crop_name': crop,
        'growth_stage': selectedGrowthStage.value,
        'soil_type': selectedSoilType.value,
        'irrigation': selectedIrrigation.value,
        'field_area': areaVal,
        'area_unit': selectedAreaUnit.value,
        'crop_age_days': cropAgeDays.value.toInt(),
        'soil_test_available': soilTestAvailable.value,
        'nitrogen_status': nitrogenStatus.value,
        'phosphorus_status': phosphorusStatus.value,
        'potassium_status': potassiumStatus.value,
        'language': currentLang,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/fertilizer-advisor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status'] == 'Success' && res['data'] != null) {
          prescription.value = _normalizeFertilizerData(Map<String, dynamic>.from(res['data']));
        } else {
          errorMessage.value = res['error'] ?? 'calculation_failed'.tr;
        }
      } else {
        errorMessage.value = 'connection_error'.tr;
      }
    } catch (e) {
      errorMessage.value = '${'connection_error'.tr}: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String localizedCropName(String crop, bool isHi) {
    if (!isHi) return crop;
    final map = {
      'Wheat': 'गेहूं (Wheat)',
      'Rice / Paddy': 'धान / चावल (Paddy)',
      'Soybean': 'सोयाबीन (Soybean)',
      'Cotton': 'कपास (Cotton)',
      'Maize': 'मक्का (Maize)',
      'Mustard': 'सरसों (Mustard)',
      'Sugarcane': 'गन्ना (Sugarcane)',
      'Chickpea / Gram': 'चना (Gram)',
      'Potato': 'आलू (Potato)',
      'Tomato': 'टमाटर (Tomato)',
      'Onion': 'प्याज (Onion)',
      'Garlic': 'लहसुन (Garlic)',
      'Groundnut': 'मूंगफली (Groundnut)',
    };
    return map[crop] ?? crop;
  }

  String localizedUnit(String unit, bool isHi) {
    if (!isHi) return unit;
    final map = {
      'Acre': 'एकड़ (Acre)',
      'Hectare': 'हेक्टेयर (Hectare)',
      'Bigha': 'बीघा (Bigha)',
      'Guntha': 'गुंठा (Guntha)',
    };
    return map[unit] ?? unit;
  }

  Map<String, dynamic> _normalizeFertilizerData(Map<String, dynamic> raw) {
    final norm = Map<String, dynamic>.from(raw);
    final isHi = currentLang == 'hi';

    // 1. Calculated acres
    if (norm['calculated_acres'] == null) {
      norm['calculated_acres'] = norm['area_in_acres'] ?? norm['farm_area'] ?? areaController.text;
    }

    // 2. Pure nutrients
    if (norm['pure_nutrients_kg'] == null && norm['pure_nutrients_required'] is Map) {
      final pnr = Map<String, dynamic>.from(norm['pure_nutrients_required']);
      norm['pure_nutrients_kg'] = {
        'N': pnr['nitrogen_kg'] ?? pnr['N'] ?? 0,
        'P2O5': pnr['phosphate_p2o5_kg'] ?? pnr['P2O5'] ?? pnr['P'] ?? 0,
        'K2O': pnr['potash_k2o_kg'] ?? pnr['K2O'] ?? pnr['K'] ?? 0,
      };
    }

    // 3. Fertilizer Items List (converting commercial_fertilizers Map to List if needed)
    if ((norm['fertilizer_items'] == null || (norm['fertilizer_items'] is List && (norm['fertilizer_items'] as List).isEmpty)) &&
        norm['commercial_fertilizers'] is Map) {
      final cf = Map<String, dynamic>.from(norm['commercial_fertilizers']);
      final List<Map<String, dynamic>> items = [];

      cf.forEach((key, val) {
        if (val is Map) {
          final v = Map<String, dynamic>.from(val);
          String pName = isHi ? (v['product_name_hi'] ?? v['product_name'] ?? '') : (v['product_name'] ?? v['product_name_hi'] ?? '');
          if (isHi) {
            if (key.contains('urea')) pName = 'नीम लेपित यूरिया (46% N)';
            if (key.contains('dap')) pName = 'डीएपी (18% N, 46% P₂O₅)';
            if (key.contains('mop')) pName = 'एमओपी पोटाश (60% K₂O)';
          }
          final totalKg = v['quantity_kg'] ?? v['total_kg'] ?? 0;
          final bagSize = v['bags_45kg'] != null ? 45 : (v['bags_50kg'] != null ? 50 : (v['bag_size_kg'] ?? 50));
          final bagsCount = v['bags_45kg'] ?? v['bags_50kg'] ?? v['bags_count'] ?? (totalKg / bagSize);
          final wholeBags = (bagsCount is num) ? bagsCount.ceil() : 1;
          final remainingKg = ((wholeBags * bagSize) - (totalKg as num)).clamp(0, bagSize);

          items.add({
            'name': pName,
            'total_kg': totalKg,
            'bag_size_kg': bagSize,
            'bags_count': bagsCount,
            'bags_whole_to_buy': wholeBags,
            'remaining_buffer_kg': remainingKg,
            'purpose': isHi
                ? (key.contains('urea')
                    ? 'वानस्पतिक बढ़वार और पत्तियों में हरियाली हेतु'
                    : (key.contains('dap')
                        ? 'जड़ों के गहरे फैलाव और कल्ले फूटने हेतु'
                        : 'दानों की चमक, वजन और रोग प्रतिरोधक क्षमता हेतु'))
                : (v['purpose'] ?? 'Essential crop nutrition'),
          });
        }
      });
      norm['fertilizer_items'] = items;
    }

    // 4. Split application schedule
    if ((norm['split_schedule'] == null || (norm['split_schedule'] is List && (norm['split_schedule'] as List).isEmpty)) &&
        norm['application_schedule'] is List) {
      final List rawSplits = norm['application_schedule'];
      final List<Map<String, dynamic>> splits = [];

      for (var s in rawSplits) {
        if (s is Map) {
          final sm = Map<String, dynamic>.from(s);
          String stage = isHi ? (sm['stage_hi'] ?? sm['stage'] ?? 'बुवाई के समय') : (sm['stage'] ?? sm['stage_hi'] ?? 'Sowing Stage');
          if (isHi) {
            final sLow = stage.toLowerCase();
            if (sLow.contains('basal') || sLow.contains('sow')) stage = 'बुवाई के समय (बेसल डोज)';
            else if (sLow.contains('first') || sLow.contains('vegetative')) stage = 'प्रथम सिंचाई / 20-25 दिन पर';
            else if (sLow.contains('second') || sLow.contains('tillering')) stage = 'दूसरी सिंचाई / 45-50 दिन पर';
            else if (sLow.contains('flowering') || sLow.contains('boot')) stage = 'फूल / बालियां बनते समय';
          }

          final List<String> fList = [];
          if ((sm['urea_kg'] ?? 0) > 0) fList.add(isHi ? 'यूरिया: ${sm['urea_kg']} कि.ग्रा.' : 'Urea: ${sm['urea_kg']} kg');
          if ((sm['dap_kg'] ?? 0) > 0) fList.add(isHi ? 'डीएपी: ${sm['dap_kg']} कि.ग्रा.' : 'DAP: ${sm['dap_kg']} kg');
          if ((sm['mop_kg'] ?? 0) > 0) fList.add(isHi ? 'पोटाश (MOP): ${sm['mop_kg']} कि.ग्रा.' : 'MOP: ${sm['mop_kg']} kg');
          final fertText = sm['fertilizers'] ?? (fList.isNotEmpty ? fList.join(', ') : (isHi ? 'आवश्यक उर्वरक' : 'Required Fertilizers'));

          splits.add({
            'stage': stage,
            'timing': isHi ? (sm['timing_hi'] ?? sm['timing'] ?? '') : (sm['timing'] ?? sm['timing_hi'] ?? ''),
            'fertilizers': fertText,
            'method': isHi ? (sm['method_hi'] ?? 'खेत में समान रूप से बुरकाव करें अथवा कूंड़ में डालें') : (sm['method'] ?? 'Broadcast evenly across field'),
            'importance': isHi ? (sm['notes_hi'] ?? sm['importance_hi'] ?? 'फसल की प्रारंभिक जड़ों व वानस्पतिक वृद्धि हेतु अति आवश्यक।') : (sm['notes'] ?? ''),
          });
        }
      }
      norm['split_schedule'] = splits;
    }

    // 5. Tips and Advice
    if (norm['soil_health_tips'] == null || (norm['soil_health_tips'] is List && (norm['soil_health_tips'] as List).isEmpty)) {
      final List<String> tips = [];
      if (isHi) {
        tips.addAll([
          'जिंक सल्फेट (21%) 10 कि.ग्रा. प्रति एकड़ बुवाई के समय अवश्य डालें, इसे कभी भी डीएपी के साथ न मिलाएं।',
          'मिट्टी में जीवांश कार्बन बढ़ाने हेतु हर 2-3 वर्ष में सड़ी गोबर की खाद या वर्मीकम्पोस्ट अवश्य प्रयोग करें।',
          'यूरिया का प्रयोग हमेशा 2 से 3 किस्तों में करें ताकि नाइट्रोजन का लीचिंग से नुकसान न हो।',
        ]);
      } else {
        if (norm['micronutrient_advice'] != null) tips.add(norm['micronutrient_advice'].toString());
        if (norm['soil_test_recommendation'] != null) tips.add(norm['soil_test_recommendation'].toString());
      }
      norm['soil_health_tips'] = tips;
    }

    // 6. AI Explanation
    if (norm['ai_explanation'] == null || norm['ai_explanation'].toString().isEmpty) {
      norm['ai_explanation'] = isHi
          ? (norm['calculation_basis_hi'] ?? 'यह उर्वरक संस्तुति भारतीय कृषि अनुसंधान परिषद (ICAR) एवं राज्य कृषि विश्वविद्यालय के वैज्ञानिक मानकों के आधार पर तैयार की गई है।')
          : (norm['calculation_basis'] ?? 'This recommendation is calculated using ICAR / SAU agronomic nutrition standards.');
    }

    return norm;
  }

  @override
  void onClose() {
    cropController.dispose();
    areaController.dispose();
    super.onClose();
  }
}
