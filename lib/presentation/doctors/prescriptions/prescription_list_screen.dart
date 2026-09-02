import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() =>
      _PrescriptionListScreenState();
}

class _PrescriptionListScreenState
    extends State<PrescriptionListScreen> {
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    final data = await LocalStorageService.getPrescriptions();

    if (!mounted) {
      return;
    }

    setState(() {
      prescriptions = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Prescriptions'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : prescriptions.isEmpty
              ? const Center(
                  child: Text(
                    'No prescriptions saved yet.',
                    style: TextStyle(fontSize: 17),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrescriptions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = prescriptions[index];

                      return _buildPrescriptionCard(
                        prescription,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildPrescriptionCard(
    Map<String, dynamic> prescription,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.medication),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prescription['patientName'] ?? 'Patient',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _detail(
              'Doctor',
              prescription['doctorName'] ?? 'Doctor',
            ),

            _detail(
              'Diagnosis',
              prescription['diagnosis'] ?? '',
            ),

            _detail(
              'Medicine',
              prescription['medicine'] ?? '',
            ),

            _detail(
              'Dosage',
              prescription['dosage'] ?? '',
            ),

            _detail(
              'Instructions',
              prescription['instructions'] ?? 'None',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}