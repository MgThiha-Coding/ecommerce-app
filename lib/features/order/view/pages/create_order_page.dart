import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
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
import 'package:picoshop_theme2/features/create_address/model/address_response.dart';
import 'package:picoshop_theme2/features/order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/order/model/response/create_order_response.dart';
import 'package:picoshop_theme2/features/order/viewmodel/create_order_notifier.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';
import 'package:picoshop_theme2/features/payment/view/payment_list_page.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:shimmer/shimmer.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  final AddressItem? selectedAddress;
  final ShippingMethod? selectedShipping;
  const CreateOrderPage(
    this.selectedAddress,
    this.selectedShipping, {
    super.key,
  });

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  PaymentMethod? _selectedPayment;
  File? _approveScreenshot;
  final ImagePicker _picker = ImagePicker();

  String orderType = "delivery";
  List<int> cartItemIds = [];
  ShippingInfo? shipping;
  int? paymentAccountId;

  // Image size validation
  bool _validateImageSize() {
    if (_approveScreenshot == null) return true;

    final fileSize = _approveScreenshot!.lengthSync();
    const maxSize = 1 * 1024 * 1024;

    return fileSize <= maxSize;
  }


  Future<void> _pickScreenshot(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileSize = await file.length();
      const maxSize = 1 * 1024 * 1024;

      if (fileSize > maxSize) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB. Maximum allowed is 1   MB.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      setState(() {
        _approveScreenshot = file;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Screenshot picker widget
  Widget _buildScreenshotPicker() {
    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(8),
        child: _approveScreenshot != null
            ? Stack(
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _approveScreenshot!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${(_approveScreenshot!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _approveScreenshot = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTap: () => _pickScreenshot(context),
                behavior: HitTestBehavior.opaque,
                child: DottedBorder(
                  child: SizedBox.expand(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.uploadPaymentScreenshot.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Max size: 1 MB',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
              SnackBar(
                content: Text(
                  "Order placed successfully!",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: Responsive(context).body,
                    color: AppColors.textPrimary,
                  ),
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: AppColors.background,
              ),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                err.toString(),
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: Responsive(context).body,
                  color: AppColors.textPrimary,
                ),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.background,
            ),
          );
        },
      );
    });

    return WillPopScope(
      onWillPop: () {
        ref.read(createOrderNotifierProvider.notifier).cancel();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Create Order',
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
            final shippingAmount = widget.selectedShipping != null
                ? double.tryParse(widget.selectedShipping!.amount) ?? 0.0
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    LocaleKeys.paymentMethod.tr(),
                    responsive,
                  ),
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
                      title: LocaleKeys.placeOrder.tr(),
                      backgroundColor: AppColors.primary,
                      labelColor: AppColors.background,
                      isLoading: orderState is AsyncLoading,
                      onTap: () async {
                        // Validate all required fields including image size
                        if (widget.selectedAddress == null ||
                            _selectedPayment == null ||
                            widget.selectedShipping == null ||
                            _approveScreenshot == null ||
                            cartItemsAsync.value == null ||
                            cartItemsAsync.value!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please complete all selections and upload screenshot",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: Responsive(context).body,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.background,
                            ),
                          );
                          return;
                        }

                        // Validate image size before submission
                        if (!_validateImageSize()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Image size exceeds 1 MB limit. Please select a smaller image.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final ids = cartItemsAsync.value!
                            .map((e) => e.id)
                            .toList();

                        final shippingInfo = ShippingInfo(
                          address: widget.selectedAddress!.addressLine1,
                          township: widget.selectedAddress!.townshipEnName,
                          region: widget.selectedAddress!.regionEnName,
                          country: widget.selectedAddress!.country,
                          phone: widget.selectedAddress!.phone,
                        );

                        final request = CreateOrderRequest(
                          orderType: orderType,
                          cartItemIds: ids,
                          shipping: shippingInfo,
                          shippingMethodId: widget.selectedShipping!.id,
                          paymentAccountId:
                              _selectedPayment!.paymentAccount!.id,
                          approveScreenshot: _approveScreenshot!,
                        );

                        await ref
                            .read(createOrderNotifierProvider.notifier)
                            .createOrder(request);

                        final currentState = ref.read(
                          createOrderNotifierProvider,
                        );
                        currentState.when(
                          data: (data) {
                            if (data != null && data.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Order ${data.data?.orderNumber} created successfully!',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: AppColors.textPrimary,
                                      fontSize: Responsive(context).body,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.background,
                                ),
                              );
                            }
                          },
                          loading: () {},
                          error: (err, _) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err.toString())),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => _buildCheckoutShimmerLoading(),
          error: (err, _) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Responsive responsive) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: responsive.body,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
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
          leading: const Icon(Icons.payment_outlined, color: AppColors.textSecondary),
          title: Text(
            _selectedPayment == null
                ? LocaleKeys.paymentMethod.tr()
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
          return amount.toStringAsFixed(2);
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
            color: Colors.black87,
          ),
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
