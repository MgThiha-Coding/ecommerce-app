import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(cartNotifierProvider.notifier).fetchCart(),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(cartNotifierProvider.notifier).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final cartItemsAsync = ref.watch(cartNotifierProvider);
    final cartState = ref.watch(removeCartItemNotifierProvider);

    ref.listen<CartState>(removeCartItemNotifierProvider, (previous, next) {
      final removedItems = previous?.itemLoading.keys
          .where(
            (id) =>
                previous.itemLoading[id] == true &&
                next.itemLoading[id] == null,
          )
          .toList();

      if (removedItems!.isNotEmpty) {
        for (var id in removedItems) {
          if (next.itemError[id] == null) {
            const message = "Item removed successfully";
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(message),
                duration: Duration(seconds: 2),
              ),
            );
            ref.read(cartNotifierProvider.notifier).fetchCart();
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          LocaleKeys.cart.tr(),
          style: GoogleFonts.poppins(
            fontSize: fontSize.subHeading,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer(
              builder: (context, ref, _) {
                final cartCount = ref
                    .watch(cartNotifierProvider)
                    .maybeWhen(data: (items) => items.length, orElse: () => 0);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                        size: fontSize.value(
                          mobile: 24,
                          tablet: 25,
                          desktop: 25,
                        ),
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -1,
                        top: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 15,
                          ),
                          child: Text(
                            '$cartCount',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize.caption,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: AppColors.background,
          onRefresh: _onRefresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Expanded(
                  child: cartItemsAsync.when(
                    data: (cartItems) {
                      if (cartItems.isEmpty) {
                        return Center(
                          child: Text(
                            'Cart is currently empty.',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                              fontSize: fontSize.body,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final isLoading =
                              cartState.itemLoading[item.id] ?? false;
                          final errorMsg = cartState.itemError[item.id];

                          return Stack(
                            children: [
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    item.productName,
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSize.body,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: GoogleFonts.poppins(
                                          fontSize: fontSize.caption,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Price: ${item.uomPrice}',
                                        style: GoogleFonts.poppins(
                                          fontSize: fontSize.caption,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isLoading
                                      ? SizedBox(
                                          width: 80,
                                          child: Center(
                                            child: Text(
                                              'Removing..',
                                              style: GoogleFonts.poppins(
                                                fontSize: fontSize.caption,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  removeCartItemNotifierProvider
                                                      .notifier,
                                                )
                                                .removeCartItem(item.id);
                                          },
                                        ),
                                ),
                              ),
                              if (errorMsg != null)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50.withOpacity(
                                        0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        errorMsg,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: fontSize.caption,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: 6,
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade300,
                            ),
                            title: Container(
                              height: 12,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                            ),
                            subtitle: Container(
                              height: 10,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.only(top: 4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load cart.\n${error.toString()}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize.body,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShippingMethodPage(),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Shipping",
                            style: GoogleFonts.poppins(
                              fontSize: fontSize.body,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
