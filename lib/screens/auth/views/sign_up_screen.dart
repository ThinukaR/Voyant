import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onLoginTap; // Callback to switch back to Sign In

  const SignUpScreen({super.key, required this.onLoginTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool signUpRequired = false;

  // Password Requirement States
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() => signUpRequired = false);
        } else if (state is SignUpLoading) {
          setState(() => signUpRequired = true);
        } else if (state is SignUpFailure) {
          setState(() => signUpRequired = false);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
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
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              _buildInputLabel("Full Name"),
              _buildTextField(
                controller: nameController,
                hint: "Enter your name",
                validator: (val) => val!.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 15),

              // Email Field
              _buildInputLabel("Email"),
              _buildTextField(
                controller: emailController,
                hint: "Enter your email",
                validator: (val) {
                  if (val!.isEmpty) return 'Field required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Field
              _buildInputLabel("Password"),
              _buildTextField(
                controller: passwordController,
                hint: "Create a password",
                obscure: obscurePassword,
                onChanged: (val) => _validatePassword(val),
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Field required';
                  if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$').hasMatch(val)) {
                    return 'Password too weak';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Password Requirements UI
              _buildRequirementGrid(),

              const SizedBox(height: 25),

              // Sign Up Button
              signUpRequired
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _buildPillButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final myUser = MyUser(
                            userId: '',
                            email: emailController.text,
                            username: nameController.text,
                          );  
                          context.read<SignUpBloc>().add(SignUpRequired(myUser, passwordController.text));
                        }
                      },
                    ),

              const SizedBox(height: 15),

              // Footer: Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
                  GestureDetector(
                    onTap: widget.onLoginTap,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF1B0330), 
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

  // Logic for real-time password validation UI
  void _validatePassword(String val) {
    setState(() {
      containsUpperCase = val.contains(RegExp(r'[A-Z]'));
      containsLowerCase = val.contains(RegExp(r'[a-z]'));
      containsNumber = val.contains(RegExp(r'[0-9]'));
      containsSpecialChar = val.contains(RegExp(r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'));
      contains8Length = val.length >= 8;
    });
  }

  // --- UI Helpers ---

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        suffixIcon: suffix,
        errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildRequirementGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 5,
      children: [
        _reqItem("Upper", containsUpperCase),
        _reqItem("Lower", containsLowerCase),
        _reqItem("Number", containsNumber),
        _reqItem("Special", containsSpecialChar),
        _reqItem("8+ Char", contains8Length),
      ],
    );
  }

  Widget _reqItem(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? Colors.greenAccent : Colors.white38,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: isMet ? Colors.white : Colors.white38, fontSize: 10)),
      ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}