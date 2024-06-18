import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fp_recipemanager/services/storage_service.dart';

class RecipeImage extends StatefulWidget {
  final String recipeId;
  final ValueChanged<String> onImagePathChanged;

  const RecipeImage({
    required this.recipeId,
    required this.onImagePathChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<RecipeImage> createState() => _RecipeImageState();
}

class _RecipeImageState extends State<RecipeImage> {
  final StorageService storage = StorageService();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    loadRecipeImage();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth; // Ensuring the height equals the width
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0), // Add border radius
              child: Container(
                width: size,
                height: size, // Making the height equal to the width to form a square
                decoration: BoxDecoration(
                  color: Colors.grey,
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
                    Icons.fastfood,
                    color: Colors.black38,
                    size: 50,
                  )
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: onRecipeTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onRecipeTapped() async {
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imagePath = 'recipeImage/${widget.recipeId}';
    await storage.uploadFile(imagePath, image);

    // Get the download URL of the uploaded image
    String url = await storage.getDownloadURL(imagePath);
    setState(() => imageUrl = url);

    // Notify the parent widget of the image path change
    widget.onImagePathChanged(imagePath);
  }

  Future<void> loadRecipeImage() async {
    final imagePath = 'recipeImage/${widget.recipeId}';
    String? url = await storage.getDownloadURL(imagePath);
    if (url != null) {
      setState(() => imageUrl = url);
    }
  }
}
