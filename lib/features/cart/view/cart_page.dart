import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
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
    Future.microtask(() {
      ref.read(getCartItemNotifierProvider.notifier).getCartItem();
      ref.read(getTotalCartItemNotifierProvider.notifier).getTotalCartItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartListAsync = ref.watch(getCartItemNotifierProvider);

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const AppBarWidget(),
              Expanded(
                child: cartListAsync.when(
                  data: (cartListData) {
                    final cartList = cartListData?.data ?? [];

                    // Always show Card
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: cartList.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No Cart Items yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: cartList.length,
                                    itemBuilder: (context, index) {
                                      final cartItemname =
                                          cartList[index].productName;
                                      final cartItemCount =
                                          cartList[index].quantity;
                                      final uomPrice = cartList[index].uomPrice;
                                      final id = cartList[index].id;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 4,
                                        ),
                                        child: Card(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.blue.shade500,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              cartItemname,
                                              style: GoogleFonts.poppins(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Text(
                                                  '${uomPrice.toStringAsFixed(0)} × ${cartItemCount.toInt()} = ${(uomPrice * cartItemCount).toStringAsFixed(0)}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.red,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            trailing: IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.grey
                                                    // ignore: deprecated_member_use
                                                    .withOpacity(0.3),
                                                shape: CircleBorder(),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      title: Text(
                                                        'Delete Item',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .red
                                                                  .shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to delete this item from your cart?',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      actions: [
                                                        TextButton(
                                                          style: TextButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 10,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            'Cancel',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  color: Colors
                                                                      .black87,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ),
                                                        Consumer(
                                                          builder: (context, ref, _) {
                                                            final removeState =
                                                                ref.watch(
                                                                  removeCartItemNotifierProvider,
                                                                );
                                                            final isLoading =
                                                                removeState
                                                                    .isLoading;

                                                            return TextButton(
                                                              style: TextButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .red
                                                                        .shade600,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  isLoading
                                                                  ? null
                                                                  : () async {
                                                                      final notifier = ref.read(
                                                                        removeCartItemNotifierProvider
                                                                            .notifier,
                                                                      );
                                                                      await notifier
                                                                          .removeCartItem(
                                                                            id,
                                                                          );

                                                                      await ref
                                                                          .read(
                                                                            getCartItemNotifierProvider.notifier,
                                                                          )
                                                                          .getCartItem();
                                                                      await ref
                                                                          .read(
                                                                            getTotalCartItemNotifierProvider.notifier,
                                                                          )
                                                                          .getTotalCartItem();

                                                                      if (!ref
                                                                          .watch(
                                                                            removeCartItemNotifierProvider,
                                                                          )
                                                                          .isLoading) {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      }
                                                                    },

                                                              child: isLoading
                                                                  ? const SizedBox(
                                                                      height:
                                                                          16,
                                                                      width: 16,
                                                                      child: SpinKitCircle(
                                                                        size:
                                                                            15,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      'Yes',
                                                                      style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          CartSummaryWidget(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Next',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (error, _) => Center(child: Text(error.toString())),
                  loading: () => const Center(
                    child: SpinKitCircle(size: 50, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cartItemCountAsync = ref.watch(getTotalCartItemNotifierProvider);

    double responsiveTitle() {
      if (screenWidth < 600) {
        return 18;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 20;
      }
      return 25;
    }

    double responsiveAppBarHeight() {
      if (screenWidth < 600) {
        return 60;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 70;
      }
      return 80;
    }

    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: responsiveAppBarHeight(),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Cart',
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          Stack(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: responsiveTitle(),
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
                      
                       count!.data.toString(),
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


class CartSummaryWidget extends ConsumerWidget {
  const CartSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(getCartItemNotifierProvider);
    final cartItemCountAsync = ref.watch(getTotalCartItemNotifierProvider);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Item count (API 2)
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

            // Total price (API 1, calculated)
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
      ),
    );
  }
}
