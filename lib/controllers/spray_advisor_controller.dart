import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'scan_controller.dart';

class SprayAdvisorController extends GetxController {
  final cropController = TextEditingController();
  final symptomsController = TextEditingController();

  var selectedCrop = 'Soybean'.obs;
  var selectedGrowthStage = 'Vegetative'.obs;
  var selectedPart = 'Leaves'.obs;
  var selectedSeverity = 'Moderate'.obs;
  var selectedSpread = 'Patches'.obs;
  var selectedProvider = 'gemini'.obs;
  var cropAgeDays = 25.0.obs;

  var isLoading = false.obs;
  var prescription = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;
  File? attachedImage;

  String get baseUrl => AppConfig.baseUrl;
  String get currentLang => Get.locale?.languageCode ?? 'hi';

  final List<String> commonCrops = [
    'Wheat',
    'Rice / Paddy',
    'Cotton',
    'Soybean',
    'Tomato',
    'Maize',
    'Mustard',
    'Gram / Chickpea',
    'Potato',
    'Onion',
    'Garlic',
    'Chilli',
  ];

  final List<String> growthStages = [
    'Sowing / Germination',
    'Vegetative',
    'Tillering / Branching',
    'Flowering',
    'Fruit / Grain Formation',
    'Pre-Harvest',
  ];

  final List<String> plantParts = [
    'Leaves',
    'Stem',
    'Roots',
    'Flowers',
    'Fruit / Pods',
    'Whole Plant',
  ];

  final List<String> severities = ['Mild', 'Moderate', 'Severe'];

