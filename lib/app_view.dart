import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/auth/views/welcomescreen.dart';
import 'screens/home/views/root_screen.dart';

class MyAppView extends StatelessWidget {

  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voyant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: const Color.fromARGB(255, 176, 32, 221),
          primary: const Color.fromARGB(255, 85, 17, 97),
          onPrimary: Colors.white,
        ),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: ((context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return const RootScreen();
          } else {
            return WelcomeScreen();
          }
        }),
      ),
    );
  }
}
