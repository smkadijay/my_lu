// cloudinary_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({required this.cloudName, required this.uploadPreset});

  Future<String> uploadFile(File file, {required String resourceType}) async {
    // resourceType: 'image' | 'video' | 'auto' (auto handles docs too)
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final parts = mimeType.split('/');
    final fileStream = http.MultipartFile.fromBytes(
      'file',
      await file.readAsBytes(),
      filename: file.path.split('/').last,
      contentType: MediaType(parts[0], parts[1]),
    );

    request.files.add(await fileStream);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      // Return secure_url
      return data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }
  }
}
