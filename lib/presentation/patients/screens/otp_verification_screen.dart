import 'package:flutter/material.dart';

import '../dashboard/patient_home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
      List.generate(
    6,
    (_) => FocusNode(),
  );

  bool isVerifying = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  // Get complete OTP
  String get otp {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  // Move between OTP boxes
  void _onOtpChanged(
    String value,
    int index,
  ) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    // Check OTP length first
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the complete 6-digit OTP.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      isVerifying = true;
    });

    // Temporary frontend verification.
    // Real OTP verification will be connected
    // to Node.js backend later.

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      isVerifying = false;
    });

    // Navigate to Patient Home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientHomeScreen(),
      ),
      (route) => false,
    );
  }

  // Resend OTP
  void _resendOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A new OTP has been sent.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      // =====================================================
      // APP BAR
      // =====================================================

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
          'OTP Verification',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            30,
            24,
            40,
          ),
          child: Column(
            children: [
              // =================================================
              // ICON
              // =================================================

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3EF),
                  borderRadius:
                      BorderRadius.circular(45),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: Color(0xFF167C71),
                  size: 45,
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // TITLE
              // =================================================

              const Text(
                'Verify Your Number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'We have sent a 6-digit verification code to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 7),

              // Phone number
              Text(
                _maskedPhoneNumber(
                  widget.phoneNumber,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF167C71),
                ),
              ),

              const SizedBox(height: 38),

              // =================================================
              // ENTER OTP
              // =================================================

              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // OTP BOXES
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller:
                            _controllers[index],
                        focusNode:
                            _focusNodes[index],

                        keyboardType:
                            TextInputType.number,

                        textAlign: TextAlign.center,

                        maxLength: 1,

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),

                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            borderSide:
                                BorderSide.none,
                          ),

                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            borderSide: BorderSide(
                              color:
                                  Colors.grey.shade200,
                            ),
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(0xFF35AFA0),
                              width: 1.5,
                            ),
                          ),
                        ),

                        onChanged: (value) {
                          _onOtpChanged(
                            value,
                            index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // =================================================
              // VERIFY BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      isVerifying
                          ? null
                          : _verifyOtp,

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

                  child: isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // RESEND OTP
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Resend OTP',
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

              const SizedBox(height: 25),

              // =================================================
              // SECURITY INFORMATION
              // =================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF8F5),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color:
                          Color(0xFF167C71),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'OTP verification helps keep '
                        'your HealthSync account secure.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Development note
              Text(
                'Development mode: OTP is simulated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MASK PHONE NUMBER
  // ============================================================

  String _maskedPhoneNumber(
    String phone,
  ) {
    if (phone.length < 4) {
      return phone;
    }

    final lastFour =
        phone.substring(phone.length - 4);

    return '******$lastFour';
  }
}