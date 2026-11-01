
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import '../dashboard/hospital_admin_dashboard_screen.dart';

class HospitalAdminLoginScreen extends StatefulWidget {
  const HospitalAdminLoginScreen({super.key});

  @override
  State<HospitalAdminLoginScreen> createState() =>
      _HospitalAdminLoginScreenState();
}

class _HospitalAdminLoginScreenState
    extends State<HospitalAdminLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginHospitalAdmin() async {
    final identifier = emailController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty) {
      _showMessage('Please enter your email or phone number.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await LocalStorageService.loginHospitalAdmin(
        emailOrPhone: identifier,
        password: password,
      );

      if (!mounted) return;

      if (!success) {
        setState(() => isLoading = false);
        _showMessage(
          'Invalid Hospital Admin email/phone or password, '
          'or this account is not authorized.',
          isError: true,
        );
        return;
      }

      final token =
          await LocalStorageService.getHospitalAdminAuthToken();
      final adminName =
          await LocalStorageService.getHospitalAdminName();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        await LocalStorageService.logoutHospitalAdmin();

        if (!mounted) return;

        setState(() => isLoading = false);
        _showMessage(
          'Could not retrieve your login session. Please try again.',
          isError: true,
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HospitalAdminDashboardScreen(
            token: token,
            adminName: adminName,
            onLogout: _logout,
          ),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoading = false);

      final message = error.toString().replaceFirst('Exception: ', '');
      _showMessage(message, isError: true);
    }
  }

  // Only clear the saved session here.
  // Navigation back to role selection is handled by the dashboard.
  Future<void> _logout() async {
    await LocalStorageService.logoutHospitalAdmin();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      appBar: AppBar(
        title: const Text('Hospital Admin Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFC66A35),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome, Hospital Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your hospital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email or Phone',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!isLoading) loginHospitalAdmin();
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginHospitalAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC66A35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Hospital Admin accounts are created by the Super Admin. '
                'Contact your platform administrator if you need access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
