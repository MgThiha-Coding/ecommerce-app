import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/view/widgets/app_bar_widget.dart';
import 'package:picoshop_theme2/features/home/view/widgets/brand_list_widget.dart';
import 'package:picoshop_theme2/features/home/view/widgets/categories_list_widget.dart';
import 'package:picoshop_theme2/features/home/view/widgets/product_list_widget.dart';
import 'package:picoshop_theme2/features/home/view/widgets/section_header_widget.dart';
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
      ref.read(brandListNotifierProvider.notifier).getBrandList();
      ref.read(categoriesListNotifierProvider.notifier).getCagetoryList();
      ref.read(productNotifierProvider.notifier).getProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade500,
                Colors.blue.shade200,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.value(mobile: 10, tablet: 30, desktop: 50),
              ),
              child: Column(
                children: [
                  const AppBarSection(),
                  ResponsiveGap(responsive: responsive),
                  SectionBlock(
                    title: "Brands",
                    responsive: responsive,
                    child: const BrandListWidget(),
                  ),
                  SectionBlock(
                    title: "Categories",
                    responsive: responsive,
                    child: const CategoriesListWidget(),
                  ),
                  SectionBlock(
                    title: "Products",
                    responsive: responsive,
                    child: const ProductListWidget(),
                  ),
                ],
              ),
            ),
          ),
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
    return SizedBox(
      height: responsive.isMobile ? mobile : nonMobile,
    );
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
        SectionHeaderWidget(header: title, onTap: () {}),
        ResponsiveGap(responsive: responsive, mobile: 12, nonMobile: 6),
        child,
        ResponsiveGap(responsive: responsive),
      ],
    );
  }
}
