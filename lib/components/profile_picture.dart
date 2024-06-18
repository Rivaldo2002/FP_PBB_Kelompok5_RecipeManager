import 'package:cached_network_image/cached_network_image.dart';
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
  final StorageService storage = StorageService();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    loadProfilePicture();
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
            image: imageUrl != null
                ? DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(imageUrl!),
            )
                : null,
          ),
          child: Center(
            child: imageUrl == null
                ? Icon(
              Icons.person_rounded,
              color: Colors.black38,
              size: 35,
            )
                : null,
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
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imagePath = 'profilePicture/${widget.userId}';
    await storage.uploadFile(imagePath, image);

    // Get the download URL of the uploaded image
    String url = await storage.getDownloadURL(imagePath);
    setState(() => imageUrl = url);
  }

  Future<void> loadProfilePicture() async {
    final imagePath = 'profilePicture/${widget.userId}';
    String? url = await storage.getDownloadURL(imagePath);
    if (url != null) {
      setState(() => imageUrl = url);
    }
  }
}