import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // ------------------------------------------------------------
  // PATIENT ACCOUNT
  // ------------------------------------------------------------

  static const String _nameKey = 'patient_name';
  static const String _emailKey = 'patient_email';
  static const String _phoneKey = 'patient_phone';
  static const String _passwordKey = 'patient_password';
  static const String _loggedInKey = 'patient_logged_in';
  static const String _authTokenKey = 'patient_auth_token';

  // Android physical-device address for the local development backend.
  static const String _apiBaseUrl = 'http://192.168.29.21:4000/api';

  static Future<void> savePatientAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phone);
    // The backend stores a bcrypt hash; do not keep the password in plaintext locally.
    await prefs.remove(_passwordKey);
    await prefs.setBool(_loggedInKey, false);
  }

  static Future<bool> hasPatientAccount() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_emailKey);
  }

  static Future<bool> loginPatient({
    required String emailOrPhone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = emailOrPhone.trim();

    final response = await http
        .post(
          Uri.parse('$_apiBaseUrl/auth/login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': identifier,
            'password': password,
            'role': 'PATIENT',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      if (response.statusCode == 401) return false;
      String message = 'Unable to connect to HealthSync. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final user = Map<String, dynamic>.from(decoded['user'] as Map);
    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw Exception('The server did not return an authentication token.');
    }

    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_nameKey, (user['name'] ?? 'Patient').toString());
    await prefs.setString(_emailKey, (user['email'] ?? '').toString());
    await prefs.setString(_phoneKey, (user['phone'] ?? '').toString());
    await prefs.remove(_passwordKey);
    await prefs.setBool(_loggedInKey, true);
    return true;
  }

  static Future<String?> getPatientAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<bool> isPatientLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String> getPatientName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_nameKey) ?? 'Patient';
  }

  static Future<String> getPatientEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_emailKey) ?? '';
  }

  static Future<String> getPatientPhone() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_phoneKey) ?? '';
  }

  static Future<void> logoutPatient() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_authTokenKey);
  }

  // Calls the authenticated backend first. Local data is cleared only after
  // the server confirms deletion, so a network error cannot look successful.
  static Future<void> deletePatientAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again before deleting your account.');
    }

    final response = await http
        .delete(
          Uri.parse('$_apiBaseUrl/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 204) {
      String message = 'The account could not be deleted from the server.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_loggedInKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_appointmentsKey);
    await prefs.remove(_bedBookingsKey);
  }

  // ------------------------------------------------------------
  // APPOINTMENTS
  // ------------------------------------------------------------

  static const String _appointmentsKey =
      'patient_appointments';

  static Future<void> saveAppointment({
    required String doctorName,
    required String specialization,
    required String hospitalName,
    required String date,
    required String time,
    required String fee,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existingAppointments =
        prefs.getStringList(_appointmentsKey) ?? [];

    final appointment = {
      'id': DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      'doctorName': doctorName,
      'specialization': specialization,
      'hospitalName': hospitalName,
      'date': date,
      'time': time,
      'fee': fee,
      'status': 'Upcoming',
    };

    existingAppointments.add(
      jsonEncode(appointment),
    );

    await prefs.setStringList(
      _appointmentsKey,
      existingAppointments,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getAppointments() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedAppointments =
        prefs.getStringList(_appointmentsKey) ?? [];

    return savedAppointments.map((appointment) {
      final decoded = jsonDecode(appointment);

      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  static Future<List<Map<String, dynamic>>>
      getUpcomingAppointments() async {
    final appointments =
        await getAppointments();

    return appointments.where((appointment) {
      return appointment['status'] == 'Upcoming';
    }).toList();
  }

  static Future<void> cancelAppointment(
    String appointmentId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedAppointments =
        prefs.getStringList(_appointmentsKey) ?? [];

    final updatedAppointments =
        savedAppointments.map((item) {
      final appointment =
          Map<String, dynamic>.from(
        jsonDecode(item),
      );

      if (appointment['id'] == appointmentId) {
        appointment['status'] = 'Cancelled';
      }

      return jsonEncode(appointment);
    }).toList();

    await prefs.setStringList(
      _appointmentsKey,
      updatedAppointments,
    );
  }

  static Future<void> deleteAppointment(
    String appointmentId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedAppointments =
        prefs.getStringList(_appointmentsKey) ?? [];

    final updatedAppointments =
        savedAppointments.where((item) {
      final appointment =
          Map<String, dynamic>.from(
        jsonDecode(item),
      );

      return appointment['id'] != appointmentId;
    }).toList();

    await prefs.setStringList(
      _appointmentsKey,
      updatedAppointments,
    );
  }

  static Future<void> clearAppointments() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_appointmentsKey);
  }

  // ------------------------------------------------------------
  // PROFILE UPDATE
  // ------------------------------------------------------------

  static Future<void> updatePatientProfile({
    required String name,
    required String phone,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _nameKey,
      name,
    );

    await prefs.setString(
      _phoneKey,
      phone,
    );
  }

  static Future<void> updatePatientPassword(
    String password,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _passwordKey,
      password,
    );
  }

  // ------------------------------------------------------------
  // BED BOOKINGS
  // ------------------------------------------------------------

  static const String _bedBookingsKey =
      'patient_bed_bookings';

  static Future<void> saveBedBooking({
    required String bookingId,
    required String patientName,
    required String phone,
    required String age,
    required String gender,
    required String hospitalName,
    required String bedType,
    required int days,
    required String price,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existingBookings =
        prefs.getStringList(_bedBookingsKey) ?? [];

    final booking = {
      'bookingId': bookingId,
      'patientName': patientName,
      'phone': phone,
      'age': age,
      'gender': gender,
      'hospitalName': hospitalName,
      'bedType': bedType,
      'days': days,
      'price': price,
      'status': 'Pending Admission',
      'bookedAt':
          DateTime.now().toIso8601String(),
    };

    existingBookings.add(
      jsonEncode(booking),
    );

    await prefs.setStringList(
      _bedBookingsKey,
      existingBookings,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getBedBookings() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedBookings =
        prefs.getStringList(_bedBookingsKey) ?? [];

    return savedBookings.map((booking) {
      final decoded = jsonDecode(booking);

      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  static Future<void> cancelBedBooking(
    String bookingId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedBookings =
        prefs.getStringList(_bedBookingsKey) ?? [];

    final updatedBookings =
        savedBookings.map((item) {
      final booking =
          Map<String, dynamic>.from(
        jsonDecode(item),
      );

      if (booking['bookingId'] == bookingId) {
        booking['status'] = 'Cancelled';
      }

      return jsonEncode(booking);
    }).toList();

    await prefs.setStringList(
      _bedBookingsKey,
      updatedBookings,
    );
  }

  static Future<void> deleteBedBooking(
    String bookingId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedBookings =
        prefs.getStringList(_bedBookingsKey) ?? [];

    final updatedBookings =
        savedBookings.where((item) {
      final booking =
          Map<String, dynamic>.from(
        jsonDecode(item),
      );

      return booking['bookingId'] != bookingId;
    }).toList();

    await prefs.setStringList(
      _bedBookingsKey,
      updatedBookings,
    );
  }

  static Future<void> clearBedBookings() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_bedBookingsKey);
  }

  // ============================================================
  // DOCTOR ACCOUNT
  // ============================================================

  static const String _doctorNameKey = 'doctor_name';
  static const String _doctorEmailKey = 'doctor_email';
  static const String _doctorPhoneKey = 'doctor_phone';
  static const String _doctorPasswordKey = 'doctor_password';
  static const String _doctorSpecializationKey =
      'doctor_specialization';
  static const String _doctorHospitalKey = 'doctor_hospital';
  static const String _doctorLoggedInKey = 'doctor_logged_in';
  static const String _doctorAuthTokenKey = 'doctor_auth_token';

  // ============================================================
  // HOSPITAL ADMIN ACCOUNT
  // ============================================================

  static const String _hospitalAdminNameKey = 'hospital_admin_name';
  static const String _hospitalAdminEmailKey = 'hospital_admin_email';
  static const String _hospitalAdminLoggedInKey =
      'hospital_admin_logged_in';
  static const String _hospitalAdminAuthTokenKey =
      'hospital_admin_auth_token';

  static Future<void> saveDoctorAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
    String specialization = 'General Physician',
    String hospital = 'HealthSync Hospital',
  }) async {
    // Never store a plaintext password locally.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doctorNameKey, name);
    await prefs.setString(_doctorEmailKey, email);
    await prefs.setString(_doctorPhoneKey, phone);
    await prefs.remove(_doctorPasswordKey);
    await prefs.setString(
      _doctorSpecializationKey,
      specialization,
    );
    await prefs.setString(_doctorHospitalKey, hospital);
    await prefs.setBool(_doctorLoggedInKey, false);
  }

  static Future<bool> hasDoctorAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_doctorEmailKey);
  }

  static Future<bool> loginDoctor({
    required String emailOrPhone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http
        .post(
          Uri.parse('$_apiBaseUrl/auth/login'),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': emailOrPhone.trim(),
            'password': password,
            'role': 'DOCTOR',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401 || response.statusCode == 403) {
      return false;
    }

    if (response.statusCode != 200) {
      String message = 'Unable to connect to HealthSync.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    final decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final user =
        Map<String, dynamic>.from(decoded['user'] as Map);
    final token = decoded['token'];

    if (token is! String || token.isEmpty) {
      throw Exception(
        'The server did not return an authentication token.',
      );
    }

    await prefs.setString(_doctorAuthTokenKey, token);
    await prefs.setString(
      _doctorNameKey,
      (user['name'] ?? 'Doctor').toString(),
    );
    await prefs.setString(
      _doctorEmailKey,
      (user['email'] ?? '').toString(),
    );
    await prefs.setString(
      _doctorPhoneKey,
      (user['phone'] ?? '').toString(),
    );
    await prefs.setString(
      _doctorSpecializationKey,
      (user['specialization'] ?? 'General Physician').toString(),
    );
    await prefs.setBool(_doctorLoggedInKey, true);

    return true;
  }

  static Future<String?> getDoctorAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorAuthTokenKey);
  }

  static Future<bool> isDoctorLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doctorLoggedInKey) ?? false;
  }

  static Future<void> logoutDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doctorLoggedInKey, false);
    await prefs.remove(_doctorAuthTokenKey);
  }

  static Future<String> getDoctorName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorNameKey) ?? 'Doctor';
  }

  static Future<String> getDoctorEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorEmailKey) ?? '';
  }

  static Future<String> getDoctorPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorPhoneKey) ?? '';
  }

  static Future<String> getDoctorSpecialization() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorSpecializationKey) ??
        'General Physician';
  }

  static Future<String> getDoctorHospital() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorHospitalKey) ??
        'HealthSync Hospital';
  }

  static Future<void> updateDoctorProfile({
    required String name,
    required String phone,
    required String specialization,
    required String hospital,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_doctorAuthTokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    final response = await http
        .patch(
          Uri.parse('$_apiBaseUrl/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name.trim(),
            'phone': phone.trim(),
            'specialization': specialization.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      String message = 'Could not update doctor profile.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    await prefs.setString(_doctorNameKey, name.trim());
    await prefs.setString(_doctorPhoneKey, phone.trim());
    await prefs.setString(
      _doctorSpecializationKey,
      specialization.trim(),
    );

    // Hospital remains local until we connect it to a real hospital ID.
    await prefs.setString(_doctorHospitalKey, hospital.trim());
  }

  static Future<void> deleteDoctorAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_doctorAuthTokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again before deleting your account.');
    }

    final response = await http
        .delete(
          Uri.parse('$_apiBaseUrl/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      String message = 'Could not delete doctor account.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    for (final key in [
      _doctorNameKey,
      _doctorEmailKey,
      _doctorPhoneKey,
      _doctorPasswordKey,
      _doctorSpecializationKey,
      _doctorHospitalKey,
      _doctorLoggedInKey,
      _doctorAuthTokenKey,
      _prescriptionsKey,
      _doctorDirectoryKey,
    ]) {
      await prefs.remove(key);
    }
  }

  static Future<void> updateDoctorPassword(
    String currentPassword,
    String newPassword,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_doctorAuthTokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    final response = await http
        .patch(
          Uri.parse('$_apiBaseUrl/auth/password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      String message = 'Could not update password.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }

    await prefs.remove(_doctorPasswordKey);
  }

    // ============================================================
  // PRESCRIPTIONS
  // ============================================================

  static const String _prescriptionsKey = 'doctor_prescriptions';

  static Future<void> savePrescription({
    required String patientName,
    required String diagnosis,
    required String medicine,
    required String dosage,
    required String instructions,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existingPrescriptions =
        prefs.getStringList(_prescriptionsKey) ?? [];

    final prescription = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'patientName': patientName,
      'diagnosis': diagnosis,
      'medicine': medicine,
      'dosage': dosage,
      'instructions': instructions,
      'doctorName':
          prefs.getString(_doctorNameKey) ?? 'Doctor',
      'createdAt': DateTime.now().toIso8601String(),
    };

    existingPrescriptions.add(
      jsonEncode(prescription),
    );

    await prefs.setStringList(
      _prescriptionsKey,
      existingPrescriptions,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPrescriptions =
        prefs.getStringList(_prescriptionsKey) ?? [];

    return savedPrescriptions.map((prescription) {
      final decoded = jsonDecode(prescription);

      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  static Future<void> deletePrescription(
    String prescriptionId,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final savedPrescriptions =
        prefs.getStringList(_prescriptionsKey) ?? [];

    final updatedPrescriptions =
        savedPrescriptions.where((item) {
      final prescription =
          Map<String, dynamic>.from(
        jsonDecode(item),
      );

      return prescription['id'] != prescriptionId;
    }).toList();

    await prefs.setStringList(
      _prescriptionsKey,
      updatedPrescriptions,
    );
  }

  static Future<void> clearPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_prescriptionsKey);
  }
  // =====================================================
// DOCTOR DIRECTORY (Visible to Patients)
// =====================================================

static const String _doctorDirectoryKey = 'doctor_directory';

static Future<void> saveDoctorToDirectory() async {
  final prefs = await SharedPreferences.getInstance();

  final doctors = prefs.getStringList(_doctorDirectoryKey) ?? [];

  final doctor = {
    'name': prefs.getString(_doctorNameKey) ?? '',
    'phone': prefs.getString(_doctorPhoneKey) ?? '',
    'email': prefs.getString(_doctorEmailKey) ?? '',
    'specialization':
        prefs.getString(_doctorSpecializationKey) ?? '',
    'hospital':
        prefs.getString(_doctorHospitalKey) ?? '',
  };

  doctors.removeWhere((item) {
    final d = jsonDecode(item);
    return d['email'] == doctor['email'];
  });

  doctors.add(jsonEncode(doctor));

  await prefs.setStringList(_doctorDirectoryKey, doctors);
}

static Future<List<Map<String, dynamic>>> getDoctors() async {
  final prefs = await SharedPreferences.getInstance();

  final doctors = prefs.getStringList(_doctorDirectoryKey) ?? [];

  return doctors
      .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
      .toList();
}


  // ============================================================
  // HOSPITAL ADMIN AUTHENTICATION
  // ============================================================

  static Future<bool> loginHospitalAdmin({
    required String emailOrPhone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http
        .post(
          Uri.parse('$_apiBaseUrl/auth/login'),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': emailOrPhone.trim(),
            'password': password,
            'role': 'HOSPITAL_ADMIN',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      return false;
    }

    if (response.statusCode != 200) {
      String message = 'Unable to connect to HealthSync.';

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}

      throw Exception(message);
    }

    final decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    final user =
        Map<String, dynamic>.from(decoded['user'] as Map);

    final token = decoded['token'];

    if (user['role'] != 'HOSPITAL_ADMIN') {
      throw Exception('This account is not a Hospital Admin.');
    }

    if (token is! String || token.isEmpty) {
      throw Exception(
        'The server did not return an authentication token.',
      );
    }

    await prefs.setString(_hospitalAdminAuthTokenKey, token);
    await prefs.setString(
      _hospitalAdminNameKey,
      (user['name'] ?? 'Hospital Admin').toString(),
    );
    await prefs.setString(
      _hospitalAdminEmailKey,
      (user['email'] ?? '').toString(),
    );
    await prefs.setBool(_hospitalAdminLoggedInKey, true);

    return true;
  }

  static Future<String?> getHospitalAdminAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hospitalAdminAuthTokenKey);
  }

  static Future<String> getHospitalAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hospitalAdminNameKey) ?? 'Hospital Admin';
  }

  static Future<String> getHospitalAdminEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hospitalAdminEmailKey) ?? '';
  }

  static Future<bool> isHospitalAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hospitalAdminLoggedInKey) ?? false;
  }

  static Future<void> logoutHospitalAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hospitalAdminLoggedInKey, false);
    await prefs.remove(_hospitalAdminAuthTokenKey);
  }

}
