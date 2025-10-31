import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/category/model/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';

class CategoryDetailPage extends ConsumerStatefulWidget {
  final int categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryDetailPage> createState() =>
      _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(categoryDetailNotifierProvider.notifier)
          .getCategoryDetail(widget.categoryId);
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
    final categoryState = ref.watch(categoryDetailNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.4,
        centerTitle: true,
        title: Text(
          'Category Details',
          style: GoogleFonts.poppins(
            fontSize: responsive.subHeading,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: categoryState.when(
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
          final Data? category = resp?.data;
          if (category == null) {
            return Center(
              child: Text(
                'No category information available.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: responsive.body,
                ),
              ),
            );
          }

          final name = category.name;
          final description =
              (category.description?.toString().trim().isEmpty ?? true)
                  ? 'No description available.'
                  : category.description.toString();

          return SingleChildScrollView(
            padding: EdgeInsets.all(responsive.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avatar
                Center(
                  child: CircleAvatar(
                    radius: responsive.iconLarge + 8,
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.category_outlined,
                      size: responsive.iconLarge + 4,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: responsive.paddingMedium),

                // Name
                Text(
                  name.isNotEmpty ? name : 'Unnamed Category',
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

                // Metadata Section
                const Divider(),
                _metaRow(
                  icon: Icons.calendar_today_outlined,
                  label: _sinceText(category.createdAt),
                  responsive: responsive,
                ),
                _metaRow(
                  icon: Icons.update_outlined,
                  label: 'Updated ${_timeAgo(category.updatedAt)}',
                  responsive: responsive,
                ),
                _metaRow(
                  icon: Icons.tag_outlined,
                  label: 'ID: ${category.id}',
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
