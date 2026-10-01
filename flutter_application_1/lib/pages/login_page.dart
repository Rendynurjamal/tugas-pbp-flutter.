import 'package:flutter/material.dart';

import 'home_page.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username == 'admin' && password == '12345') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    String label,
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.gold),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceAlt, AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    size: 46,
                    color: AppColors.gold,
                  ),
                ),

                const SizedBox(height: 20),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bengkel',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Ku',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Solusi servis kendaraan Anda',
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _fieldDecoration(
                    'Username',
                    'Masukkan username',
                    Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _fieldDecoration(
                    'Password',
                    'Masukkan password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Username: admin | Password: 12345',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
