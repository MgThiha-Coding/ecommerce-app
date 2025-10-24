import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                
                  child: ListTile(
                    onTap: (){
                      Navigator.pop(context,township);
                    },
                    title: Text(townshipMmName),
                    subtitle: Text(townshipEnName),
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
    );
  }
}
