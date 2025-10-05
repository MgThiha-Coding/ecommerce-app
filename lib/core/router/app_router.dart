import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/view/pages/splash_page.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/loginOrRegister',
        builder: (context, state) => const LoginOrRegister(),
      ),

      /*
      ShellRoute(
        builder: (context, state, child) => WrapperPage(child: child),
        routes: [
     
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'brandList',
                builder: (context, state) => const BrandListPage(),
              ),
              GoRoute(
                path: 'categoryList',
                builder: (context, state) => const CategoryListPage(),
              ),
            ],
          ),
         
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListPage(),
          ),
          GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      */
    ],
  );
});
