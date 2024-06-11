import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fp_recipemanager/services/storage_service.dart';

class ProfilePicture extends StatefulWidget {
  final String userId;

  const ProfilePicture({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool isLoading = false;
  StorageService storage = StorageService();
  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
            image: pickedImage != null
                ? DecorationImage(
                fit: BoxFit.cover,
                image: Image.memory(pickedImage!, fit: BoxFit.cover).image)
                : null,
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: Colors.black38,
              size: 35,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onProfileTapped,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> onProfileTapped() async {
    final ImagePicker _imagePicker = ImagePicker();
    bool isLoading = false;

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await storage.uploadFile('profilePicture/${widget.userId}', image);

    final imageBytes = await image.readAsBytes();
    setState(() => pickedImage = imageBytes);
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile('profilePicture/${widget.userId}');
    if (imageBytes == null) return;
    setState(() => pickedImage = imageBytes);
  }
}
