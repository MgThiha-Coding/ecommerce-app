
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

Widget productPreview(
  BuildContext context,
  List<ProductDataModel?> productList,
) {
  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final productName = productList[index]?.name ?? '';
        final productImage = productList[index]?.productImage ?? '';
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            height: 130,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: productImage.isEmpty
                          ? Image.asset(
                              AppImage.emptyContainer,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    AppImage.emptyContainer,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      productName,
                      style: GoogleFonts.poppins(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

