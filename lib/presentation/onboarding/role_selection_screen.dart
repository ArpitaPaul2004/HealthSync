import 'package:flutter/material.dart';

import '../patients/screens/patient_login_screen.dart';

import '../doctors/screens/doctor_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HealthSync',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'How will you use\nHealthSync?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Select a role to continue.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              // PATIENT
              _RoleCard(
                icon: Icons.person_outline_rounded,
                title: 'Patient',
                description:
                    'Appointments, medical records and emergency care',
                iconBackground: const Color(0xFFD8F3EF),
                iconColor: const Color(0xFF167C71),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PatientLoginScreen(),
                    ),
                  );
                },
              ),

              // DOCTOR
              _RoleCard(
                icon: Icons.medical_services_outlined,
                title: 'Doctor',
                description:
                    'Patients, prescriptions and availability',
                iconBackground: const Color(0xFFE5EEFF),
                iconColor: const Color(0xFF3567B8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorLoginScreen(),
                    ),
                  );
                },
              ),

              // HOSPITAL ADMIN
              _RoleCard(
                icon: Icons.local_hospital_outlined,
                title: 'Hospital Admin',
                description:
                    'Hospital, doctors, beds and admissions',
                iconBackground: const Color(0xFFFFEEE4),
                iconColor: const Color(0xFFC66A35),
                onTap: () {
                  _showComingSoon(context, 'Hospital Admin');
                },
              ),

              // SUPER ADMIN
              _RoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Super Admin',
                description:
                    'Platform management and approvals',
                iconBackground: const Color(0xFFEDE7F8),
                iconColor: const Color(0xFF7356A8),
                onTap: () {
                  _showComingSoon(context, 'Super Admin');
                },
              ),

              const SizedBox(height: 15),

              // Security message
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secure healthcare platform',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showComingSoon(
    BuildContext context,
    String role,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$role section will be available soon.',
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,

                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}