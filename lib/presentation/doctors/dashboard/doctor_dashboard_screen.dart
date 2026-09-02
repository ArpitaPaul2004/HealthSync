import 'package:flutter/material.dart';

import '../appointments/doctor_appointments_screen.dart';
import '../patients/patient_list_screen.dart';
import '../prescriptions/write_prescription_screen.dart';
import '../prescriptions/prescription_list_screen.dart';
import '../profile/doctor_profile_screen.dart';
import '../availability/availability_screen.dart';
import '../reports/upload_report_screen.dart';
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        centerTitle: true,
      ),

      body: _currentIndex == 0
          ? _buildDashboard()
          : _currentIndex == 1
              ? _buildPatients()
              : _buildProfile(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Doctor 👨‍⚕️',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Manage your patients and appointments.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.calendar_month,
                  'Appointments',
                  '0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.people,
                  'Patients',
                  '0',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // APPOINTMENTS
          _actionCard(
            Icons.calendar_today,
            'Appointments',
            'View your appointments',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DoctorAppointmentsScreen(),
                ),
              );
            },
          ),

          // PATIENTS
          _actionCard(
            Icons.people,
            'Patients',
            'View your patients',
            () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),

          // PRESCRIPTIONS
          _actionCard(
            Icons.medication,
            'Prescriptions',
            'Write prescriptions',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const WritePrescriptionScreen(),
                ),
              );
            },
          ),

          // SAVED PRESCRIPTIONS
          _actionCard(
            Icons.receipt_long,
            'Saved Prescriptions',
            'View saved prescriptions',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PrescriptionListScreen(),
                ),
              );
            },
          ),

          
          // AVAILABILITY
          _actionCard(
            Icons.access_time,
            'Availability',
            'Manage your availability',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AvailabilityScreen(),
                ),
              );
            },
          ),

          // REPORTS
          _actionCard(
            Icons.upload_file,
            'Reports',
            'Upload patient reports',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const UploadReportScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatients() {
    return const PatientListScreen();
  }

  Widget _buildProfile() {
    return const DoctorProfileScreen();
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}