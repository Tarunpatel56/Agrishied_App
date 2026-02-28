import 'package:agrishield_app/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart'; // Required import for local storage
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Add other imports here

void main() async {
  
  // 1. Flutter bindings must be initialized when using 'async' in main
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  
  // 2. Initialize GetStorage so data can be saved locally
  await GetStorage.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp when using GetX
      debugShowCheckedModeBanner: false,
      title: 'AgriShield AI',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}