import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class GovtSchemesController extends GetxController {
  var isLoading = true.obs;
  var schemes = <Map<String, dynamic>>[].obs;
  var filteredSchemes = <Map<String, dynamic>>[].obs;
  var selectedCategory = 'all'.obs;
  var searchQuery = ''.obs;

  String get baseUrl => AppConfig.baseUrl;
  String get currentLang => Get.locale?.languageCode ?? 'hi';

  @override
  void onInit() {
    super.onInit();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    isLoading(true);
    try {
      final uri = Uri.parse('$baseUrl/govt-schemes').replace(queryParameters: {
        'language': currentLang,
        if (selectedCategory.value != 'all') 'category': selectedCategory.value,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          final List items = data['data'] ?? [];
          schemes.assignAll(List<Map<String, dynamic>>.from(items));
          _applyLocalFilter();
        }
      }
    } catch (e) {
      print('[GovtSchemes] Fetch Error: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterCategory(String category) {
    selectedCategory.value = category;
    _applyLocalFilter();
  }

  void filterSearch(String query) {
    searchQuery.value = query;
    _applyLocalFilter();
  }

  void _applyLocalFilter() {
    var list = schemes.toList();
    final q = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value.trim().toLowerCase();

    if (cat != 'all' && cat != 'सभी') {
      list = list.where((s) {
        final c = (s['category'] ?? '').toString().toLowerCase();
        final sn = (s['short_name'] ?? '').toString().toLowerCase();
        return c.contains(cat) || sn.contains(cat);
      }).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((s) {
        final title = (s['title'] ?? '').toString().toLowerCase();
        final desc = (s['description'] ?? '').toString().toLowerCase();
        final benefit = (s['benefit'] ?? '').toString().toLowerCase();
        return title.contains(q) || desc.contains(q) || benefit.contains(q);
      }).toList();
    }

    filteredSchemes.assignAll(list);
  }
}
