import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/model/brand_detail_response.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';

class BrandDetailPage extends ConsumerStatefulWidget {
  final int brandId;
  const BrandDetailPage({super.key, required this.brandId});

  @override
  ConsumerState<BrandDetailPage> createState() => _BrandDetailPageState();
}

class _BrandDetailPageState extends ConsumerState<BrandDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(brandDetailNotifierProvider.notifier)
          .getBrandDetail(widget.brandId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final brandState = ref.watch(brandDetailNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.4,
        centerTitle: true,
        title: Text(
          'Brand Details',
          style: GoogleFonts.poppins(
            fontSize: responsive.subHeading,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        foregroundColor: AppColors.textPrimary,
      ),
      body: brandState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.paddingMedium),
            child: Text(
              err.toString(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: responsive.body,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (resp) {
          final Data? brand = resp?.data;
          if (brand == null) {
            return Center(
              child: Text(
                'No brand information available.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: responsive.body,
                ),
              ),
            );
          }

          final name = brand.name;
          final description = brand.description?.toString() ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(responsive.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avatar with brand initial
                Center(
                  child: CircleAvatar(
                    radius: responsive.iconLarge + 8,
                    backgroundColor: AppColors.background,
                    child: Text(
                      (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                      style: TextStyle(
                        fontSize: responsive.iconLarge,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: responsive.paddingMedium),

                // Name
                Text(
                  name.isNotEmpty ? name : 'Unnamed Brand',
                  style: TextStyle(
                    fontSize: responsive.heading,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: responsive.paddingSmall),

                // Description (if available)
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: responsive.body,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    'No description available.',
                    style: TextStyle(
                      fontSize: responsive.body,
                      color: AppColors.textSecondary,
                    ),
                  ),

                SizedBox(height: responsive.paddingLarge),

                // Info rows
                _infoRow(
                  label: 'ID',
                  value: brand.id.toString(),
                  responsive: responsive,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required Responsive responsive,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.paddingSmall),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.body,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: responsive.body,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
