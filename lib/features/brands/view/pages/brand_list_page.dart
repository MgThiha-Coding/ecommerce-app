import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

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
    ref.read(brandListNotifierProvider.notifier).getNextPage();
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

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade500,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Column(
            children: [
              const BrandListAppBar(),
              const SizedBox(height: 8),
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
                    child: brandListAsync.when(
                      loading: () => brandListShimmer(context),
                      error: (e, _) {
                        toastification.show(
                          title: Text(e.toString()),
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Colors.white,
                        );
                        return const SizedBox.shrink();
                      },
                      data: (brands) {
                        if (brands.isEmpty) {
                          toastification.show(
                            title: const Text(
                              'No Brands Available right now...',
                            ),
                            autoCloseDuration: const Duration(seconds: 3),
                            backgroundColor: Colors.white,
                          );
                          return const SizedBox.shrink();
                        }
                        return brandListView(
                          context,
                          brands,
                          notifier.isNoMore,
                          _scrollController,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandListAppBar extends StatelessWidget {
  const BrandListAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      margin: EdgeInsets.only(top: 18),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          responsive.isMobile
              ? IconButton(
                  style: IconButton.styleFrom(
                    // ignore: deprecated_member_use
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
                  ),
                )
              : SizedBox(width: 48),
          Text(
            'Brands',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }
}

ListView brandListView(
  BuildContext context,
  List<BrandDataModel?> brands,
  bool isNoMore,
  ScrollController scrollController,
) {
  return ListView.separated(
    controller: scrollController,
    itemCount: brands.length,
    separatorBuilder: (_, __) => const SizedBox(height: 6),
    itemBuilder: (context, index) {
      final brandName = brands[index]?.name ?? '';
      final description = brands[index]?.description ?? '';
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (description.isEmpty)
                        ? "No description available"
                        : description,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'See Detail',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

ListView brandListShimmer(BuildContext context, {int itemCount = 12}) {
  return ListView.separated(
    itemCount: itemCount,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(width: 50, height: 50, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 10,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
