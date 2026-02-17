import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller ko yahan inject karein
    final controller = Get.put(WeatherController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.weatherData.isEmpty) {
          return const Center(child: Text("Mausam ka data nahi mil raha"));
        }

        var data = controller.weatherData;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _weatherCard("Temperature", "${data['temp']}°C", Icons.thermostat, Colors.orange),
              _weatherCard("Humidity", "${data['humidity']}%", Icons.water_drop, Colors.blue),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text("💡 Advisory: ${data['advisory']}", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _weatherCard(String title, String val, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}