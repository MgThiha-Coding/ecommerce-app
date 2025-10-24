import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/location/view/available_township_page.dart';
import 'package:picoshop_theme2/features/location/viewmodel/local_region_notifier.dart';

class AvailableRegionPage extends ConsumerStatefulWidget {
  const AvailableRegionPage({super.key});

  @override
  ConsumerState<AvailableRegionPage> createState() =>
      _AvailableRegionPageState();
}

class _AvailableRegionPageState extends ConsumerState<AvailableRegionPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref.read(localRegionNotifierProvider.notifier).getNextPage();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(localRegionNotifierProvider.notifier).getNextPage();
      }
    });
  }

  Future<void> reset() async {
    await Future.wait([ref.read(localRegionNotifierProvider.notifier).reset()]);
    ref.read(localRegionNotifierProvider.notifier).getNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final regionAsync = ref.watch(localRegionNotifierProvider);
    final fontSize = Responsive(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Available Regions',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w300,
            fontSize: fontSize.subHeading,
            color: AppColors.textSecondary,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: reset,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: regionAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("Region unavailable"));
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final regionMmName = data[index].mmName;
                  final regionEnName = data[index].enName;
                  final townshipId = data[index].id;
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AvailableTownshipPage(townshipId),
                          ),
                        );
                      },
                      title: Text(regionMmName.toString()),
                      subtitle: Text(regionEnName.toString()),
                    ),
                  );
                },
              );
            },
            error: (err, _) {
              return Center(child: Text(err.toString()));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
