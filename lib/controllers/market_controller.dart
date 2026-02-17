import 'package:get/get.dart';

class MarketController extends GetxController {
  var isLoading = false.obs;
  
  // Point 9: Dummy data for Mandi Prices
  // Ise kisan ko rates dikhane ke liye use karenge
  var mandiPrices = [
    {"crop": "Wheat (Gehu)", "price": "₹2,450/Qtl", "trend": "up", "mandi": "Indore"},
    {"crop": "Rice (Chawal)", "price": "₹3,800/Qtl", "trend": "down", "mandi": "Bhopal"},
    {"crop": "Maize (Makka)", "price": "₹2,100/Qtl", "trend": "stable", "mandi": "Ujjain"},
    {"crop": "Soybean", "price": "₹4,600/Qtl", "trend": "up", "mandi": "Indore"},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrices();
  }

  void fetchPrices() async {
    isLoading.value = true;
    // Real API connect karne ke liye yahan logic aayega
    await Future.delayed(const Duration(seconds: 1)); 
    isLoading.value = false;
  }
}