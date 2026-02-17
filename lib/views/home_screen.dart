import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'scan_view.dart';
import 'weather_view.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt currentIndex = 0.obs;
  final List<Widget> pages = [const ScanView(), const WeatherView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Weather"),
        ],
      )),
    );
  }
}