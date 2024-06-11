import 'dart:typed_data';
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
  bool isLoading = false;
  StorageService storage = StorageService();
  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getRecipeImage();
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
                  image: pickedImage != null
                      ? DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.memory(pickedImage!, fit: BoxFit.cover).image,
                  )
                      : null,
                ),
                child: Center(
                  child: pickedImage == null
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

    final imageBytes = await image.readAsBytes();
    setState(() => pickedImage = imageBytes);

    // Notify the parent widget of the image path change
    widget.onImagePathChanged(imagePath);
  }

  Future<void> getRecipeImage() async {
    final imageBytes = await storage.getFile('recipeImage/${widget.recipeId}');
    if (imageBytes == null) return;
    setState(() => pickedImage = imageBytes);
  }
}
