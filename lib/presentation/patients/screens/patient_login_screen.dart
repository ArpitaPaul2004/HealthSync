import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import '../dashboard/patient_home_screen.dart';
import 'patient_signup_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() =>
      _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoggingIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    final success = await LocalStorageService.loginPatient(
      emailOrPhone: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoggingIn = false;
    });

    if (success) {
      // Go directly to Patient Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const PatientHomeScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid email/mobile number or password.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Forgot password will be connected next.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientSignupScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Patient Login',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              40,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // ICON
                // ==================================================

                Center(
                  child: Container(
                    width: 82,
                    height: 82,

                    decoration: BoxDecoration(
                      color: const Color(0xFF35AFA0),
                      borderRadius:
                          BorderRadius.circular(26),
                    ),

                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // TITLE
                // ==================================================

                const Center(
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Login to access your HealthSync account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // ==================================================
                // EMAIL / MOBILE
                // ==================================================

                const Text(
                  'Email or Mobile Number',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  decoration: InputDecoration(
                    hintText:
                        'Enter email or mobile number',

                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFF35AFA0),
                        width: 1.5,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your email or mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PASSWORD
                // ==================================================

                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      passwordController,

                  obscureText:
                      obscurePassword,

                  decoration: InputDecoration(
                    hintText:
                        'Enter password',

                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(
                        obscurePassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFF35AFA0),
                        width: 1.5,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================

                Align(
                  alignment:
                      Alignment.centerRight,

                  child: TextButton(
                    onPressed:
                        _forgotPassword,

                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color:
                            Color(0xFF168B7D),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed:
                        isLoggingIn
                            ? null
                            : _login,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF35AFA0),

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          const Color(0xFF9DD8D1),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),

                    child: isLoggingIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // OR
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color:
                            Colors.grey.shade300,
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      child: Text(
                        'OR',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        color:
                            Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // GOOGLE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google login will be configured later.',
                          ),
                          behavior:
                              SnackBarBehavior.floating,
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 30,
                    ),

                    label: const Text(
                      'Continue with Google',
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.black87,

                      backgroundColor:
                          Colors.white,

                      side: BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // SIGN UP
                // ==================================================

                Center(
                  child: Wrap(
                    alignment:
                        WrapAlignment.center,

                    crossAxisAlignment:
                        WrapCrossAlignment.center,

                    children: [
                      const Text(
                        "Don't have an account?",
                      ),

                      TextButton(
                        onPressed:
                            _openSignup,

                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color:
                                Color(0xFF168B7D),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // SECURITY
                // ==================================================

                Center(
                  child: Text(
                    'Your health information is private and secure.',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade500,
                    ),
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