import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/cloudinary_config.dart';

class ImageUploadService {
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      rethrow;
    }
  }

  /// Upload image to Cloudinary
  /// Returns the URL of the uploaded image
  Future<String?> uploadImage(XFile imageFile, String folderName) async {
    try {
      // Generate unique filename
      String fileName = 'thread_${DateTime.now().millisecondsSinceEpoch}';
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Create signature for signed upload
      // Parameters must be in alphabetical order
      String stringToSign = 'folder=$folderName&timestamp=$timestamp${CloudinaryConfig.apiSecret}';
      String signature = sha1.convert(utf8.encode(stringToSign)).toString();
      
      // Create MultipartFile - different approach for web vs mobile
      MultipartFile multipartFile;
      if (kIsWeb) {
        // Web platform: Use fromBytes
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );
      } else {
        // Mobile platform: Use fromFile
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }
      
      // Prepare form data with signature
      FormData formData = FormData.fromMap({
        'file': multipartFile,
        'folder': folderName,
        'timestamp': timestamp.toString(),
        'signature': signature,
        'api_key': CloudinaryConfig.apiKey,
      });

      // Upload to Cloudinary
      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // Accept all status codes to handle errors manually
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final imageUrl = data['secure_url'] as String;
        debugPrint('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        // Log detailed error from Cloudinary
        debugPrint('Cloudinary error response: ${response.data}');
        final errorMsg = response.data['error']?['message'] ?? 'Upload failed';
        throw Exception('Upload failed: $errorMsg (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Delete image from Cloudinary
  Future<void> deleteImage(String publicId) async {
    try {
      FormData formData = FormData.fromMap({
        'public_id': publicId,
        'api_key': CloudinaryConfig.apiKey,
        'api_secret': CloudinaryConfig.apiSecret,
      });

      final response = await _dio.post(
        CloudinaryConfig.deleteUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint('Image deleted successfully');
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }
}
