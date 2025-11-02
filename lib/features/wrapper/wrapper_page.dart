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
import 'package:badges/badges.dart';
import 'package:picoshop_theme2/features/profile/view/pages/profile_page.dart';
import 'package:picoshop_theme2/features/search/view/pages/search_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = const [
    HomePage(),
    ProductListPage(),
    SearchPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) async {
    await _scaleController.forward();

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    await _scaleController.reverse();
  }

  Widget _buildPageTransition(Widget child, int index) {
    final isForward = index > _previousIndex;

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      reverse: !isForward,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return _buildCustomTransition(
          child,
          animation,
          secondaryAnimation,
          isForward,
        );
      },
      child: KeyedSubtree(key: ValueKey(index), child: child),
    );
  }

  Widget _buildCustomTransition(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool isForward,
  ) {
    if (isForward) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastEaseInToSlowEaseOut,
              ),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    } else {
      return SlideTransition(
        position:
            Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastEaseInToSlowEaseOut,
              ),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    }
  }

  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
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
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10, height: 1.2),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: [
            _buildNavItem(icon: LineIcons.home, label: 'Home', index: 0),
            _buildNavItem(icon: LineIcons.box, label: 'Products', index: 1),
            _buildNavItem(icon: LineIcons.search, label: 'Search', index: 2),
            _buildNavItem(
              icon: LineIcons.shoppingCart,
              label: 'Cart',
              index: 3,
              isCart: true,
            ),
            _buildNavItem(icon: LineIcons.user, label: 'Profile', index: 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isCart = false,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = _currentIndex == index ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: isCart ? _buildCartIcon() : Icon(icon),
          );
        },
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: AppColors.selectedNavColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: isCart ? _buildCartIcon(isActive: true) : Icon(icon),
      ),
      label: label,
    );
  }

  Widget _buildCartIcon({bool isActive = false}) {
    return Consumer(
      builder: (context, ref, _) {
        final cartCount = ref
            .watch(cartNotifierProvider)
            .maybeWhen(data: (items) => items.length, orElse: () => 0);

        return Badge(
          showBadge: cartCount > 0,
          badgeContent: Text(
            cartCount > 99 ? '99+' : '$cartCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: BadgeStyle(
            badgeColor: isActive ? AppColors.primary : Colors.red,
            padding: const EdgeInsets.all(4),
            borderRadius: BorderRadius.circular(8),
          ),
          position: BadgePosition.topEnd(top: -9, end: -8),
          child: Icon(
            LineIcons.shoppingCart,
            color: isActive
                ? AppColors.selectedNavColor
                : AppColors.unselctedNavColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    if (responsive.isMobile) {
      return Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.fastEaseInToSlowEaseOut,
          switchOutCurve: Curves.fastEaseInToSlowEaseOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _buildPageTransition(_pages[_currentIndex], _currentIndex),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // Desktop layout with enhanced NavigationRail
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabTapped,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppColors.background,
                selectedLabelTextStyle: TextStyle(
                  color: AppColors.selectedNavColor,
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.navLabel,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: AppColors.unselctedNavColor,
                  fontSize: responsive.navLabel,
                ),
                selectedIconTheme: IconThemeData(
                  color: AppColors.selectedNavColor,
                  size: responsive.navIcon * 1.1,
                ),
                unselectedIconTheme: IconThemeData(
                  color: AppColors.unselctedNavColor,
                  size: responsive.navIcon,
                ),
                destinations: [
                  _buildRailDestination(LineIcons.home, 'Home', responsive),
                  _buildRailDestination(LineIcons.box, 'Products', responsive),
                  _buildRailDestination(LineIcons.search, 'Search', responsive),
                  _buildRailDestination(
                    LineIcons.shoppingCart,
                    'Cart',
                    responsive,
                  ),
                  _buildRailDestination(LineIcons.user, 'Profile', responsive),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: _buildPageTransition(
                    _pages[_currentIndex],
                    _currentIndex,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(
    IconData icon,
    String label,
    Responsive responsive,
  ) {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: AppColors.selectedNavColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label),
      ),
    );
  }
}
