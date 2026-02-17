import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class MarketView extends StatelessWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketController controller = Get.put(MarketController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.mandiPrices.length,
          itemBuilder: (context, index) {
            var item = controller.mandiPrices[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.store, color: Colors.white),
                ),
                title: Text(item['crop']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Mandi: ${item['mandi']}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    Icon(
                      item['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
                      color: item['trend'] == 'up' ? Colors.green : Colors.red,
                      size: 20,
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}