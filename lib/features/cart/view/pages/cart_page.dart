import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_page.dart';
import 'package:shimmer/shimmer.dart';

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

  Widget _buildGlassCard({required Widget child, double borderRadius = 0}) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final cartItemsAsync = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientStart,
        title: Text(
          LocaleKeys.cart.tr(),
          style: GoogleFonts.poppins(
            fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
            color: AppColors.bannerTextPrimary,
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
                        Icons.shopping_cart,
                        color: AppColors.bannerTextPrimary,
                        size: responsive.value(
                          mobile: 20,
                          tablet: 25,
                          desktop: 30,
                        ),
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartCount',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: Colors.amber.shade100,
            onRefresh: _onRefresh,
            child: _buildGlassCard(
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
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade500,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  item.productName,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                subtitle: Text(
                                  'Quantity: ${item.quantity}',
                                  style: GoogleFonts.poppins(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => ListView.builder(
                        padding: const EdgeInsets.all(6),
                        itemCount: 10,
                        itemBuilder: (context, index) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade300,
                              ),
                              title: Container(
                                height: 10,
                                color: Colors.grey.shade300,
                              ),
                              subtitle: Container(
                                height: 10,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.only(top: 6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Text(
                          'Failed to load cart.\n${error.toString()}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
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
                            color: AppColors.buttonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Shipping",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
      ),
    );
  }
}
