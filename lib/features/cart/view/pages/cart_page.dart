import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:picoshop_theme2/features/checkout/view/pages/check_out_page.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
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

  // Helper method to format price with currency
  String _formatPrice(double price, BusinessSettingData? businessSetting) {
    if (businessSetting != null) {
      final symbol = businessSetting.currency.symbol;
      final decimalPlaces = businessSetting.currencyDecimalPlaces;
      // ✅ Currency symbol AFTER the price number
      return '${price.toStringAsFixed(decimalPlaces)}$symbol';
    }
    return price.toStringAsFixed(2);
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

                      // Calculate total cost
                      final totalCost = cartItems.fold<double>(
                        0,
                        (sum, item) => sum + (item.uomPrice * item.quantity),
                      );

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                final isLoading =
                                    cartState.itemLoading[item.id] ?? false;
                                final errorMsg = cartState.itemError[item.id];

                                return Stack(
                                  children: [
                                    Card(
                                      color: AppColors.background,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                            const SizedBox(height: 4),
                                            Text(
                                              'Quantity: ${item.quantity}',
                                              style: GoogleFonts.poppins(
                                                fontSize: fontSize.caption,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),

                                            // Unit Price with Currency
                                            currencyAsync.when(
                                              data: (businessSetting) {
                                                final unitPrice = item.uomPrice;
                                                final formattedUnitPrice =
                                                    _formatPrice(
                                                      unitPrice,
                                                      businessSetting,
                                                    );
                                                return Text(
                                                  'Price: $formattedUnitPrice',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
                                              error: (err, _) {
                                                return Text(
                                                  'Price: ${item.uomPrice.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
                                              loading: () {
                                                return Text(
                                                  'Price: ${item.uomPrice.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 2),

                                            // Subtotal with Currency
                                            currencyAsync.when(
                                              data: (businessSetting) {
                                                final subtotal =
                                                    item.uomPrice *
                                                    item.quantity;
                                                final formattedSubtotal =
                                                    _formatPrice(
                                                      subtotal,
                                                      businessSetting,
                                                    );
                                                return Text(
                                                  'Subtotal: $formattedSubtotal',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
                                              error: (err, _) {
                                                final subtotal =
                                                    item.uomPrice *
                                                    item.quantity;
                                                return Text(
                                                  'Subtotal: ${subtotal.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
                                              loading: () {
                                                final subtotal =
                                                    item.uomPrice *
                                                    item.quantity;
                                                return Text(
                                                  'Subtotal: ${subtotal.toStringAsFixed(2)}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize.caption,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                );
                                              },
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
                                                      fontSize:
                                                          fontSize.caption,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color:
                                                      AppColors.textSecondary,
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
                                            color: Colors.red.shade50
                                                // ignore: deprecated_member_use
                                                .withOpacity(0.95),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                            ),
                          ),

                          // Total and Checkout Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Total with Currency
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: GoogleFonts.poppins(
                                        fontSize: fontSize.subHeading,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    currencyAsync.when(
                                      data: (businessSetting) {
                                        final formattedTotal = _formatPrice(
                                          totalCost,
                                          businessSetting,
                                        );
                                        return Text(
                                          formattedTotal,
                                          style: GoogleFonts.poppins(
                                            fontSize: fontSize.subHeading,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      },
                                      error: (err, _) {
                                        return Text(
                                          totalCost.toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                            fontSize: fontSize.subHeading,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      },
                                      loading: () {
                                        return Text(
                                          totalCost.toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                            fontSize: fontSize.subHeading,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 45,
                                  child: AppButton(
                                    title: LocaleKeys.checkout.tr(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckOutPage(),
                                        ),
                                      );
                                    },
                                    backgroundColor: AppColors.primary,
                                    labelColor: AppColors.background,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                'Oops! Something went wrong.\nPlease try again in a moment.',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
