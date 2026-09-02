import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';

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
      backgroundColor:
          const Color(0xFFF5F9F9),

      appBar: AppBar(
        title: const Text('Doctors'),
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
                      final doctor = doctors[index];

                      return _buildDoctorCard(
                        doctor,
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
        doctor['name']?.toString().trim().isNotEmpty ==
                true
            ? doctor['name'].toString()
            : 'Doctor';

    final specialization =
        doctor['specialization']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true
        ? doctor['specialization'].toString()
        : 'Specialization not added';

    final hospital =
        doctor['hospital']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true
        ? doctor['hospital'].toString()
        : 'Hospital not added';

    final phone =
        doctor['phone']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
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
                  radius: 30,
                  backgroundColor:
                      const Color(0xFFD8F3EF),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Color(0xFF167C71),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        specialization,
                        style: const TextStyle(
                          fontSize: 13,
                          color:
                              Color(0xFF167C71),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                onPressed: () {
                  _showDoctorDetails(
                    doctor,
                  );
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: const Text(
                  'View Doctor',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
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

  void _showDoctorDetails(
    Map<String, dynamic> doctor,
  ) {
    final name =
        doctor['name']?.toString() ??
            'Doctor';

    final specialization =
        doctor['specialization']
                ?.toString() ??
            '';

    final hospital =
        doctor['hospital']?.toString() ??
            '';

    final phone =
        doctor['phone']?.toString() ??
            '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            15,
            20,
            30,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 25),

              CircleAvatar(
                radius: 42,
                backgroundColor:
                    const Color(0xFFD8F3EF),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF167C71),
                  size: 42,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                specialization.isEmpty
                    ? 'Specialization not added'
                    : specialization,
                style: const TextStyle(
                  color: Color(0xFF167C71),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 22),

              _detailRow(
                Icons.local_hospital_outlined,
                'Hospital',
                hospital.isEmpty
                    ? 'Not added'
                    : hospital,
              ),

              if (phone.isNotEmpty)
                _detailRow(
                  Icons.phone_outlined,
                  'Phone',
                  phone,
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Appointment booking will be connected next.',
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF35AFA0),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF167C71),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
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