import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService() : ref = FirebaseStorage.instance.ref();

  final Reference ref;

  Future<void> uploadFile(String fileName, XFile file) async {
    try {
      final imageRef = ref.child(fileName);
      final imageBytes = await file.readAsBytes();

      // Optimize the image
      final optimizedImageBytes = await optimizeImage(imageBytes);

      await imageRef.putData(optimizedImageBytes);
    } catch (e) {
      print('Could not upload file: $e');
    }
  }

  Future<Uint8List?> getFile(String fileName) async {
    try {
      final imageRef = ref.child(fileName);
      return await imageRef.getData();
    } catch (e) {
      print('Could not get file: $e');
      return null;
    }
  }

  Future<String> getDownloadURL(String fileName) async {
    try {
      final imageRef = ref.child(fileName);
      return await imageRef.getDownloadURL();
    } catch (e) {
      print('Could not get download URL: $e');
      throw e;
    }
  }

  Future<Uint8List> optimizeImage(Uint8List imageBytes) async {
    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);

    if (image != null) {
      // Resize the image to a maximum width of 800px, preserving the aspect ratio
      img.Image resizedImage = img.copyResize(image, width: 800);

      // Compress the image as JPEG with 80% quality
      Uint8List optimizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));

      return optimizedImageBytes;
    } else {
      // If image decoding fails, return the original image bytes
      return imageBytes;
    }
  }
}
