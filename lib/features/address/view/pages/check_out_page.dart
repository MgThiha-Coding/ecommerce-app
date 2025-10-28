import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/address/model/response/address_response.dart';
import 'package:picoshop_theme2/features/address/view/pages/address_list_page.dart';
import 'package:picoshop_theme2/features/address/view/pages/create_address_page.dart';
import 'package:picoshop_theme2/features/address/view/pages/shipping_method_list_page.dart';
import 'package:picoshop_theme2/features/order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/order/model/response/create_order_response.dart';
import 'package:picoshop_theme2/features/order/viewmodel/create_order_notifier.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';
import 'package:picoshop_theme2/features/payment/view/payment_list_page.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:shimmer/shimmer.dart';

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

  String orderType = "delivery";
  List<int> cartItemIds = [];
  ShippingInfo? shipping;
  int? paymentAccountId;

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
    final orderState = ref.watch(createOrderNotifierProvider);
    final currency = ref.watch(businessSettingNotifierProvider);

    ref.listen<AsyncValue<CreateOrderResponse?>>(createOrderNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (response) {
          if (response != null && response.success) {
            ref.read(cartNotifierProvider.notifier).fetchCart();
            ref.read(cartNotifierProvider.notifier).refreshCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Order placed successfully!")),
            );
            Navigator.pop(context);
          }
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.checkout.tr(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  LocaleKeys.deliveryAddress.tr(),
                  responsive,
                ),
                const SizedBox(height: 8),
                _buildCreateAddressCard(responsive),
                const SizedBox(height: 8),
                _buildSelectAddressCard(responsive),

                const SizedBox(height: 16),

                _buildSectionHeader(LocaleKeys.shippingMethod.tr(), responsive),
                const SizedBox(height: 8),
                _buildShippingCard(responsive),

                const SizedBox(height: 16),

                _buildSectionHeader(LocaleKeys.paymentMethod.tr(), responsive),
                const SizedBox(height: 8),
                _buildPaymentCard(responsive),
                const SizedBox(height: 8),
                _buildScreenshotPicker(),

                const SizedBox(height: 16),

                _buildSectionHeader(LocaleKeys.orderSummary.tr(), responsive),
                const SizedBox(height: 8),

                _buildOrderSummary(
                  itemCount,
                  itemTotal,
                  shippingAmount,
                  itemTotal + shippingAmount,
                  currency,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: AppButton(
                    title: orderState is AsyncLoading
                        ? "Placing Order..."
                        : LocaleKeys.placeOrder.tr(),
                    backgroundColor: AppColors.primary,
                    labelColor: AppColors.background,
                    isLoading: orderState.isLoading ? true : false,
                    onTap: () async {
                      if (_selectedAddress == null ||
                          _selectedPayment == null ||
                          _selectedShipping == null ||
                          _approveScreenshot == null ||
                          cartItemsAsync.value == null ||
                          cartItemsAsync.value!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete all selections and upload screenshot',
                            ),
                          ),
                        );
                        return;
                      }

                      final ids = cartItemsAsync.value!
                          .map((e) => e.id)
                          .toList();

                      final request = CreateOrderRequest(
                        orderType: orderType,
                        cartItemIds: ids,
                        shipping: ShippingInfo(
                          address: _selectedAddress!.addressLine1,
                          township: _selectedAddress!.townshipEnName,
                          region: _selectedAddress!.regionEnName,
                          country: _selectedAddress!.country,
                          phone: _selectedAddress!.phone,
                        ),
                        shippingMethodId: _selectedShipping!.id,
                        shippingAccountId: _selectedAddress!.id,
                        paymentAccountId: _selectedPayment!.paymentAccount!.id,
                        approveScreenshoot: _approveScreenshot!,
                      );

                      await ref
                          .read(createOrderNotifierProvider.notifier)
                          .createOrder(request);
                    },
                  ),
                ),

                // button
              ],
            ),
          );
        },
        loading: () => _buildCheckoutShimmerLoading(),
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
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            LocaleKeys.createAddress.tr(),
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
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            _selectedAddress == null
                ? LocaleKeys.selectSavedAddress.tr()
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
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            _selectedShipping == null
                ? LocaleKeys.selectShippingMethod.tr()
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
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(Icons.payment_outlined, color: AppColors.primary),
          title: Text(
            _selectedPayment == null
                ? LocaleKeys.selectShippingMethod.tr()
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
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(Icons.photo, color: AppColors.primary),
          title: Text(
            _approveScreenshot == null
                ? LocaleKeys.uploadPaymentScreenshot.tr()
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
    AsyncValue<BusinessSettingData?> currency,
  ) {
    String formatPrice(double amount) {
      return currency.when(
        data: (businessSetting) {
          if (businessSetting != null) {
            final symbol = businessSetting.currency.symbol;
            final decimalPlaces = businessSetting.currencyDecimalPlaces;
            return '${amount.toStringAsFixed(decimalPlaces)}$symbol';
          }
          return amount.toStringAsFixed(2); // fallback
        },
        loading: () => amount.toStringAsFixed(2),
        error: (_, __) => amount.toStringAsFixed(2),
      );
    }

    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            _buildSummaryRow("Items ($itemCount)", formatPrice(itemTotal)),
            const SizedBox(height: 6),
            _buildSummaryRow("Shipping", formatPrice(shippingAmount)),
            const Divider(),
            _buildSummaryRow("Total", formatPrice(totalCost)),
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
}

Widget _buildCheckoutShimmerLoading() {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      backgroundColor: Colors.grey[50],
      elevation: 0,
      centerTitle: true,
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Shimmer
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 8),

          // Create Address Card Shimmer
          _buildCardShimmer(
            icon: Icons.location_on_outlined,
            titleWidth: 120,
            subtitleWidth: 150,
          ),
          const SizedBox(height: 8),

          // Select Address Card Shimmer
          _buildCardShimmer(
            icon: Icons.location_on_outlined,
            titleWidth: 140,
            subtitleWidth: 200,
            hasSubtitle: true,
          ),

          const SizedBox(height: 16),

          // Shipping Method Header
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 8),

          // Shipping Card Shimmer
          _buildCardShimmer(
            icon: Icons.local_shipping_outlined,
            titleWidth: 130,
            subtitleWidth: 100,
          ),

          const SizedBox(height: 16),

          // Payment Method Header
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 8),

          // Payment Card Shimmer
          _buildCardShimmer(
            icon: Icons.payment_outlined,
            titleWidth: 140,
            subtitleWidth: 120,
          ),
          const SizedBox(height: 8),

          // Screenshot Picker Shimmer
          _buildCardShimmer(icon: Icons.photo, titleWidth: 160),

          const SizedBox(height: 16),

          // Order Summary Header
          _buildSectionHeaderShimmer(),
          const SizedBox(height: 8),

          // Order Summary Card Shimmer
          _buildOrderSummaryShimmer(),

          const SizedBox(height: 30),

          // Place Order Button Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeaderShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: 120,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

Widget _buildCardShimmer({
  required IconData icon,
  required double titleWidth,
  double subtitleWidth = 0,
  bool hasSubtitle = false,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        title: Container(
          width: titleWidth,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: hasSubtitle
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: subtitleWidth,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: subtitleWidth - 30,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: subtitleWidth - 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )
            : null,
        trailing: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

Widget _buildOrderSummaryShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            _buildSummaryRowShimmer(),
            const SizedBox(height: 6),
            _buildSummaryRowShimmer(),
            const SizedBox(height: 6),
            Container(height: 1, color: Colors.white),
            const SizedBox(height: 6),
            _buildSummaryRowShimmer(isTotal: true),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSummaryRowShimmer({bool isTotal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: isTotal ? 40 : 80,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      Container(
        width: isTotal ? 100 : 80,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );
}
