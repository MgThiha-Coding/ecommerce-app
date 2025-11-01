import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/shipping/viewmodel/shipping_method_notifier.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ShippingMethodListPage extends ConsumerStatefulWidget {
  const ShippingMethodListPage({super.key});

  @override
  ConsumerState<ShippingMethodListPage> createState() =>
      _ShippingMethodListPageState();
}

class _ShippingMethodListPageState
    extends ConsumerState<ShippingMethodListPage> {
  int? selectedShippingId;
  ShippingMethod? selectedShipping;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final shippingAsync = ref.watch(shippingMethodNotifierProvider);
    final currencyAsync = ref.watch(businessSettingNotifierProvider);

    String formatPrice(String amount) {
      final parsedAmount = double.tryParse(amount) ?? 0;
      return currencyAsync.when(
        data: (businessSetting) {
          if (businessSetting != null) {
            final symbol = businessSetting.currency.symbol;
            final decimalPlaces = businessSetting.currencyDecimalPlaces;
            return '${parsedAmount.toStringAsFixed(decimalPlaces)}$symbol';
          }
          return parsedAmount.toStringAsFixed(2);
        },
        loading: () => parsedAmount.toStringAsFixed(2),
        error: (_, __) => parsedAmount.toStringAsFixed(2),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Select Shipping Method',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: shippingAsync.when(
        data: (response) {
          if (response == null  || response.data.isEmpty) {
            return const Center(
              child: Text(
                'No shipping methods available.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final data = response.data;
          return ListView.builder(
             padding: Responsive(context).isMobile? const EdgeInsets.all(12):const EdgeInsets.all(50),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final isSelected = selectedShippingId == item.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedShippingId = item.id;
                    selectedShipping = item;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade500,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                fontSize: responsive.subHeading,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (item.amount.isNotEmpty)
                              Text(
                                formatPrice(item.amount),
                                style: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                  color: Colors.black54,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (item.descriptions.isNotEmpty)
                              Text(
                                item.descriptions,
                                style: GoogleFonts.poppins(
                                  fontSize: responsive.body - 1,
                                  color: Colors.black45,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: _buildShimmerList,
        error: (err, _) => Center(
          child: Text(
            err.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedShipping == null
              ? null
              : () => Navigator.pop(context, selectedShipping),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: Responsive(context).body,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 100, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: 150, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
