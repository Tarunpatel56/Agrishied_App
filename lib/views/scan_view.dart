import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart'; // '../' matlab controllers folder mein jao

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller ko yahan initialize kar rahe hain
    final controller = Get.put(ScanController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.scanResult.isEmpty) {
          return const Center(child: Text("Fasal ko scan karne ke liye button dabayein"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: ListTile(
              title: Text("Crop: ${controller.scanResult['crop_type']}"),
              subtitle: Text("Health: ${controller.scanResult['health_score']}%"),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.pickAndScan(),
        child: const Icon(Icons.camera),
      ),
    );
  }
}