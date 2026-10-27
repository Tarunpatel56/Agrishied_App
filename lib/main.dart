import 'package:agrishield_app/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'config/app_config.dart';
import 'localization/app_translations.dart';
import 'controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  // Initialize LanguageController
  final langController = Get.put(LanguageController(), permanent: true);

  // Auto-discover and connect to local backend (USB adb-reverse / Wi-Fi)
  try {
    await AppConfig.autoDiscoverBackend().timeout(const Duration(seconds: 2));
  } catch (_) {}

  runApp(MyApp(langController: langController));
}

class MyApp extends StatelessWidget {
  final LanguageController? langController;
  const MyApp({super.key, this.langController});

  @override
  Widget build(BuildContext context) {
    final controller = langController ??
        (Get.isRegistered<LanguageController>()
            ? Get.find<LanguageController>()
            : Get.put(LanguageController()));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriShield AI',
      translations: AppTranslations(),
      locale: controller?.currentLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}