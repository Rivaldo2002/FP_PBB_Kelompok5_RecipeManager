import 'package:flutter/material.dart';

import '../models/food.dart';

// Define the FoodTile widget which will be used to display food items in the UI
class FoodTile extends StatelessWidget {
  // Properties of the FoodTile
  final Food food; // The food item to display
  final void Function()? onTap; // Function to execute on tap

  // Constructor for FoodTile requiring the food item and onTap function
  const FoodTile({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The widget layout
    return Column(
      children: [
        GestureDetector(
          onTap: onTap, // Set the onTap action
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Text food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('\$' + food.price.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 10),
                      Text(food.description,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                // Food image
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(food.imagePath, height: 120)),
              ],
            ),
          ),
        ),
        // Divider line
        Divider(
            color: Theme.of(context).colorScheme.tertiary,
            endIndent: 25,
            indent: 25),
      ],
    );
  }
}
