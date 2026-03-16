import 'package:bean_byte/auth/auth_services.dart';
import 'package:bean_byte/components/alert_comp.dart';
import 'package:bean_byte/components/button_comp.dart';
import 'package:bean_byte/components/text_field_comp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginScreen({super.key, required this.onToggle});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertComp(title: "Bean & Byte", message: message),
    );
  }

  void onLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showAlert("Please fill all the fields");
      return;
    }

    Map<String, dynamic> data = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      await AuthServices().login(data["email"], data["password"]);
    } on Exception catch (e) {
      showAlert(
        Exception(e).toString().split(':').last.trim().split('-').join(' '),
      );
      return;
    }

    emailController.clear();
    passwordController.clear();
  }

  void onForgotPassword() async {
    try {
      await AuthServices().resetPassword(emailController.text.trim());
      showAlert(
        "Password reset email sent to ${emailController.text.trim()}, \nif not found in inbox check spam folder.",
      );
    } catch (e) {
      showAlert(e.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your fresh brew is just a tap away.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
              ),
              const SizedBox(height: 32),

              // Login Form
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

              const SizedBox(height: 8),

              Container(
                width: double.maxFinite,
                child: GestureDetector(
                  onTap: onForgotPassword,
                  child: Text(
                    "forgot password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ButtonComp(
                label: "Login",
                onTap: () {
                  onLogin();
                },
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: AuthServices().google_SignIn,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(60),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Image.asset('images/google_icon.png'),
                ),
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Text(
                      " Register now.",
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
