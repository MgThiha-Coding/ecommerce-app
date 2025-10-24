import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/location/model/local_region_response.dart';
import 'package:picoshop_theme2/features/location/view/available_township_page.dart';
import 'package:picoshop_theme2/features/location/viewmodel/local_region_notifier.dart';

class RegionDropdown extends ConsumerStatefulWidget {
  final Function(RegionItem region)? onChanged;
  final RegionItem? selectedRegion;

  const RegionDropdown({Key? key, this.onChanged, this.selectedRegion})
    : super(key: key);

  @override
  ConsumerState<RegionDropdown> createState() => _RegionDropdownState();
}

class _RegionDropdownState extends ConsumerState<RegionDropdown> {
  RegionItem? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(localRegionNotifierProvider);

    return regionState.when(
      data: (regions) {
        return DropdownButtonFormField<RegionItem>(
          value: _selectedRegion,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Region',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: regions.map((region) {
            return DropdownMenuItem<RegionItem>(
              value: region,
              child: Text(region.enName ?? region.mmName ?? '-'),
            );
          }).toList(),
          onChanged: (region) async {
            if (region == null) return;

            setState(() => _selectedRegion = region);
            widget.onChanged?.call(region);

            final selectedTownship = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvailableTownshipPage(region.id),
              ),
            );

            if (selectedTownship != null) {
             
            }
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
