import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';

class CategoryDetailPage extends ConsumerStatefulWidget {
  final int? categoryId;
  const CategoryDetailPage(this.categoryId, {super.key});

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.categoryId != null) {
        ref
            .read(categoryDetailNotifierProvider.notifier)
            .getCategoryDetail(widget.categoryId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final categoryDetailAsync = ref.watch(categoryDetailNotifierProvider);
    //final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Category Detail',
          style: GoogleFonts.poppins(
            fontSize: responsive.subHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: categoryDetailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.paddingMedium),
              child: Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: responsive.body,
                ),
              ),
            ),
          ),
          data: (categoryDetail) {
            if (categoryDetail?.data == null) {
              return Center(
                child: Text(
                  'No category information available.',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: responsive.body,
                  ),
                ),
              );
            }

            final category = categoryDetail!.data;
            final categoryName = category.name;
            final description =
                category.description ?? 'No description available';

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header / Avatar
                  Container(
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.category_outlined,
                          size: 50,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.paddingLarge),

                  // Category Name
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.paddingLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: responsive.heading,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: responsive.paddingSmall),

                        // Description
                        Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: responsive.body,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: responsive.paddingLarge),

                        // Info rows
                        _infoRow(
                          label: 'ID',
                          value: category.id.toString(),
                          responsive: responsive,
                        ),
                        _infoRow(
                          label: 'Created At',
                          value: category.createdAt.toString(),
                          responsive: responsive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
