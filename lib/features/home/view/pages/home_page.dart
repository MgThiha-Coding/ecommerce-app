import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/service/pagination_provider.dart';
import 'package:picoshop_theme2/features/home/view/widgets/home_appbar.dart';
import 'package:picoshop_theme2/features/home/view/widgets/section_header.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFirstProductList();
    });
  }

  Future<void> getProductList() async {
    Future.microtask(() {
      final state = ref.watch(productNotifierProvider);
      if (!state.isLoading) {
        ref
            .read(productNotifierProvider.notifier)
            .getProductList(ref.watch(pageProvider));
      }
    });
  }

  Future<void> getFirstProductList() async {
    Future.microtask(() {
      ref
          .read(productNotifierProvider.notifier)
          .getProductList(ref.watch(pageProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    ref.listen(productNotifierProvider, (previous, next) {
      next.when(
        data: (data) {
          ref.read(pageProvider.notifier).update((state) => state + 1);
        },
        error: (error, _) {},
        loading: () {},
      );
    });

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade500,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: getProductList,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
                      getProductList();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.value(
                          mobile: 10,
                          tablet: 30,
                          desktop: 50,
                        ),
                      ),
                      child: Column(
                        children: [
                          const HomeAppBar(),
                          /*
                          ResponsiveGap(responsive: responsive),
                          const ProductPreviewSlider(),
                          ResponsiveGap(responsive: responsive),
                          responsive.isMobile
                              ? Column(
                                  children: [
                                    SectionBlock(
                                      title: "Brands",
                                      responsive: responsive,
                                      child: const BrandSection(),
                                    ),
                                    SectionBlock(
                                      title: "Categories",
                                      responsive: responsive,
                                      child: const CategorySection(),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SectionBlock(
                                          title: "Brands",
                                          responsive: responsive,
                                          child: const BrandSection(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SectionBlock(
                                          title: "Categories",
                                          responsive: responsive,
                                          child: const CategorySection(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          SectionBlock(
                            title: "Products",
                            responsive: responsive,
                            child: const ProductPreviewSection(),
                          ),
                          */
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveGap extends StatelessWidget {
  final Responsive responsive;
  final double mobile;
  final double nonMobile;

  const ResponsiveGap({
    super.key,
    required this.responsive,
    this.mobile = 16,
    this.nonMobile = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: responsive.isMobile ? mobile : nonMobile);
  }
}

class SectionBlock extends StatelessWidget {
  final String title;
  final Widget child;
  final Responsive responsive;

  const SectionBlock({
    super.key,
    required this.title,
    required this.child,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(header: title, onTap: () {}),
        ResponsiveGap(responsive: responsive, mobile: 12, nonMobile: 6),
        child,
        ResponsiveGap(responsive: responsive),
      ],
    );
  }
}
