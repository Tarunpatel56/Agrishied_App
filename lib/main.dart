import 'package:agrishield_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart'; // Ye import zaroori hai
import 'package:get/get.dart';
// Apne baaki imports bhi yahan rakhein

void main() async {
  // 1. Flutter bindings initialize karna zaroori hai jab hum 'async' use karte hain
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. GetStorage ko initialize karein taaki data save ho sake
  await GetStorage.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // GetMaterialApp use karein agar GetX use kar rahe hain
      debugShowCheckedModeBanner: false,
      title: 'AgriShield AI',
      theme: ThemeData(primarySwatch: Colors.green),
      home:  HomeScreen(), // Ya jo bhi aapka pehla page hai
    );
  }
}