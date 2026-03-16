import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import 'package:voyant/screens/trips/views/trip_screen.dart';
import 'package:voyant/screens/quest/views/quests_list_screen.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final List<Map<String, dynamic>> trips = [
    {
      'title': 'Colombo Explorer',
      'location': 'Colombo, Sri Lanka',
      'progress': 0.4,
      'questsDone': 4,
      'totalQuests': 10,
      'status': 'Active',
      'statusColor': Colors.green,
      'icon': '🏙️',
    },
    {
      'title': 'Galle Fort Adventure',
      'location': 'Galle, Sri Lanka',
      'progress': 0.85,
      'questsDone': 17,
      'totalQuests': 20,
      'status': 'In Progress',
      'statusColor': Colors.orange,
      'icon': '🏯',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'My Trips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(trips[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(trip['icon'], style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        trip['location'],
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (trip['statusColor'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (trip['statusColor'] as Color).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    trip['status'],
                    style: TextStyle(
                      color: trip['statusColor'],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: trip['progress'],
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(trip['statusColor']),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestsListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    '${trip['questsDone']}/${trip['totalQuests']} quests',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
                Text(
                  '${(trip['progress'] * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