  @override
  void onInit() {
    super.onInit();
    // Check if arguments were passed from last scan or direct navigation
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['crop_name'] != null && args['crop_name'].toString().isNotEmpty) {
        selectedCrop.value = args['crop_name'].toString();
        cropController.text = args['crop_name'].toString();
      }
      if (args['disease'] != null && args['disease'].toString().isNotEmpty) {
        symptomsController.text = args['disease'].toString();
      }
      if (args['crop_age'] != null) {
        cropAgeDays.value = (args['crop_age'] as num).toDouble();
      }
      if (args['auto_fetch'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fetchSprayPrescription();
        });
      }
    }
  }

  Future<void> fetchSprayPrescription() async {
    final crop = cropController.text.trim().isNotEmpty
        ? cropController.text.trim()
        : selectedCrop.value;

    if (crop.isEmpty) {
      Get.snackbar(
        'notice'.tr,
        'please_enter_crop'.tr,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    prescription.value = null;

    try {
      final payload = {
        'crop_name': crop,
        'growth_stage': selectedGrowthStage.value,
        'symptoms': symptomsController.text.trim(),
        'affected_parts': selectedPart.value,
        'severity': selectedSeverity.value,
        'spread': selectedSpread.value,
        'language': currentLang,
        'provider': selectedProvider.value,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/crop-spray-advisor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status'] == 'Success' && res['data'] != null) {
          prescription.value = _normalizeSprayData(Map<String, dynamic>.from(res['data']));
        } else {
          errorMessage.value = res['error'] ?? 'analysis_failed'.tr;
        }
      } else {
        final err = json.decode(response.body);
        errorMessage.value = err['error'] ?? 'connection_error'.tr;
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
      'Cotton': 'कपास (Cotton)',
      'Soybean': 'सोयाबीन (Soybean)',
      'Tomato': 'टमाटर (Tomato)',
      'Maize': 'मक्का (Maize)',
      'Mustard': 'सरसों (Mustard)',
      'Gram / Chickpea': 'चना (Gram)',
      'Potato': 'आलू (Potato)',
      'Onion': 'प्याज (Onion)',
      'Garlic': 'लहसुन (Garlic)',
      'Chilli': 'मिर्च (Chilli)',
    };
    return map[crop] ?? crop;
  }

  Map<String, dynamic> _normalizeSprayData(Map<String, dynamic> raw) {
    final norm = Map<String, dynamic>.from(raw);
    final isHi = currentLang == 'hi';

    // 1. Problem / Issue identification
    if (norm['identified_issue'] == null || norm['identified_issue'].toString().isEmpty) {
      final pHi = norm['identified_problem_hi']?.toString();
      final pEn = norm['identified_problem']?.toString();
      norm['identified_issue'] = isHi ? (pHi ?? pEn ?? 'पहचाना गया रोग / कीट') : (pEn ?? pHi ?? 'Identified Problem');
    }
    if (norm['identified_issue_hindi'] == null) {
      norm['identified_issue_hindi'] = norm['identified_problem_hi'] ?? norm['identified_issue'];
    }

    // 2. Chemical Recommendation
    if (norm['chemical_recommendation'] == null && norm['chemical_treatment'] is Map) {
      final ct = Map<String, dynamic>.from(norm['chemical_treatment']);
      norm['chemical_recommendation'] = {
        'active_ingredient': isHi ? (ct['active_ingredient_hi'] ?? ct['active_ingredient']) : (ct['active_ingredient'] ?? ct['active_ingredient_hi']),
        'commercial_names': ct['trade_names'] ?? ct['brand_names'] ?? ct['commercial_names'] ?? (isHi ? 'उपलब्ध CIBRC ब्रांड' : 'CIBRC Registered Brands'),
        'dosage_per_liter': ct['dosage_per_liter'] ?? (isHi ? '2 मिली / लीटर' : '2 ml/L'),
        'dosage_per_acre': ct['dosage_per_acre'] ?? (isHi ? '250-300 मिली / एकड़' : '250-300 ml/acre'),
        'water_volume': isHi ? '150-200 लीटर' : '150-200 L',
        'water_volume_per_acre': isHi ? '150-200 लीटर' : '150-200 L',
        'application_method': isHi ? 'नैपसैक स्प्रेयर से पर्णीय छिड़काव' : 'Foliar spray',
        'application_timing': isHi ? 'सुबह जल्दी (8-10 बजे) या शांत शाम (4-6 बजे)' : 'Early morning or late afternoon',
        'phi_days': isHi ? (ct['waiting_period_hi'] ?? '14 दिन') : (ct['waiting_period'] ?? '14 days'),
        'registration_source': isHi ? 'सीआईबीआरसी (CIBRC) पंजीकृत संस्तुति' : 'CIBRC Registered Recommendation',
      };
      if (ct['safety_precautions'] != null && norm['safety_guidelines'] == null) {
        norm['safety_guidelines'] = [ct['safety_precautions'].toString()];
      }
    }

    // 3. Organic Alternative / Biological Control
    if (norm['organic_alternative'] == null && (norm['biological_control'] != null || norm['biological_control_hi'] != null)) {
      final bio = isHi ? (norm['biological_control_hi'] ?? norm['biological_control']) : (norm['biological_control'] ?? norm['biological_control_hi']);
      norm['organic_alternative'] = {
        'product_name': bio,
        'dosage': isHi ? '2-3 मिली या 5 ग्राम प्रति लीटर पानी' : '2-3 ml or 5 g per liter of water',
        'method': isHi ? 'पत्तियों पर समान रूप से छिड़काव करें' : 'Thorough foliar coverage',
      };
    }

    // 4. Cultural Management & Mixing Warning
    if (norm['cultural_management'] != null || norm['cultural_management_hi'] != null) {
      norm['cultural_guidelines'] = isHi
          ? (norm['cultural_management_hi'] ?? norm['cultural_management'])
          : (norm['cultural_management'] ?? norm['cultural_management_hi']);
    }
    if (norm['mixing_warning'] != null || norm['mixing_warning_hi'] != null) {
      norm['mixing_alert'] = isHi
          ? (norm['mixing_warning_hi'] ?? norm['mixing_warning'])
          : (norm['mixing_warning'] ?? norm['mixing_warning_hi']);
    }

    // 5. Safety guidelines translation into Hindi
    if (isHi) {
      norm['safety_guidelines'] = [
        'छिड़काव करते समय सुरक्षात्मक किट (मास्क, चश्मा, रबर दस्ताने) अवश्य पहनें।',
        'दवाई डालने के दौरान कुछ भी न खाएं, न पिएं और न ही धूम्रपान करें।',
        'हवा की दिशा के विपरीत स्प्रे न करें ताकि दवा शरीर पर न पड़े।',
        'दवा को बच्चों, पशुओं और खाद्य पदार्थों से दूर सुरक्षित स्थान पर रखें।',
        'स्प्रे पूरा होने के बाद हाथ-मुंह अच्छी तरह साबुन से धोएं और कपड़े बदलें।',
      ];
    }

    return norm;
  }

  void loadFromLastScan() async {
    try {
      // 1. First check in-memory ScanController if available
      if (Get.isRegistered<ScanController>()) {
        final scanCtrl = Get.find<ScanController>();
        final scan = scanCtrl.result.value;
        if (scan != null) {
          if (scan.cropName.isNotEmpty && scan.cropName != 'Unknown') {
            selectedCrop.value = scan.cropName;
            cropController.text = scan.cropName;
          }
          final issue = (scan.disease.isNotEmpty && scan.disease != 'N/A')
              ? scan.disease
              : (scan.pestDetected.isNotEmpty && scan.pestDetected != 'No pest detected')
                  ? scan.pestDetected
                  : (scan.healthStatus.isNotEmpty ? scan.healthStatus : 'Healthy');
          symptomsController.text = issue;

          final parsedAge = double.tryParse(scan.age.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (parsedAge != null && parsedAge > 0) {
            cropAgeDays.value = parsedAge;
          }

          Get.snackbar(
            'success'.tr,
            currentLang == 'hi'
                ? 'स्कैन डेटा लोड हो गया (${selectedCrop.value} - $issue)'
                : 'Loaded scan: ${selectedCrop.value} ($issue)',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // 2. Fallback to backend /last-scan endpoint
      final response = await http.get(Uri.parse('$baseUrl/last-scan')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final data = res['data'] ?? res;
        final crop = data['crop_name'] ?? data['crop'];
        final disease = data['disease'] ?? data['identified_issue'] ?? data['prediction'];
        final age = data['age'] ?? data['crop_age'];

        if (crop != null && crop.toString().isNotEmpty) {
          selectedCrop.value = crop.toString();
          cropController.text = crop.toString();
        }
        if (disease != null && disease.toString().isNotEmpty) {
          symptomsController.text = disease.toString();
        }
        if (age != null) {
          final parsedAge = double.tryParse(age.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
          if (parsedAge != null && parsedAge > 0) {
            cropAgeDays.value = parsedAge;
          }
        }

        Get.snackbar(
          'success'.tr,
          currentLang == 'hi'
              ? 'हालिया स्कैन डेटा लोड हो गया ($crop - $disease)'
              : 'Loaded last scan: $crop ($disease)',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'notice'.tr,
          currentLang == 'hi' ? 'कोई हालिया स्कैन उपलब्ध नहीं है' : 'No recent scan found',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'notice'.tr,
        currentLang == 'hi' ? 'कोई हालिया स्कैन उपलब्ध नहीं है' : 'No recent scan found',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    cropController.dispose();
    symptomsController.dispose();
    super.onClose();
  }
}
