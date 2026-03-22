import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/map/map.dart';
import 'package:voyant/screens/inventory/inventory_screen.dart';
import 'package:voyant/screens/classes/views/classScreen.dart';
import 'package:voyant/screens/leaderboard/leaderboard_screen.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Map(),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'leaderboard_btn',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.leaderboard, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      // Add a button to go to class selection screen

    );
  }
}