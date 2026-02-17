import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'scan_view.dart';
import 'weather_view.dart';
import 'market_view.dart'; // Naya View Import kiya

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt currentIndex = 0.obs;
  
  // Pages list updated for Point 9
  final List<Widget> pages = [
    const ScanView(),
    const WeatherView(),
    const MarketView(), // Market tab add ho gaya
    const Center(child: Text("Insurance Feature (Coming Soon)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgriShield AI System"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() => pages[currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Weather"),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: "Insurance"),
        ],
      )),
    );
  }
}