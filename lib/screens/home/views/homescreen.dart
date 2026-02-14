import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/map/map.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          TextButton(
            onPressed: () {
              // Dispatch the logout event
              context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: const Map(),
    );
  }
}