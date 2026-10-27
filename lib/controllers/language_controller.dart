import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _storage = GetStorage();
  var currentLanguage = 'hi'.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<String>('app_language');
    if (saved != null && (saved == 'hi' || saved == 'en')) {
      currentLanguage.value = saved;
    } else {
      currentLanguage.value = 'hi'; // Default friendly language for Indian farmers
    }
  }

  Locale get currentLocale {
    if (currentLanguage.value == 'en') {
      return const Locale('en', 'US');
    }
    return const Locale('hi', 'IN');
  }

  bool get isHindi => currentLanguage.value == 'hi';

  static bool get isAppHindi =>
      Get.isRegistered<LanguageController>() ? Get.find<LanguageController>().isHindi : (Get.locale?.languageCode == 'hi');

  void changeLanguage(String langCode) {
    if (langCode == 'en') {
      currentLanguage.value = 'en';
      Get.updateLocale(const Locale('en', 'US'));
      _storage.write('app_language', 'en');
    } else {
      currentLanguage.value = 'hi';
      Get.updateLocale(const Locale('hi', 'IN'));
      _storage.write('app_language', 'hi');
    }
  }

  void toggleLanguage() {
    if (currentLanguage.value == 'hi') {
      changeLanguage('en');
    } else {
      changeLanguage('hi');
    }
  }
}
