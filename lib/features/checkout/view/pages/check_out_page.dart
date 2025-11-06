import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/create_address/model/address_response.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/address_list_page.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/create_address_page.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_list_page.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:shimmer/shimmer.dart';

class CheckOutPage extends ConsumerStatefulWidget {
  const CheckOutPage({super.key});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  AddressItem? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final cartItemsAsync = ref.watch(cartNotifierProvider);
    final currency = ref.watch(businessSettingNotifierProvider);

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
            color: AppColors.textSecondary,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address
                _buildSectionHeader(
                  LocaleKeys.deliveryAddress.tr(),
                  responsive,
                ),

                const SizedBox(height: 8),

                // Create Address
                _buildCreateAddressCard(responsive),

                const SizedBox(height: 8),

                // Select Address
                _buildSelectAddressCard(responsive),

                const SizedBox(height: 16),

                _buildOrderSummary(itemCount, itemTotal, currency),

                const SizedBox(height: 18),

                // next to shipping method >>
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: AppButton(
                    title: "Shipping Method >",
                    onTap: () {
                      if (_selectedAddress == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please add your address.",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: Responsive(context).body,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.background,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShippingMethodListPage(_selectedAddress!),
                          ),
                        );
                      }
                    },

                    backgroundColor: AppColors.primary,
                    labelColor: AppColors.background,
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
      style: TextStyle(
        fontFamily: "Poppins",
        fontSize: responsive.body,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
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
            'New Address',
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

  Widget _buildOrderSummary(
    int itemCount,
    double itemTotal,
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
            const Divider(),
            _buildSummaryRow("Total", formatPrice(itemTotal)),
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
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green,
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
