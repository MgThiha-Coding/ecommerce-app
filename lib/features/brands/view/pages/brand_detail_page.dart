import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 365) {
      final years = diff.inDays ~/ 365;
      return years == 1 ? 'a year ago' : '$years years ago';
    } else if (diff.inDays >= 30) {
      final months = diff.inDays ~/ 30;
      return months == 1 ? 'a month ago' : '$months months ago';
    } else if (diff.inDays > 0) {
      return diff.inDays == 1 ? 'yesterday' : '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'just now';
  }

  String _sinceText(DateTime date) {
    return 'Since ${DateFormat('MMMM yyyy').format(date)}';
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
            color: AppColors.textSecondary,
          ),
        ),
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
          final description =
              (brand.description?.toString().trim().isEmpty ?? true)
                  ? 'No description available.'
                  : brand.description.toString();

          return SingleChildScrollView(
            padding: EdgeInsets.all(responsive.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Icon/Avatar
                Center(
                  child: CircleAvatar(
                    radius: responsive.iconLarge + 8,
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.store_mall_directory_outlined,
                      size: responsive.iconLarge + 4,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: responsive.paddingMedium),

                // Name
                Text(
                  name.isNotEmpty ? name : 'Unnamed Brand',
                  style: TextStyle(
                    fontSize: responsive.subHeading,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: responsive.paddingSmall),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: responsive.body,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: responsive.paddingLarge),
                const Divider(),

                // Metadata
                _metaRow(
                  icon: Icons.calendar_today_outlined,
                  label: _sinceText(brand.createdAt),
                  responsive: responsive,
                ),
                _metaRow(
                  icon: Icons.update_outlined,
                  label: 'Updated ${_timeAgo(brand.updatedAt)}',
                  responsive: responsive,
                ),
                _metaRow(
                  icon: Icons.tag_outlined,
                  label: 'ID: ${brand.id}',
                  responsive: responsive,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metaRow({
    required IconData icon,
    required String label,
    required Responsive responsive,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.paddingSmall, top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.body,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
