import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/scan_model.dart';

class ScanController extends GetxController {
  var isLoading = false.obs;
  var result = Rxn<ScanModel>();
  var selectedImage = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  // Backend API URL - your laptop's IP for physical device testing
  static const String baseUrl = 'http://10.179.18.46:5000';

  /// Pick image from Camera
  Future<void> scanFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      selectedImage.value = File(image.path);
      await _analyzeImage(image.path);
    }
  }

  /// Pick image from Gallery
  Future<void> scanFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      selectedImage.value = File(image.path);
      await _analyzeImage(image.path);
    }
  }

  /// Send image to backend for AI analysis
  Future<void> _analyzeImage(String imagePath) async {
    isLoading(true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send().timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw Exception('Analysis timeout - please try again');
        },
      );

      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'Success') {
        var d = jsonResponse['data'];
        result.value = ScanModel.fromJson(d);
      } else {
        Get.snackbar(
          "Analysis Failed",
          jsonResponse['error']?.toString() ?? "Unknown error occurred",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Connection Error",
        "Cannot reach AgriShield server. Make sure backend is running.",
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Show image source picker dialog
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Analyze Your Crop",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose how to capture your crop image",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  color: Colors.green,
                  onTap: () {
                    Get.back();
                    scanFromCamera();
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  color: Colors.blue,
                  onTap: () {
                    Get.back();
                    scanFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}