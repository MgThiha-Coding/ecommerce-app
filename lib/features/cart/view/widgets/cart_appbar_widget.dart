import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';

class CartAppBarWidget extends ConsumerWidget {
  const CartAppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCountAsync = ref.watch(getTotalCartItemNotifierProvider);
    final responsive = Responsive(context);

    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Cart',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 20, tablet: 25, desktop: 30),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: responsive.value(mobile: 20, tablet: 25, desktop: 30),
                ),
              ),
              Positioned(
                top: 1,
                right: 3,
                child: cartItemCountAsync.when(
                  data: (count) => Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        (count?.data ?? 0).toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}