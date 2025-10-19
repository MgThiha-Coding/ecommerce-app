import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/create_address/model/response/address_response.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/address_list_page.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/create_address_page.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';
import 'package:picoshop_theme2/features/payment/view/payment_list_page.dart';
import 'package:picoshop_theme2/features/test/create_order.dart';
import 'package:picoshop_theme2/shared/app_button.dart';

class CheckOutPage extends ConsumerStatefulWidget {
  const CheckOutPage({super.key});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  AddressItem? _selectedAddress;
  PaymentMethod? _selectedPayment;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final cartItemsAsync = ref.watch(cartNotifierProvider);
    final orderNotifier = ref.watch(orderNotifierProvider.notifier);
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Checkout',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: cartItemsAsync.when(
        data: (cartItems) {
          final itemCount = cartItems.length;
          final totalCost = cartItems.fold<double>(
            0,
            (sum, item) => sum + (item.uomPrice * item.quantity),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Address Section =====
                Text(
                  "Delivery Address",
                  style: GoogleFonts.poppins(
                    fontSize: responsive.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAddressPage(),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Create Address',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        'Add a new delivery address',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: Responsive(context).caption,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<AddressItem>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressListPage(),
                      ),
                    );
                    if (result != null) {
                      setState(() => _selectedAddress = result);
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        _selectedAddress == null
                            ? 'Select Saved Address'
                            : '${_selectedAddress!.firstName} ${_selectedAddress!.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: _selectedAddress != null
                          ? Text(
                              '${_selectedAddress!.addressLine1}, ${_selectedAddress!.addressLine2}\n'
                              '${_selectedAddress!.townshipEnName}, ${_selectedAddress!.regionEnName}\n'
                              '${_selectedAddress!.country}, ${_selectedAddress!.postalZipCode}\n'
                              'Phone: ${_selectedAddress!.phone}',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.body - 1,
                                color: Colors.black54,
                              ),
                            )
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Payment Section =====
                Text(
                  "Payment Method",
                  style: GoogleFonts.poppins(
                    fontSize: responsive.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<PaymentMethod>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentListPage(),
                      ),
                    );
                    if (result != null) {
                      setState(() => _selectedPayment = result);
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.payment_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        _selectedPayment == null
                            ? 'Select Payment Method'
                            : _selectedPayment!.name,
                        style: GoogleFonts.poppins(
                          fontSize: responsive.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: _selectedPayment?.paymentAccount?.accountNumber !=
                              null
                          ? Text(
                              "Acc: ${_selectedPayment!.paymentAccount!.accountNumber}",
                              style: GoogleFonts.poppins(
                                fontSize: responsive.body - 1,
                                color: Colors.black54,
                              ),
                            )
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Order Summary =====
                Text(
                  "Order Summary",
                  style: GoogleFonts.poppins(
                    fontSize: responsive.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      children: [
                        _buildSummaryRow("Items", "$itemCount"),
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          "Total Amount",
                          "${totalCost.toStringAsFixed(2)} MMK",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ===== Place Order Button =====
                Opacity(
                  opacity: _selectedAddress != null && _selectedPayment != null
                      ? 1.0
                      : 0.4,
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: AppButton(
                      title: orderState.isLoading
                          ? "Placing Order..."
                          : "Place Order",
                      backgroundColor: AppColors.primary,
                      labelColor: AppColors.background,
                      onTap: _selectedAddress != null &&
                              _selectedPayment != null &&
                              !orderState.isLoading
                          ? () async {
                              await orderNotifier.createOrder();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('✅ Order placed successfully!'),
                                  ),
                                );
                              }
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select both address and payment method'),
                                ),
                              );
                            },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
