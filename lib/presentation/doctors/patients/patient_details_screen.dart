import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, String> patient;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              patient['name'] ?? 'Patient',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            _infoCard(
              icon: Icons.person_outline,
              title: 'Age',
              value: '${patient['age']} years',
            ),

            _infoCard(
              icon: Icons.wc,
              title: 'Gender',
              value: patient['gender'] ?? 'Not available',
            ),

            _infoCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: patient['phone'] ?? 'Not available',
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Medical History',
              child: const Text(
                'No medical history available yet.',
                style: TextStyle(fontSize: 15),
              ),
            ),

            _sectionCard(
              title: 'Current Medications',
              child: const Text(
                'No medications recorded yet.',
                style: TextStyle(fontSize: 15),
              ),
            ),

            _sectionCard(
              title: 'Notes',
              child: const Text(
                'No doctor notes available yet.',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
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
        subtitle: Text(value),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}