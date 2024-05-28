import 'package:flutter/material.dart';
import 'package:fp_recipemanager/components/drawer_list_tile.dart';

class HomeDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  const HomeDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          DrawerHeader(child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
          ),
          ),
          DrawerListTile(
              icon: Icons.home,
              text: "H O M E",
            onTap: () => Navigator.pop(context),
          ),
          DrawerListTile(
            icon: Icons.person,
            text: "P R O F I L E",
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
