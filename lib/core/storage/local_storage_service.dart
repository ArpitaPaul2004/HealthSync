import 'dart:convert';

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
    await prefs.setString(_passwordKey, password);
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

    final savedEmail = prefs.getString(_emailKey);
    final savedPhone = prefs.getString(_phoneKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedPassword != password) {
      return false;
    }

    final input = emailOrPhone.trim();

    final matchesEmail =
        savedEmail?.toLowerCase() == input.toLowerCase();

    final matchesPhone = savedPhone == input;

    if (!matchesEmail && !matchesPhone) {
      return false;
    }

    await prefs.setBool(_loggedInKey, true);

    return true;
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
  }

  static Future<void> deletePatientAccount() async {
    final prefs = await SharedPreferences.getInstance();

    // Delete account information.
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_loggedInKey);

    // Delete appointments.
    await prefs.remove(_appointmentsKey);

    // Delete bed bookings.
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
}