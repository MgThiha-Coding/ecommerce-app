// wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/features/cart/view/cart_page.dart';
import 'package:picoshop_theme2/features/home/view/home_page.dart';
import 'package:picoshop_theme2/features/product/view/product_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/profile_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _MobileWrapperState();
}

class _MobileWrapperState extends State<WrapperPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ProductListPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        elevation: 4,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade400,
        unselectedItemColor: Colors.grey.shade800,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
