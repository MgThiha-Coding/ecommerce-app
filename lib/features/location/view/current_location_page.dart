import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class CurrentLocationPage extends StatefulWidget {
  const CurrentLocationPage({Key? key}) : super(key: key);

  @override
  State<CurrentLocationPage> createState() => _CurrentLocationPageState();
}

class _CurrentLocationPageState extends State<CurrentLocationPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(0, 0);
  bool _loading = true;

  int _selectedMapStyle = 0;

  final List<MapStyle> _mapStyles = [
    MapStyle(
      name: 'Satellite',
      urlTemplate:
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    ),
    MapStyle(
      name: 'Dark',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ),
    MapStyle(
      name: 'Terrain',
      urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // _showError('Location services are disabled. Please enable GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permissions are permanently denied. Please enable in settings.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
      });

      _mapController.move(_currentLocation, 16);
    } catch (e) {
      _showError('Failed to get location: $e');
    }
  }

  void _showError(String message) {
    setState(() => _loading = false);
    /*
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    */
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildMapShimmerLoading();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Select Your Location',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: Responsive(context).subHeading,
          ),
        ),
        actions: [
          // Map style selector
          PopupMenuButton<int>(
            color: AppColors.background,
            onSelected: (index) {
              setState(() {
                _selectedMapStyle = index;
              });
            },
            itemBuilder: (context) => _mapStyles.asMap().entries.map((entry) {
              return PopupMenuItem(
                value: entry.key,
                child: Text(entry.value.name),
              );
            }).toList(),
            icon: const Icon(Icons.layers),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 16,
          minZoom: 3,
          maxZoom: 18,
          onTap: (tapPosition, latlng) {
            setState(() => _currentLocation = latlng);
            _mapController.move(latlng, 16);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: _mapStyles[_selectedMapStyle].urlTemplate,
            subdomains: _mapStyles[_selectedMapStyle].subdomains,
            userAgentPackageName: 'com.example.picoshop_theme2',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.background,
            onPressed: () async {
              try {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                LatLng newLocation = LatLng(
                  position.latitude,
                  position.longitude,
                );
                setState(() => _currentLocation = newLocation);
                _mapController.move(newLocation, 16);
              } catch (e) {
                _showError('Failed to get current location: $e');
              }
            },
            heroTag: 'center_location',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: AppColors.background,
            onPressed: () {
              Navigator.pop(context, _currentLocation);
            },
            heroTag: 'confirm_location',
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class MapStyle {
  final String name;
  final String urlTemplate;
  final List<String> subdomains;

  MapStyle({
    required this.name,
    required this.urlTemplate,
    this.subdomains = const [],
  });
}

Widget _buildMapShimmerLoading() {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 200,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    body: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Map area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Bottom controls placeholder
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
