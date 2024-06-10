import 'package:flutter/material.dart';
import 'package:fp_recipemanager/models/food.dart';
import 'package:fp_recipemanager/models/restaurant.dart';
import 'package:fp_recipemanager/pages/food_page.dart';
import 'package:fp_recipemanager/components/my_current_location.dart';
import 'package:fp_recipemanager/components/my_description_box.dart';
import 'package:fp_recipemanager/components/my_drawer.dart';
import 'package:fp_recipemanager/components/my_food_tile.dart';
import 'package:fp_recipemanager/components/my_sliver_app_bar.dart';
import 'package:fp_recipemanager/components/my_tab_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sort out and return a list of food items that belong to a specific category
  // Function to filter menu items by a specific category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

// Function to return a list of components displaying foods in a specific category
  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      // Get category menu
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);

      // Builds a ListView for the current category
      return ListView.builder(
        itemCount: categoryMenu.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          // Get individual food
          final food = categoryMenu[index];

          // Return food tile UI
          return FoodTile(food: food, onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FoodPage(food: food))
          ));
        },
      );
    }).toList(); // Converts the map results to a list
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
              title: MyTabBar(tabController: _tabController),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  // My current location
                  const MyCurrentLocation(),

                  // Description box
                  const MyDescriptionBox()
                ],
              ))
        ],
        body: Consumer<Restaurant>(
          builder: (context, restaurant, child) => TabBarView(
            controller: _tabController,
            children: getFoodInThisCategory(restaurant.menu),
          ),
        ),
      ),
    );
  }
}
