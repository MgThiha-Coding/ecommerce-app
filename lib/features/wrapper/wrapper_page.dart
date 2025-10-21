import 'package:flutter/material.dart' hide Badge;
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/home/pages/home_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/pages/profile_page.dart';
import 'package:picoshop_theme2/features/search/view/search_page.dart';
import 'package:badges/badges.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ProductListPage(),
    SearchPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    if (responsive.isMobile || responsive.isTablet) {
      return Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: _currentIndex < _previousIndex,
          transitionBuilder: (child, animation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.background,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.selectedNavColor,
          unselectedItemColor: AppColors.unselctedNavColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LineIcons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LineIcons.box),
              label: 'Products',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LineIcons.search),
              label: 'Search',
            ),

            BottomNavigationBarItem(
              icon: Consumer(
                builder: (context, ref, _) {
                  final cartCount = ref
                      .watch(cartNotifierProvider)
                      .maybeWhen(
                        data: (items) => items.length,
                        orElse: () => 0,
                      );

                  return Badge(
                    showBadge: cartCount > 0,
                    badgeContent: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),

                    position: BadgePosition.topEnd(top: -10, end: -12),
                    child: const Icon(LineIcons.shoppingCart),
                  );
                },
              ),

              label: 'Cart',
            ),

            const BottomNavigationBarItem(
              icon: Icon(LineIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    // Desktop layout with NavigationRail
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(LineIcons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(LineIcons.box),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(LineIcons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(LineIcons.shoppingCart),
                  label: Text('Cart'),
                ),
                NavigationRailDestination(
                  icon: Icon(LineIcons.user),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _currentIndex < _previousIndex,
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: _pages[_currentIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
