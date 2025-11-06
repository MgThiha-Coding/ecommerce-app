import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/cart_list.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/total_checkout_section.dart';
import 'package:picoshop_theme2/features/category/view/widgets/category_list_loading.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartNotifierProvider.notifier).fetchCart();
      ref.read(businessSettingNotifierProvider.notifier).fetchBusinessSetting();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(cartNotifierProvider.notifier).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final cartItemsAsync = ref.watch(cartNotifierProvider);
    final cartState = ref.watch(removeCartItemNotifierProvider);
    final currencyAsync = ref.watch(businessSettingNotifierProvider);

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
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
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
                        LineIcons.shoppingCart,
                        color: AppColors.textSecondary,
                        size: fontSize.value(
                          mobile: 26,
                          tablet: 25,
                          desktop: 25,
                        ),
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 3,
                        top: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 13,
                            minHeight: 10,
                          ),
                          child: Text(
                            '$cartCount',
                            style: GoogleFonts.poppins(
                              fontSize: 7,
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

                      // total cost
                      final totalCost = cartItems.fold<double>(
                        0,
                        (sum, item) => sum + (item.uomPrice * item.quantity),
                      );

                      return Column(
                        children: [
                          cartList(
                            context,
                            cartItems,
                            fontSize,
                            currencyAsync,
                            cartState,
                            ref,
                          ),
                          // Total and Checkout Section
                          totalCheckoutSection(
                            context,
                            totalCost,
                            fontSize,
                            currencyAsync,
                          ),
                        ],
                      );
                    },
                    loading: () => categoryListLoading(context),
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
                                'Oops! Something went wrong.\nPlease try again in a moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Poppins",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
