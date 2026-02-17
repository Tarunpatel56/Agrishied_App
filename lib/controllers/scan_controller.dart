import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ScanController extends GetxController {
  var isLoading = false.obs;
  var scanResult = <String, dynamic>{}.obs; // Empty map
  final String baseUrl = 'http://10.179.18.46:5000';

  Future<void> pickAndScan() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    isLoading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze-crop'));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        scanResult.value = json.decode(data);
      }
    } catch (e) {
      Get.snackbar("Error", "Connection fail: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}