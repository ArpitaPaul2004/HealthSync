import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import 'doctor_details_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() =>
      _DoctorListScreenState();
}

class _DoctorListScreenState
    extends State<DoctorListScreen> {
  List<Map<String, dynamic>> doctors = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final savedDoctors =
        await LocalStorageService.getDoctors();

    if (!mounted) return;

    setState(() {
      doctors = savedDoctors;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        title: const Text(
          'Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : doctors.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(
                        doctors[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildDoctorCard(
    Map<String, dynamic> doctor,
  ) {
    final name =
        doctor['name']?.toString().trim() ?? '';

    final specialization =
        doctor['specialization']?.toString().trim() ?? '';

    final hospital =
        doctor['hospital']?.toString().trim() ?? '';

    final phone =
        doctor['phone']?.toString().trim() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      const Color(0xFFD8F3EF),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 32,
                    color: Color(0xFF167C71),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty
                            ? 'Doctor'
                            : name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        specialization.isEmpty
                            ? 'Specialization not added'
                            : specialization,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF167C71),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (hospital.isNotEmpty)
              _infoRow(
                Icons.local_hospital_outlined,
                hospital,
              ),

            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.phone_outlined,
                phone,
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorDetailsScreen(
                        doctor: doctor,
                      ),
                    ),
                  );

                  _loadDoctors();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Doctor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF167C71),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor:
                  const Color(0xFFD8F3EF),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 42,
                color: Color(0xFF167C71),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Doctors Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Doctors will appear here after '
              'they complete their profiles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}