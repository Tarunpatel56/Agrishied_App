import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/market_model.dart';
import '../config/app_config.dart';

class MarketController extends GetxController {
  var isLoading = true.obs;
  var isAiTrendLoading = false.obs;
  var allPrices = <MarketModel>[].obs;
  var priceList = <MarketModel>[].obs;
  var selectedState = 'all'.obs;
  var selectedCommodity = 'all'.obs;
  var currentDisclaimer = ''.obs;
  var aiTrendInsight = ''.obs;
  var selectedCropForTrend = ''.obs;
  
  final box = GetStorage();

  String get baseUrl => AppConfig.baseUrl;
  String get currentLang => Get.locale?.languageCode ?? 'hi';

  @override
  void onInit() {
    super.onInit();
    loadOfflineData();
    fetchPrices();
  }

  void loadOfflineData() {
    var storedData = box.read('mandi_cache');
    if (storedData != null) {
      try {
        var list = (storedData as List).map((e) => MarketModel.fromJson(e)).toList();
        allPrices.assignAll(list);
        priceList.assignAll(list);
      } catch (e) {
        print("[MarketController] Cache read error: $e");
      }
    }
  }

  Future<void> fetchPrices() async {
    try {
      isLoading(true);
      final uri = Uri.parse('$baseUrl/mandi-prices').replace(queryParameters: {
        'language': currentLang,
        'format': 'map',
        if (selectedState.value != 'all') 'state': selectedState.value,
        if (selectedCommodity.value != 'all') 'commodity': selectedCommodity.value,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded['market_data'] != null) {
          rawList = decoded['market_data'];
          currentDisclaimer.value = decoded['disclaimer'] ?? '';
        }

        var fetchedList = rawList.map((item) => MarketModel.fromJson(item)).toList();
        
        allPrices.assignAll(fetchedList);
        priceList.assignAll(fetchedList);
        box.write('mandi_cache', fetchedList.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      print("[MarketController] Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void filterState(String state) {
    selectedState.value = state;
    fetchPrices();
  }

  void filterCommodity(String commodity) {
    selectedCommodity.value = commodity;
    fetchPrices();
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      priceList.assignAll(allPrices);
    } else {
      final q = query.toLowerCase();
      priceList.assignAll(allPrices.where((item) =>
          item.cropName.toLowerCase().contains(q) ||
          item.cropNameHindi.toLowerCase().contains(q) ||
          item.marketName.toLowerCase().contains(q) ||
          item.state.toLowerCase().contains(q) ||
          item.district.toLowerCase().contains(q)).toList());
    }
  }

  Future<void> fetchAiTrend(MarketModel item) async {
    isAiTrendLoading.value = true;
    selectedCropForTrend.value = item.cropName;
    aiTrendInsight.value = '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mandi-trend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'crop_name': item.cropName,
          'mandi_name': item.marketName,
          'language': currentLang,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          aiTrendInsight.value = data['data']['ai_trend_analysis'] ?? '';
        }
      }
    } catch (e) {
      aiTrendInsight.value = (currentLang == 'hi')
          ? 'वर्तमान में एआई बाजार विश्लेषण उपलब्ध नहीं है।'
          : 'AI market trend analysis unavailable at the moment.';
    } finally {
      isAiTrendLoading.value = false;
    }
  }
}