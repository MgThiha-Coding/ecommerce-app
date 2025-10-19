import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/create_address/model/response/address_response.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/address_list_page.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/create_address_page.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/shipping_method_list_page.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';
import 'package:picoshop_theme2/features/payment/view/payment_list_page.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';
import 'package:picoshop_theme2/features/createorder/create_order.dart';
import 'package:picoshop_theme2/shared/app_button.dart';

class CheckOutPage extends ConsumerStatefulWidget {
  const CheckOutPage({super.key});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  AddressItem? _selectedAddress;
  PaymentMethod? _selectedPayment;
  ShippingMethod? _selectedShipping;
  File? _approveScreenshot;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickScreenshot() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _approveScreenshot = File(pickedFile.path));
    }
  }

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
          final itemTotal = cartItems.fold<double>(
            0,
            (sum, item) => sum + (item.uomPrice * item.quantity),
          );
          final shippingAmount = _selectedShipping != null
              ? double.tryParse(_selectedShipping!.amount) ?? 0.0
              : 0.0;

          final totalCost = itemTotal + shippingAmount;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Address Section =====
                _buildSectionHeader("Delivery Address", responsive),
                const SizedBox(height: 8),
                _buildCreateAddressCard(responsive),
                const SizedBox(height: 8),
                _buildSelectAddressCard(responsive),

                const SizedBox(height: 16),
                // ===== Shipping Method Section =====
                _buildSectionHeader("Shipping Method", responsive),
                const SizedBox(height: 8),
                _buildShippingCard(responsive),

                const SizedBox(height: 16),
                // ===== Payment Section =====
                _buildSectionHeader("Payment Method", responsive),
                const SizedBox(height: 8),
                _buildPaymentCard(responsive),
                const SizedBox(height: 8),
                _buildScreenshotPicker(),

                const SizedBox(height: 16),
                // ===== Order Summary =====
                _buildSectionHeader("Order Summary", responsive),
                const SizedBox(height: 8),

                _buildOrderSummary(
                  itemCount,
                  itemTotal,
                  shippingAmount,
                  itemTotal + shippingAmount,
                ),

                const SizedBox(height: 30),
                // ===== Place Order Button =====
                _buildPlaceOrderButton(orderNotifier, orderState, totalCost),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Responsive responsive) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: responsive.body,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCreateAddressCard(Responsive responsive) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateAddressPage()),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            style: GoogleFonts.poppins(
              fontSize: responsive.caption,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildSelectAddressCard(Responsive responsive) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<AddressItem>(
          context,
          MaterialPageRoute(builder: (_) => const AddressListPage()),
        );
        if (result != null) setState(() => _selectedAddress = result);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              fontSize: Responsive(context).body,
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
                    fontSize: Responsive(context).body - 1,
                    color: Colors.black54,
                  ),
                )
              : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildShippingCard(Responsive responsive) {
    final shippingAmount = _selectedShipping != null
        ? double.tryParse(_selectedShipping!.amount) ?? 0
        : 0;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<ShippingMethod>(
          context,
          MaterialPageRoute(builder: (_) => const ShippingMethodListPage()),
        );
        if (result != null) setState(() => _selectedShipping = result);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            _selectedShipping == null
                ? 'Select Shipping Method'
                : _selectedShipping!.name,
            style: GoogleFonts.poppins(
              fontSize: Responsive(context).body,
              color: AppColors.textSecondary,
            ),
          ),
          subtitle: _selectedShipping != null
              ? Text(
                  "Cost: ${shippingAmount.toStringAsFixed(2)} MMK",
                  style: GoogleFonts.poppins(
                    fontSize: Responsive(context).body - 1,
                    color: Colors.black54,
                  ),
                )
              : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Responsive responsive) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<PaymentMethod>(
          context,
          MaterialPageRoute(builder: (_) => const PaymentListPage()),
        );
        if (result != null) setState(() => _selectedPayment = result);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(Icons.payment_outlined, color: AppColors.primary),
          title: Text(
            _selectedPayment == null
                ? 'Select Payment Method'
                : _selectedPayment!.name,
            style: GoogleFonts.poppins(
              fontSize: Responsive(context).body,
              color: AppColors.textSecondary,
            ),
          ),
          subtitle: _selectedPayment?.paymentAccount?.accountNumber != null
              ? Text(
                  "Acc: ${_selectedPayment!.paymentAccount!.accountNumber}",
                  style: GoogleFonts.poppins(
                    fontSize: Responsive(context).body - 1,
                    color: Colors.black54,
                  ),
                )
              : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildScreenshotPicker() {
    return GestureDetector(
      onTap: _pickScreenshot,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(Icons.photo, color: AppColors.primary),
          title: Text(
            _approveScreenshot == null
                ? "Upload Payment Screenshot"
                : "Screenshot Selected",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: _approveScreenshot != null
              ? const Icon(Icons.check, color: Colors.green)
              : null,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    int itemCount,
    double itemTotal,
    double shippingAmount,
    double totalCost,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            _buildSummaryRow(
              "Items ($itemCount)",
              "${itemTotal.toStringAsFixed(2)} MMK",
            ),
            const SizedBox(height: 6),
            _buildSummaryRow(
              "Shipping",
              "${shippingAmount.toStringAsFixed(2)} MMK",
            ),
            const Divider(),
            _buildSummaryRow("Total", "${totalCost.toStringAsFixed(2)} MMK"),
          ],
        ),
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

  Widget _buildPlaceOrderButton(
    OrderNotifier orderNotifier,
    AsyncValue<Map<String, dynamic>?> orderState,
    double totalCost,
  ) {
    final isEnabled =
        _selectedAddress != null &&
        _selectedPayment != null &&
        _selectedShipping != null &&
        _approveScreenshot != null &&
        !orderState.isLoading;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: AppButton(
          title: orderState.isLoading ? "Placing Order..." : "Place Order",
          backgroundColor: AppColors.primary,
          labelColor: AppColors.background,
          onTap: isEnabled
              ? () async {
                  await orderNotifier.createOrder(
                    orderType: "deliver",
                    cartItemIds: ref
                        .read(cartNotifierProvider)
                        .value!
                        .map((e) => e.id)
                        .toList(),
                    address: _selectedAddress!,
                    shipping: _selectedShipping!,
                    payment: _selectedPayment!,
                    approveScreenshot: _approveScreenshot!,
                  );
                  Navigator.pop(context);
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please complete all selections and upload screenshot',
                      ),
                    ),
                  );
                },
        ),
      ),
    );
  }
}
