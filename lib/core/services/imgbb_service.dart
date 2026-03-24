import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImgBBService {
  static const String apiKey = '87ac08b1fe96f1eec8ec5a764548dd56';
  static const String apiUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image file to ImgBB and returns the public URL.
  /// Throws an exception if the upload fails.
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['key'] = apiKey;

      // Read bytes and create multipart file
      List<int> imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFile.name.isNotEmpty ? imageFile.name : 'upload.jpg',
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final url = jsonResponse['data']['url'];
          print('✅ ImgBB Upload Success: $url');
          return url;
        } else {
          throw Exception(
            'ImgBB API Error: ${jsonResponse['error']['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to upload image. Status code: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ ImgBB Upload Error: $e');
      rethrow;
    }
  }
}
