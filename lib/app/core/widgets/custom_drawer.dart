import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pharma System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Get.toNamed('/dashboard'),
          ),
          _buildMenuItem(
            icon: Icons.people,
            title: 'Suppliers',
            onTap: () => Get.toNamed('/suppliers'),
          ),
          _buildMenuItem(
            icon: Icons.medication,
            title: 'Products',
            onTap: () => Get.toNamed('/products'),
          ),
          _buildMenuItem(
            icon: Icons.shopping_cart,
            title: 'Purchase',
            onTap: () => Get.toNamed('/purchase'),
          ),
          _buildMenuItem(
            icon: Icons.point_of_sale,
            title: 'Sales',
            onTap: () => Get.toNamed('/sales'),
          ),
          _buildMenuItem(
            icon: Icons.inventory,
            title: 'Stock',
            onTap: () => Get.toNamed('/stock'),
          ),
          _buildMenuItem(
            icon: Icons.person,
            title: 'Customers',
            onTap: () => Get.toNamed('/customers'),
          ),
          const Spacer(),
          const Divider(),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Get.toNamed('/settings'),
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Add logout logic here
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
