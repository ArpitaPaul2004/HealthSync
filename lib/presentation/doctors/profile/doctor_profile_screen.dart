import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() =>
      _DoctorProfileScreenState();
}

class _DoctorProfileScreenState
    extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final specializationController = TextEditingController();
  final hospitalController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name =
        await LocalStorageService.getDoctorName();

    final phone =
        await LocalStorageService.getDoctorPhone();

    final specialization =
        await LocalStorageService.getDoctorSpecialization();

    final hospital =
        await LocalStorageService.getDoctorHospital();

    if (!mounted) return;

    setState(() {
      nameController.text = name;
      phoneController.text = phone;
      specializationController.text =
          specialization;
      hospitalController.text = hospital;
      isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    await LocalStorageService.updateDoctorProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      specialization:
          specializationController.text.trim(),
      hospital: hospitalController.text.trim(),
    );
    await LocalStorageService.saveDoctorToDirectory();
    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Doctor profile saved successfully',
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    hospitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9F9),

      appBar: AppBar(
        title: const Text('Doctor Profile'),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            Colors.teal.shade700,
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Complete Your Profile',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Add your professional information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        hint: 'Enter doctor name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone',
                        hint: 'Enter phone number',
                        icon: Icons.phone_outlined,
                        keyboardType:
                            TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller:
                            specializationController,
                        label: 'Specialization',
                        hint:
                            'Example: Cardiologist',
                        icon:
                            Icons.medical_information_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller:
                            hospitalController,
                        label: 'Hospital',
                        hint:
                            'Enter hospital name',
                        icon:
                            Icons.local_hospital_outlined,
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : _saveProfile,
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
                                : 'Save Profile',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal.shade700,
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please enter $label';
        }

        return null;
      },
    );
  }
}