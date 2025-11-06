import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/category/view/widgets/category_list_loading.dart';
import 'package:picoshop_theme2/features/category/view/widgets/category_listview.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';

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
      body: RefreshIndicator(
        color: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        onRefresh: () => notifier.reset(),
        child: NotificationListener<ScrollNotification>(
          /*
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              notifier.getNextPage();
            }
            return false;
          },
          */
          child: categoryListAsync.when(
            loading: () => categoryListLoading(context),
            error: (e, _) => const SizedBox.shrink(),
            data: (categories) {
              if (categories.isEmpty) {
                return const Center(child: Text('No categories'));
              }
              return categoryListView(
                context,
                categories,
                notifier.isNoMore,
                _scrollController,
                responsive,
              );
            },
          ),
        ),
      ),
    );
  }
}
