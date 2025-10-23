import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Model for storing location info
class UserLocation {
  final double latitude;
  final double longitude;
  final String? addressLine;
  final String? region; // administrative area
  final String? township; // locality
  final String? postalCode;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.addressLine,
    this.region,
    this.township,
    this.postalCode,
  });
}

/// StateNotifier to manage location
class LocationNotifier extends StateNotifier<AsyncValue<UserLocation?>> {
  LocationNotifier() : super(const AsyncValue.data(null));

  /// Request location permission and fetch current location
  Future<void> fetchCurrentLocation() async {
    state = const AsyncValue.loading();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncValue.error(
          'Location services are disabled.',
          StackTrace.current,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = AsyncValue.error(
            'Location permission denied',
            StackTrace.current,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncValue.error(
          'Location permissions are permanently denied. Please enable them in settings.',
          StackTrace.current,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get human-readable address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty) {
        state = AsyncValue.error(
          'Failed to get address from location',
          StackTrace.current,
        );
        return;
      }

      final place = placemarks.first;

      final location = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        addressLine: place.street,
        region: place.administrativeArea,
        township: place.locality,
        postalCode: place.postalCode,
      );

      state = AsyncValue.data(location);
    } catch (e, st) {
      state = AsyncValue.error('Error fetching location: $e', st);
    }
  }
}

/// Riverpod provider
final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<UserLocation?>>(
  (ref) => LocationNotifier(),
);
