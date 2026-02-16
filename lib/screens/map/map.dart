import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('colombo'),
        position: const LatLng(6.9271, 79.8612),
        infoWindow: const InfoWindow(
          title: 'Colombo',
          snippet: 'Capital of Sri Lanka',
        )
      ),
      Marker(
        markerId: const MarkerId('kandy'),
        position: const LatLng(7.2906, 80.6337),
        infoWindow: const InfoWindow(
          title: 'Kandy',
          snippet: 'Cultural center of Sri Lanka',
        ),
      ),
      Marker(
        markerId: const MarkerId('galle'),
        position: const LatLng(6.0535, 80.2158),
        infoWindow: const InfoWindow(
          title: 'Galle',
          snippet: 'Historic coastal city',
        ),
      ),
    ]);
  }

  Future<void> _setMapStyle() async {
    if (_isDarkMode) {
      final String darkMapStyle = await DefaultAssetBundle.of(context)
          .loadString('assets/map_styles/dark_map.json');
      await mapController.setMapStyle(darkMapStyle);
    } else {
      await mapController.setMapStyle(null); // Reset to default light style
    }
  }

  



  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle(); // Apply the map style when the map is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(7.8731, 80.7718), // Sri Lanka coordinates
          zoom: 7,
        ),
        markers: _markers,
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: true,
      ),
    
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}