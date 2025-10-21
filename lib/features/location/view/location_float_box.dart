import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/location/viewmodel/location_notifier.dart';

class LocationFloatBox extends ConsumerWidget {
  final VoidCallback onConfirm;

  const LocationFloatBox({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    return locationState.when(
      data: (location) {
        if (location == null) return const SizedBox.shrink();

        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Detected Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${location.addressLine ?? ''}, "
                    "${location.township ?? ''}, "
                    "${location.region ?? ''}, "
                    "${location.postalCode ?? ''}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }
}
