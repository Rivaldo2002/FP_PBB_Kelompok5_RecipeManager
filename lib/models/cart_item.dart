import 'package:fp_recipemanager/models/food.dart';

// Class representing an item in a shopping cart
class CartItem {
  final Food food;
  final List<Addon> selectedAddons;

  // Quantity of the food item in the cart
  int quantity;

  // Constructor for creating a cart item
  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1, // Default quantity is 1
  });

  // Computed property to get the total price of the cart item
  double get totalPrice {
    double addonsPrice =
        selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (food.price + addonsPrice) * quantity;
  }
}
