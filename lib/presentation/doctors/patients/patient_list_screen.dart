import 'package:flutter/material.dart';
import 'patient_details_screen.dart';
class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  final List<Map<String, String>> patients = const [
    {
      'name': 'Sohan Das',
      'age': '32',
      'gender': 'Male',
      'phone': '9876543210',
    },
    {
      'name': 'Arpita Paul',
      'age': '28',
      'gender': 'Female',
      'phone': '9876543211',
    },
    {
      'name': 'Augnik Ganguly',
      'age': '45',
      'gender': 'Male',
      'phone': '9876543212',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person),
              ),
              title: Text(
                patient['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${patient['age']} years • ${patient['gender']}',
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailsScreen(
                      patient: patient,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}