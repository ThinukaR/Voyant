import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/map/map.dart';
import 'package:voyant/screens/avatar/views/avatar_screen.dart';


class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AvatarScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Map(),
      // Add a button to go to class selection screen
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Dispatch the logout event
          context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
        },
        label: const Text('Sign Out'),
        icon: const Icon(Icons.logout),
      ),
    );
  }
}