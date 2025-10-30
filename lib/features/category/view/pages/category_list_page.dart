import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_detail_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:shimmer/shimmer.dart';

class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key});

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref.read(categoryListNotifierProvider.notifier).getNextPage();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(categoryListNotifierProvider.notifier).getNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryListAsync = ref.watch(categoryListNotifierProvider);
    final notifier = ref.read(categoryListNotifierProvider.notifier);
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      /*
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title: Text(
          'Categories',
          style: GoogleFonts.poppins(
            fontSize: responsive.subHeading,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      */
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.blue.shade50,
              onRefresh: () => notifier.reset(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                    notifier.getNextPage();
                  }
                  return false;
                },
                child: categoryListAsync.when(
                  loading: () => categoryListShimmer(context),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (categories) {
                    if (categories.isEmpty) return const Center(child: Text('No categories'));
                    return categoryListView(context, categories, notifier.isNoMore, _scrollController, responsive);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ListView categoryListView(
  BuildContext context,
  List<CategoryDataModel?> categories,
  bool isNoMore,
  ScrollController scrollController,
  Responsive responsive,
) {
  return ListView.separated(
    controller: scrollController,
    itemCount: categories.length,
    separatorBuilder: (_, __) => SizedBox(height: responsive.body),
    itemBuilder: (context, index) {
      final categoryName = categories[index]?.name ?? '';
      final description = categories[index]?.description ?? '';
      final categoryId = categories[index]?.id;
      return Card(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.body),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.body,
            vertical: responsive.body * 1.2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.subHeading,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.caption),
                    Text(
                      description.isEmpty ? "No description available" : description,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.caption,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.body),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(categoryId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.body * 2),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.body * 2,
                    vertical: responsive.body * 0.8,
                  ),
                ),
                child: Text(
                  'See Detail',
                  style: TextStyle(
                    fontSize: responsive.caption,
                    color: AppColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

ListView categoryListShimmer(BuildContext context, {int itemCount = 12}) {
  final responsive = Responsive(context);
  return ListView.separated(
    itemCount: itemCount,
    separatorBuilder: (_, __) => SizedBox(height: responsive.body),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.body),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.body,
            vertical: responsive.body,
          ),
          child: Row(
            children: [
              Container(width: responsive.body, height: responsive.body, color: Colors.grey.shade300),
              SizedBox(width: responsive.body),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: responsive.body,
                  color: Colors.grey.shade300,
                ),
              ),
              SizedBox(width: responsive.body),
              Container(
                width: responsive.body,
                height: responsive.body,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(responsive.body),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
