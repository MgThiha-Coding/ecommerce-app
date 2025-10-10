/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/home/pages/home_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/pages/profile_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key, required Widget child});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int _currentIndex = 0;

  final List<String> _paths = ['/home', '/products', '/cart', '/profile'];
  final List<Widget> _pages = [
    const HomePage(),
    const ProductListPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('Products')),
    NavigationRailDestination(icon: Icon(Icons.shopping_cart), label: Text('Cart')),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
  ];

  int _getIndexFromRoute(String location) {
    final index = _paths.indexWhere((path) => location.startsWith(path));
    return index >= 0 ? index : 0;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      context.go(_paths[index]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final index = _getIndexFromRoute(location);
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    if (responsive.isMobile) {
      return Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue.shade50,
          elevation: 4,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey.shade800,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                    child: Image.asset(
                      'assets/images/picocare.png',
                      height: 50,
                      width: 50,
                    ),
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
              Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
            ],
          ),
        ),
      );
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/home/pages/home_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/pages/profile_page.dart';

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
    NavigationRailDestination(
      icon: Icon(Icons.grid_view),
      label: Text('Products'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_cart),
      label: Text('Cart'),
    ),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    if (responsive.isMobile) {
      return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 4,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF2ECC71),
          unselectedItemColor: Colors.grey.shade800,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 8),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Products',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
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
