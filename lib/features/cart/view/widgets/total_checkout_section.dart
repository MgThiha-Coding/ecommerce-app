import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';
import 'package:picoshop_theme2/features/checkout/view/pages/check_out_page.dart';
import 'package:picoshop_theme2/shared/app_button.dart';

Widget totalCheckoutSection(
  BuildContext context,
  double totalCost,
  Responsive fontSize,
  AsyncValue<BusinessSettingData?> currencyAsync,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: fontSize.subHeading,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            currencyAsync.when(
              data: (businessSetting) {
                final formattedTotal = '${totalCost.toStringAsFixed(businessSetting!.currencyDecimalPlaces)}${businessSetting.currency.symbol}';
                return Text(
                  formattedTotal,
                  style: TextStyle(
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                );
              },
              error: (err, _) {
                return Text(
                  totalCost.toStringAsFixed(2),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                );
              },
              loading: () {
                return Text(
                  totalCost.toStringAsFixed(2),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: AppButton(
            title: LocaleKeys.checkout.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckOutPage(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            labelColor: AppColors.background,
          ),
        ),
      ],
    ),
  );
}
