import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/view/widgets/brand_list_loading.dart';
import 'package:picoshop_theme2/features/brands/view/widgets/brand_list_view.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';

class BrandListPage extends ConsumerStatefulWidget {
  const BrandListPage({super.key});

  @override
  ConsumerState<BrandListPage> createState() => _BrandListPageState();
}

class _BrandListPageState extends ConsumerState<BrandListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref.read(brandListNotifierProvider.notifier).getNextPage();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(brandListNotifierProvider.notifier).getNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandListAsync = ref.watch(brandListNotifierProvider);
    final notifier = ref.read(brandListNotifierProvider.notifier);
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        onRefresh: () => notifier.reset(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              notifier.getNextPage();
            }
            return false;
          },
          child: brandListAsync.when(
            loading: () => brandListLoading(context),
            error: (e, _) => const SizedBox.shrink(),
            data: (brands) {
              if (brands.isEmpty) {
                return const Center(child: Text('No brands'));
              }
              return brandListView(
                context,
                brands,
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
