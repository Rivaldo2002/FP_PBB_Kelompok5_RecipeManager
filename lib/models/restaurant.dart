import 'package:flutter/cupertino.dart';
import 'package:fp_recipemanager/models/food.dart';
import 'package:collection/collection.dart';

import 'cart_item.dart';

class Restaurant extends ChangeNotifier {
  // List to hold menu items
  final List<Food> _menu = [
    // Burgers
    Food(
      name: "Classic Cheeseburger",
      description:
          "A juicy beef patty with melted cheddar, lettuce, tomato, and a hint of onion and pickle.",
      imagePath: "images/burgers/cheese_burger.png",
      price: 0.99,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Avocado", price: 2.99),
      ],
    ),
    Food(
      name: "Veggie Burger",
      description:
          "A delicious patty made from beans and veggies, topped with lettuce, tomato, and special sauce.",
      imagePath: "images/burgers/veggie_burger.png",
      price: 1.49,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Gluten-free bun", price: 0.99),
        Addon(name: "Extra patty", price: 1.49),
      ],
    ),
    // Salads
    Food(
      name: "Caesar Salad",
      description:
          "Crisp romaine lettuce with parmesan cheese, croutons, and Caesar dressing.",
      imagePath: "images/salads/caesar_salad.png",
      price: 2.99,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Chicken", price: 1.99),
        Addon(name: "Avocado", price: 0.99),
      ],
    ),
    Food(
      name: "Greek Salad",
      description:
          "Fresh cucumbers, tomatoes, red onion, olives, and feta cheese with olive oil dressing.",
      imagePath: "images/salads/greek_salad.png",
      price: 2.99,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Extra feta cheese", price: 0.99),
        Addon(name: "Chicken", price: 1.99),
      ],
    ),
    // Sides
    Food(
      name: "French Fries",
      description: "Crispy golden fries served hot.",
      imagePath: "images/sides/french_fries.png",
      price: 0.99,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Cheese", price: 0.49),
        Addon(name: "Bacon bits", price: 0.69),
      ],
    ),
    Food(
      name: "Onion Rings",
      description: "Crispy battered onion rings, fried to perfection.",
      imagePath: "images/sides/onion_rings.png",
      price: 1.49,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Spicy dip", price: 0.49),
      ],
    ),
    // Desserts
    Food(
      name: "Cheesecake",
      description:
          "Creamy cheesecake on a graham cracker crust with a hint of lemon.",
      imagePath: "images/desserts/cheesecake.png",
      price: 1.99,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Raspberry sauce", price: 0.49),
        Addon(name: "Whipped cream", price: 0.49),
      ],
    ),
    Food(
      name: "Chocolate Brownie",
      description: "Rich chocolate brownie with walnuts.",
      imagePath: "images/desserts/chocolate_brownie.png",
      price: 1.49,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Ice cream scoop", price: 0.99),
        Addon(name: "Chocolate sauce", price: 0.49),
      ],
    ),
    // Drinks
    Food(
      name: "Lemonade",
      description:
          "Freshly squeezed lemonade with just the right amount of sweetness.",
      imagePath: "images/drinks/lemonade.png",
      price: 0.99,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Mint", price: 0.49),
      ],
    ),
    Food(
      name: "Iced Tea",
      description: "Refreshing iced tea brewed from selected black tea leaves.",
      imagePath: "images/drinks/iced_tea.png",
      price: 0.99,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Lemon slice", price: 0.29),
        Addon(name: "Peach flavor", price: 0.49),
      ],
    ),
  ];

  // GETTERS
  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;

  // OPERATIONS
  // User cart
  final List<CartItem> _cart = [];

  // Add to cart
// add to cart
  void addToCart(Food food, List<Addon> selectedAddons) {
    // see if there is a cart item already with the same food and selected addons
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // check if the food items are the same
      bool isSameFood = item.food == food;

      // check if the list of selected addons are the same
      bool isSameAddons =
          ListEquality().equals(item.selectedAddons, selectedAddons);

      return isSameFood && isSameAddons;
    });

    // if item already exists, increase its quantity
    if (cartItem != null) {
      cartItem.quantity++;
    }
    // otherwise, add a new cart item to the cart
    else {
      _cart.add(CartItem(food: food, selectedAddons: selectedAddons));
    }
    notifyListeners();
  }

// Remove to cart
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

// Get total price
  double getTotalPrice() {
    double total = 0.0;

    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;

      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }

      total += itemTotal * cartItem.quantity;
    }

    return total;
  }

// Get total number of items in cart
  int getTotalItemCount() {
    int totalItemCount = 0;

    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }

    return totalItemCount;
  }

// Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

// HELPERS
// Generate receipt
// Format double value into money
// Format list of addons into a string summary
}
