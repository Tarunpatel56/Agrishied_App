import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.result.value == null) return const Center(child: Text("Fasal ki photo lein"));

        final data = controller.result.value!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _infoCard("Fasal ki Jankari", [
              _row("Fasal", data.cropType),
              _row("Growth Stage", data.growthStage),
              _row("Umra (Age)", "${data.estimatedAge} Din"),
            ]),
            _infoCard("Prediction & Risk", [
              _row("Harvest Date", data.expectedHarvest),
              _row("Days Left", "${data.daysToHarvest}"),
              _row("Risk", "${data.riskPercent}%"),
            ]),
            _advisoryCard(data.advisory),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.scanCrop,
        label: const Text("Scan Now"),
        icon: const Icon(Icons.camera),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
    ),
  );

  Widget _advisoryCard(String text) => Card(
    color: Colors.green[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text("💡 Advisory: $text"),
    ),
  );
}