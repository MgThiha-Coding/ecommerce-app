import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/cart_list_loading.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/cart_summary_widget.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/delete_cart_item_dialog.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/create_address_page.dart';

class CartListWidget extends ConsumerStatefulWidget {
  const CartListWidget({super.key});

  @override
  ConsumerState<CartListWidget> createState() => _CartListWidgetState();
}

class _CartListWidgetState extends ConsumerState<CartListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getCartItemNotifierProvider.notifier).getCartItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartListAsync = ref.watch(getCartItemNotifierProvider);
    return Expanded(
      child: cartListAsync.when(
        data: (cartListData) {
          final cartList = cartListData?.data ?? [];
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: cartList.isEmpty
                      ? const Center(
                          child: Text(
                            'No Cart Items yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartList.length,
                          itemBuilder: (context, index) {
                            final item = cartList[index];
                            final cartItemname = item.productName;
                            final cartItemCount = item.quantity;
                            final uomPrice = item.uomPrice;
                            final id = item.id;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Card(
                                child: ListTile(
                                  leading: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.black),
                                  ),

                                  title: Text(
                                    cartItemname,
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${uomPrice.toStringAsFixed(0)} × ${cartItemCount.toInt()} = ${(uomPrice * cartItemCount).toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteCartItemDialog(
                                            itemId: id,
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAddressPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Next',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) => CartListLoading(),
        loading: () => CartListLoading(),
      ),
    );
  }
}
