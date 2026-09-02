import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        doctor['name']?.toString().trim() ?? '';

    final specialization =
        doctor['specialization']?.toString().trim() ?? '';

    final hospital =
        doctor['hospital']?.toString().trim() ?? '';

    final phone =
        doctor['phone']?.toString().trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Doctor Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor:
                  const Color(0xFFD8F3EF),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 50,
                color: Color(0xFF167C71),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              name.isEmpty ? 'Doctor' : name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              specialization.isEmpty
                  ? 'Specialization not added'
                  : specialization,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF167C71),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            _infoCard(
              icon: Icons.local_hospital_outlined,
              title: 'Hospital',
              value: hospital.isEmpty
                  ? 'Not added'
                  : hospital,
            ),

            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: phone.isEmpty
                  ? 'Not added'
                  : phone,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Appointment booking will be connected next.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                const Color(0xFFD8F3EF),
            child: Icon(
              icon,
              color: const Color(0xFF167C71),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}