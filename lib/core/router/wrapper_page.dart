// wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/home/view/pages/home_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/profile_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
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

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('Products')),
    NavigationRailDestination(icon: Icon(Icons.shopping_cart), label: Text('Cart')),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    if (responsive.isMobile) {
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
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: Scaffold(
          body: Row(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset('assets/images/picocare.png',height: 50,width: 50,),
                  ),
                  Expanded(
                    child: NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onTabTapped,
                      labelType: NavigationRailLabelType.all,
                      destinations: _railDestinations,
                    ),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
        ),
      );
    }
  }
}
