import 'package:bean_byte/auth/auth_services.dart';
import 'package:bean_byte/components/alert_comp.dart';
import 'package:bean_byte/components/button_comp.dart';
import 'package:bean_byte/components/text_field_comp.dart';
import 'package:bean_byte/database/supabase_db.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggle;
  const RegisterScreen({super.key, required this.onToggle});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertComp(title: "Bean & Byte", message: message),
    );
  }

  void register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      showAlert("Please fill all the fields");
      return;
    }
    if (passwordController.text != confirmController.text) {
      showAlert("Passwords do not match");
      return;
    }
    if (passwordController.text.length < 6) {
      showAlert("Password must be at least 6 characters long");
      return;
    }
    Map<String, dynamic> data = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };
    try {
      await AuthServices().register(
        data["name"],
        data["email"],
        data["password"],
      );
    } on Exception catch (e) {
      showAlert(
        Exception(e).toString().split(':').last.trim().split('-').join(' '),
      );
      return;
    }
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bean & Byte",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontFamily: GoogleFonts.orbitron().fontFamily,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Part
              Lottie.asset(
                'lotties/login_leady.json',
                repeat: true,
                animate: true,
                fit: BoxFit.cover,
                height: 160,
                width: 160,
              ),
              const SizedBox(height: 24),
              // Welcome Text
              Text(
                'Welcome to Bean & Byte!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account and get your fresh brew.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
              ),
              const SizedBox(height: 32),

              // Registration Form
              TextFieldComp(
                prefixIcon: Icons.person,
                labelText: 'Name',
                hintText: 'Enter your name',
                controller: nameController,
                isPassword: false,
              ),

              const SizedBox(height: 24),

              TextFieldComp(
                prefixIcon: Icons.email,
                labelText: 'Email',
                hintText: 'Enter your email',
                controller: emailController,
                isPassword: false,
              ),

              const SizedBox(height: 24),

              TextFieldComp(
                controller: passwordController,
                prefixIcon: Icons.password,
                labelText: "Password",
                hintText: "Enter Your Password",
                isPassword: true,
              ),

              const SizedBox(height: 24),

              TextFieldComp(
                controller: confirmController,
                prefixIcon: Icons.password,
                labelText: "Confirm Password",
                hintText: "Confirm Your Password",
                isPassword: true,
              ),

              const SizedBox(height: 16),

              ButtonComp(label: "Register", onTap: register),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Text(
                      " Login now.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).colorScheme.primary,
                        decorationThickness: 2,
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
}
