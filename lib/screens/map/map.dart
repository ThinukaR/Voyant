import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/quest_models.dart';
import '../../services/quest_service.dart';
import '../quest/views/quest_start_screen.dart';
import '../quest/views/quest_screen.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isDarkMode = true;
  String? _selectedMarkerId;
  late OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = null;
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('colombo'),
        position: const LatLng(6.9271, 79.8612),
        infoWindow: const InfoWindow(title: ''),
        onTap: () => _showCustomInfoWindow('Colombo', 'Capital of Sri Lanka'),
      ),
      Marker(
        markerId: const MarkerId('kandy'),
        position: const LatLng(7.2906, 80.6337),
        infoWindow: const InfoWindow(title: ''),
        onTap: () =>
            _showCustomInfoWindow('Kandy', 'Cultural center of Sri Lanka'),
      ),
      Marker(
        markerId: const MarkerId('galle'),
        position: const LatLng(6.024782559149793, 80.2180335396037),
        infoWindow: const InfoWindow(title: ''),
        onTap: _onGalleMarkerTapped,
      ),
    ]);
  }

  void _showCustomInfoWindow(String title, String snippet) {
    _removeCustomInfoWindow();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4C1D95), const Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snippet,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeCustomInfoWindow() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onGalleMarkerTapped() async {
    _showCustomInfoWindow(
      'Galle',
      'Historic coastal city',
    );

    Future.delayed(const Duration(milliseconds: 500), () async {
      _removeCustomInfoWindow();
      if (!mounted) return;

      // Load the Galle quest from the backend
      Quest? galleQuest;
      QuestProgress? existingProgress;
      try {
        final questResponse = await QuestService().getAllUserQuests();
        galleQuest = questResponse.mainQuests.firstWhere(
          (q) => q.title.toLowerCase().contains('galle'),
          orElse: () => throw Exception('Galle quest not found'),
        );
        existingProgress = galleQuest.progress;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not load Galle quest: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final quest = galleQuest;
      if (!mounted) return;

      // If already in progress, go straight to the quest screen
      if (quest.isInProgress && existingProgress != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                QuestScreen(quest: quest, initialProgress: existingProgress),
          ),
        );
        return;
      }

      // If completed, show a message instead of re-starting
      if (quest.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already completed the Galle quest!'),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }

      // Show start animation, then call the backend to start the quest
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => QuestStartScreen(
          questTitle: quest.title,
          questId: quest.id,
          onQuestStarted: () async {
            try {
              final progress = await QuestService().startQuest(quest.id);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (context) => QuestScreen(
                      quest: quest,
                      initialProgress: progress,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Error starting quest: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      );
    });
  }

  Future<void> _setMapStyle() async {
    if (_isDarkMode) {
      final String darkMapStyle = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/map_styles/dark_map.json');
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
        onTap: (_) => _removeCustomInfoWindow(),
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
    _removeCustomInfoWindow();
    mapController.dispose();
    super.dispose();
  }
}
