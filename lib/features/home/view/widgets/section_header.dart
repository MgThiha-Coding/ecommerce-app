import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

Widget sectionHeader(Responsive fontSize, String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: fontSize.body,
            color: AppColors.primary,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            LocaleKeys.seeAll.tr(),
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: fontSize.body,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
