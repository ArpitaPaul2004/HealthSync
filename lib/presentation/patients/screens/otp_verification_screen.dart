
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/patient_home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  String? _verificationId;
  ConfirmationResult? _webConfirmationResult;
  int? _forceResendingToken;

  bool isVerifying = false;
  bool isSending = true;
  bool _isCompleting = false;
  bool _completed = false;

  String _statusMessage = 'Sending verification code...';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
  }

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

  String get otp =>
      _controllers.map((controller) => controller.text).join();

  // Accept an international number, or a 10-digit Indian number.
  String _normalizedPhoneNumber() {
    final phone = widget.phoneNumber
        .trim()
        .replaceAll(RegExp(r'[\s()-]'), '');

    if (phone.startsWith('+')) {
      return phone;
    }

    if (RegExp(r'^\d{10}$').hasMatch(phone)) {
      return '+91$phone';
    }

    if (RegExp(r'^91\d{10}$').hasMatch(phone)) {
      return '+$phone';
    }

    throw const FormatException(
      'Enter a valid phone number with its country code.',
    );
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (_completed) return;

    if (mounted) {
      setState(() {
        isSending = true;
        _statusMessage = 'Sending verification code...';
      });
    }

    try {
      final phone = _normalizedPhoneNumber();

      if (kIsWeb) {
        // Firebase Web SDK handles reCAPTCHA.
        final result = await _auth.signInWithPhoneNumber(phone);

        if (!mounted || _completed) return;

        _webConfirmationResult = result;

        setState(() {
          isSending = false;
          _statusMessage = 'Code sent. Check your SMS messages.';
        });
      } else {
        // Native Android phone verification.
        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          forceResendingToken:
              isResend ? _forceResendingToken : null,
          verificationCompleted: (PhoneAuthCredential credential) {
            _completeSignIn(credential);
          },
          verificationFailed: (FirebaseAuthException error) {
            if (!mounted) return;

            setState(() {
              isSending = false;
              _statusMessage = 'Unable to send the verification code.';
            });

            _showError(_friendlyError(error));
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted || _completed) return;

            _verificationId = verificationId;
            _forceResendingToken = resendToken;

            setState(() {
              isSending = false;
              _statusMessage = 'Code sent. Check your SMS messages.';
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        isSending = false;
        _statusMessage = 'Could not send the verification code.';
      });

      _showError(_friendlyError(error));
    } on FormatException catch (error) {
      if (!mounted) return;

      setState(() {
        isSending = false;
        _statusMessage = 'Check the phone number and try again.';
      });

      _showError(error.message);
    } catch (error) {
        debugPrint('Firebase OTP send error: $error');

        if (!mounted) return;

        setState(() {
          isSending = false;
          _statusMessage = 'OTP error: $error';
        });

      _showError('OTP error: $error');
    }
  }

  Future<void> _verifyOtp() async {
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showError('Please enter the complete 6-digit OTP.');
      return;
    }

    if (isSending || _isCompleting || _completed) return;

    setState(() {
      isVerifying = true;
    });

    try {
      if (kIsWeb) {
        final confirmation = _webConfirmationResult;

        if (confirmation == null) {
          throw FirebaseAuthException(
            code: 'missing-confirmation',
            message: 'Please request a verification code first.',
          );
        }

        // Firebase verifies the web OTP.
        final result = await confirmation.confirm(otp);
        if (result.user == null) {
          throw FirebaseAuthException(
            code: 'verification-failed',
            message: 'The verification could not be completed.',
          );
        }

        await _registerPatientInBackend();
        if (mounted && !_completed) {
          _navigateToHome();
        }
      } else {
        final verificationId = _verificationId;

        if (verificationId == null) {
          throw FirebaseAuthException(
            code: 'missing-verification-id',
            message: 'Please request a new verification code.',
          );
        }

        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );

        await _completeSignIn(credential);
      }
    } on FirebaseAuthException catch (error) {
      if (mounted && !_completed) {
        _showError(_friendlyError(error));
      }
    } catch (error) {
      if (mounted && !_completed) {
        _showError('Verification failed. Please try again.');
      }
      debugPrint('OTP verification error: $error');
    } finally {
      if (mounted && !_completed) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  Future<void> _completeSignIn(
    PhoneAuthCredential credential,
  ) async {
    if (_isCompleting || _completed) return;

    _isCompleting = true;

    if (mounted) {
      setState(() {
        isVerifying = true;
      });
    }

    try {
      // Firebase validates the phone credential and signs in the user.
      await _auth.signInWithCredential(credential);

      if (mounted && !_completed) {
        await _registerPatientInBackend();
        if (mounted && !_completed) {
          _navigateToHome();
        }
      }
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase sign-in error: ${error.code} - ${error.message}');

      if (mounted && !_completed) {
        _showError(_friendlyError(error));
      }
    } catch (error, stackTrace) {
      debugPrint('Backend registration error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted && !_completed) {
        _showError(
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      _isCompleting = false;

      if (mounted && !_completed) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  // Saves the verified patient's registration details in the existing backend.
  // The backend URL below is the Mac's LAN address used for local phone testing.
  Future<void> _registerPatientInBackend() async {
    final response = await http
        .post(
          Uri.parse('http://192.168.29.21:4000/api/auth/register'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': widget.name,
            'email': widget.email,
            'phone': widget.phoneNumber,
            'password': widget.password,
            'role': 'PATIENT',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      var message = 'Could not save your account to the database.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] is String) {
          message = body['error'] as String;
        }
      } catch (_) {
        // Keep the fallback message if the response isn't JSON.
      }
      throw Exception(message);
    }
  }

  void _navigateToHome() {
    if (!mounted || _completed) return;

    _completed = true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientHomeScreen(),
      ),
      (route) => false,
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (isSending || isVerifying || _completed) return;

    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes[0].requestFocus();

    await _sendOtp(isResend: true);
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid. Check the country code.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check the code and try again.';
      case 'session-expired':
        return 'This OTP has expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'The SMS quota has been reached. Try again later.';
      case 'captcha-check-failed':
        return 'Web verification failed. Please try again.';
      case 'missing-verification-id':
        return 'Verification expired. Please request a new OTP.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled in Firebase.';
      default:
        return error.message ??
            'Authentication failed. Please try again.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _maskedPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 4) return phone;

    return '******${digits.substring(digits.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'OTP Verification',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3EF),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: Color(0xFF167C71),
                  size: 45,
                ),
              ),
              const SizedBox(height: 28),
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
                isSending
                    ? 'Sending a verification code to'
                    : 'We sent a verification code to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _maskedPhoneNumber(widget.phoneNumber),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF167C71),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      enabled: !isSending && !isVerifying,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF35AFA0),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _onOtpChanged(value, index);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSending || isVerifying
                      ? null
                      : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35AFA0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF9DD8D1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSending || isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: isSending || isVerifying
                        ? null
                        : _resendOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Color(0xFF168B7D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF167C71),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'OTP verification helps keep your '
                        'HealthSync account secure.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                kIsWeb
                    ? 'Secure verification powered by Firebase.'
                    : 'Secure SMS verification powered by Firebase.',
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
}
