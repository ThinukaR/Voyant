import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/map/map.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Map(),
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