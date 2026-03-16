import 'package:flutter/material.dart';
import 'package:voyant/screens/map/map.dart';
import 'package:voyant/screens/home/views/home_tab.dart';
import 'package:voyant/screens/trips/views/trips_list_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(onTripsTap: () => setState(() => _currentIndex = 1)),
      const TripsTab(),
      const Map(),
      const Center(
        child: Text("Inventory", style: TextStyle(color: Colors.white)),
      ),
      const Center(
        child: Text("Avatar", style: TextStyle(color: Colors.white)),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF12121A),
        selectedItemColor: const Color(0xFFB020DD),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Trips",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: "Inventory",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Avatar"),
        ],
      ),
    );
  }
}
