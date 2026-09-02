import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';

class WritePrescriptionScreen extends StatefulWidget {
  const WritePrescriptionScreen({super.key});

  @override
  State<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState
    extends State<WritePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _diagnosisController = TextEditingController();
  final _medicineController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  List<Map<String, dynamic>> patients = [];

  String? selectedPatientName;

  bool isLoadingPatients = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  // ============================================================
  // DEMO PATIENTS
  // ============================================================

  Future<void> _loadPatients() async {
    final demoPatients = [
      {
        'name': 'Arpita',
      },
      {
        'name': 'Soham Kundu',
      },
      {
        'name': 'Sohan Das',
      },
      {
        'name': 'Augnik Ganguly',
      },
    ];

    if (!mounted) {
      return;
    }

    setState(() {
      patients = demoPatients;
      isLoadingPatients = false;
    });
  }

  // ============================================================
  // SAVE PRESCRIPTION
  // ============================================================

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedPatientName == null ||
        selectedPatientName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await LocalStorageService.savePrescription(
      patientName: selectedPatientName!,
      diagnosis: _diagnosisController.text.trim(),
      medicine: _medicineController.text.trim(),
      dosage: _dosageController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Prescription saved successfully',
        ),
      ),
    );

    _diagnosisController.clear();
    _medicineController.clear();
    _dosageController.clear();
    _instructionsController.clear();

    setState(() {
      selectedPatientName = null;
    });
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medicineController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write Prescription',
        ),
        centerTitle: true,
      ),

      body: isLoadingPatients
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // PATIENT
                    // =================================================

                    const Text(
                      'Patient',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedPatientName,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Select patient',

                        prefixIcon:
                            const Icon(
                          Icons.person,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      items: patients.map(
                        (patient) {
                          final name =
                              patient['name']
                                  .toString();

                          return DropdownMenuItem<
                              String>(
                            value: name,
                            child: Text(name),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedPatientName =
                              value;
                        });
                      },

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please select a patient';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // DIAGNOSIS
                    // =================================================

                    _buildTextField(
                      controller:
                          _diagnosisController,
                      label: 'Diagnosis',
                      hint: 'Enter diagnosis',
                      icon: Icons
                          .medical_information,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // MEDICINE
                    // =================================================

                    _buildTextField(
                      controller:
                          _medicineController,
                      label: 'Medicine Name',
                      hint: 'Enter medicine name',
                      icon: Icons.medication,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // DOSAGE
                    // =================================================

                    _buildTextField(
                      controller:
                          _dosageController,
                      label: 'Dosage',
                      hint:
                          'Example: 1 tablet twice daily',
                      icon: Icons.schedule,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // INSTRUCTIONS
                    // =================================================

                    _buildTextField(
                      controller:
                          _instructionsController,
                      label: 'Instructions',
                      hint: 'Enter instructions',
                      icon: Icons.notes,
                      maxLines: 4,
                      required: false,
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // SAVE
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child:
                          ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : _savePrescription,

                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),

                        label: Text(
                          isSaving
                              ? 'Saving...'
                              : 'Save Prescription',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF35AFA0,
                          ),

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
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,

      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),

      validator: required
          ? (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter $label';
              }

              return null;
            }
          : null,
    );
  }
}