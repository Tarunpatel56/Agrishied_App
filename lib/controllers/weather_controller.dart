import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController extends GetxController {
  var isLoading = false.obs;
  var weatherData = {}.obs;
  final String baseUrl = 'http://10.179.18.46:5000';

  @override
  void onInit() {
    super.onInit();
    fetchWeather(); // Screen khulte hi data load hoga
  }

  Future<void> fetchWeather() async {
    try {
      isLoading.value = true;
      // Default location (Indore) ke liye abhi call kar rahe hain
      final response = await http.get(Uri.parse('$baseUrl/weather-advisory?lat=22.7&lon=75.8'));
      
      if (response.statusCode == 200) {
        weatherData.value = json.decode(response.body);
      }
    } catch (e) {
      Get.snackbar("Weather Error", "NASA data fetch nahi ho paya");
    } finally {
      isLoading.value = false;
    }
  }
}