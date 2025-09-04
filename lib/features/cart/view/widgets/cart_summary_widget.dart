

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';

class CartSummaryWidget extends ConsumerWidget {
  const CartSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(getCartItemNotifierProvider);
    final cartItemCountAsync = ref.watch(getTotalCartItemNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cartItemCountAsync.when(
            data: (count) => Text(
              "Items: ${count?.data ?? 0}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,
              ),
            ),
            loading: () => const Text("Items: ..."),
            error: (_, __) => const Text("Items: error"),
          ),
          cartItemsAsync.when(
            data: (cartListData) {
              final cartList = cartListData?.data ?? [];
              final totalPrice = cartList.fold<double>(
                0.0,
                (sum, item) => sum + (item.quantity * item.uomPrice),
              );
              return Text(
                "Total: ${totalPrice.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              );
            },
            loading: () => const Text("Total: ..."),
            error: (_, __) => const Text("Total: error"),
          ),
        ],
      ),
    );
  }
}
