import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onRegisterTap; // Added to handle switching to Register screen

  const SignInScreen({super.key, required this.onRegisterTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool signInRequired = false;
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() => signInRequired = false);
        } else if (state is SignInLoading) {
          setState(() => signInRequired = true);
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          // Gradient matching the image
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A148C).withOpacity(0.8),
              const Color(0xFF311B92).withOpacity(0.8),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // Username / Email Field
              _buildInputLabel("Email"),
              _buildTextField(
                controller: emailController,
                hint: "Enter your email",
                validator: (val) {
                  if (val!.isEmpty) return 'Please fill in this field';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildInputLabel("Password"),
              _buildTextField(
                controller: passwordController,
                hint: "Enter your password",
                obscure: obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Please fill in this field';
                  return null;
                },
              ),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.white),
                        child: Checkbox(
                          value: rememberMe,
                          activeColor: Colors.white,
                          checkColor: const Color(0xFF4A148C),
                          onChanged: (val) => setState(() => rememberMe = val!),
                        ),
                      ),
                      const Text("Remember me", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),

              // Continue with Google Button
              _buildPillButton(
                text: "Continue with Google",
                onPressed: () {
                  // Add Google Logic here if needed
                },
              ),
              const SizedBox(height: 15),

              // Main Login Button
              signInRequired
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _buildPillButton(
                      text: "Login",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SignInBloc>().add(
                                SignInRequired(emailController.text, passwordController.text),
                              );
                        }
                      },
                    ),

              const SizedBox(height: 20),

              // Footer: Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
                  GestureDetector(
                    onTap: widget.onRegisterTap,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Color(0xFF8C50C1), // Darker text for "Register" link
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers for cleaner code ---

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        suffixIcon: suffix,
        errorStyle: const TextStyle(color: Colors.orangeAccent),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildPillButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A148C),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}