import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';

Widget cartList(
  BuildContext context,
  List<CartItemModel> cartItems,
  Responsive fontSize,
  AsyncValue<BusinessSettingData?> currencyAsync,
  CartState cartState,
  WidgetRef ref,
) {
  return ListView.builder(
    itemCount: cartItems.length,
    itemBuilder: (context, index) {
      final item = cartItems[index];
      final isLoading = cartState.itemLoading[item.id] ?? false;
      final errorMsg = cartState.itemError[item.id];

      String formatPrice(double price, BusinessSettingData? businessSetting) {
        if (businessSetting != null) {
          final symbol = businessSetting.currency.symbol;
          final decimalPlaces = businessSetting.currencyDecimalPlaces;
          return '${price.toStringAsFixed(decimalPlaces)}$symbol';
        }
        return price.toStringAsFixed(2);
      }

      return Stack(
        children: [
          Card(
            color: AppColors.background,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              title: Text(
                item.productName,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.body,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: fontSize.caption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Unit Price with Currency
                  currencyAsync.when(
                    data: (businessSetting) {
                      final unitPrice = item.uomPrice;
                      final formattedUnitPrice = formatPrice(
                        unitPrice,
                        businessSetting,
                      );
                      return Text(
                        'Price: $formattedUnitPrice',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    error: (err, _) {
                      return Text(
                        'Price: ${item.uomPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    loading: () {
                      return Text(
                        'Price: ${item.uomPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),

                  // Subtotal with Currency
                  currencyAsync.when(
                    data: (businessSetting) {
                      final subtotal = item.uomPrice * item.quantity;
                      final formattedSubtotal = formatPrice(
                        subtotal,
                        businessSetting,
                      );
                      return Text(
                        'Subtotal: $formattedSubtotal',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    error: (err, _) {
                      final subtotal = item.uomPrice * item.quantity;
                      return Text(
                        'Subtotal: ${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    loading: () {
                      final subtotal = item.uomPrice * item.quantity;
                      return Text(
                        'Subtotal: ${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.caption,
                          color: AppColors.textSecondary,
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
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: fontSize.caption,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        ref
                            .read(removeCartItemNotifierProvider.notifier)
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
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
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
  );
}
