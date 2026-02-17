import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/crop_model.dart';

class ScanController extends GetxController {
  var isLoading = false.obs;
  var result = Rxn<CropModel>(); // Model based result

  final String apiUrl = 'http://10.179.18.46:5000/analyze-crop';

  Future<void> scanCrop() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    isLoading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', photo.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        result.value = CropModel.fromJson(json.decode(data));
      }
    } catch (e) {
      Get.snackbar("Error", "Backend connect nahi ho raha");
    } finally {
      isLoading.value = false;
    }
  }
}