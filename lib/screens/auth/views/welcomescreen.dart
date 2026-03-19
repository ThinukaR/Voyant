import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:voyant/screens/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Logic to toggle between the two screens
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0330), // Matches image background
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Static Header
                    const Text(
                      "Ready to venture?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    
                    // Animated Switcher for smooth transition between screens
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showSignIn 
                        ? BlocProvider<SignInBloc>(
                            key: const ValueKey('SignIn'),
                            create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
                            child: SignInScreen(onRegisterTap: toggleView), // Pass the toggle function
                          )
                        : BlocProvider<SignUpBloc>(
                            key: const ValueKey('SignUp'),
                            create: (context) => SignUpBloc(context.read<AuthenticationBloc>().userRepository),
                            child: SignUpScreen(onLoginTap: toggleView), // Pass the toggle function
                          ),
                    ),

                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF512DA8),
              child: const Icon(Icons.map_outlined, color: Colors.white, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}