import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/location/viewmodel/local_township_notifier.dart';

class AvailableTownshipPage extends ConsumerStatefulWidget {
  final int? townshipId;
  const AvailableTownshipPage(this.townshipId, {super.key});

  @override
  ConsumerState<AvailableTownshipPage> createState() =>
      _AvailableTownshipPageState();
}

class _AvailableTownshipPageState extends ConsumerState<AvailableTownshipPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref
            .read(localTownshipNotifierProvider.notifier)
            .fetchByRegion(widget.townshipId!);
      });
    });
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 17,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.white,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 150, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 12, width: 100, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final townshipAsync = ref.watch(localTownshipNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Available Township',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w300,
            fontSize: fontSize.subHeading,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // ignore: deprecated_member_use
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          child: townshipAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text('Township unavailable'));
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final townshipMmName = data[index].mmName;
                  final townshipEnName = data[index].enName;
                  final township = data[index];
                  return Card(
                    color: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, township);
                      },
                      title: Text(
                        townshipMmName,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.subHeading,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        townshipEnName,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (err, _) {
              return Center(child: Text(err.toString()));
            },
            loading: _buildShimmerList,
          ),
        ),
      ),
    );
  }
}
