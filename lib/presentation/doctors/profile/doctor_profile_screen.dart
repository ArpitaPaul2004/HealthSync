
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import '../screens/doctor_login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() =>
      _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final specializationController = TextEditingController();
  final hospitalController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isLoggingOut = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait<String>([
        LocalStorageService.getDoctorName(),
        LocalStorageService.getDoctorPhone(),
        LocalStorageService.getDoctorSpecialization(),
        LocalStorageService.getDoctorHospital(),
      ]);

      if (!mounted) return;

      setState(() {
        nameController.text = results[0];
        phoneController.text = results[1];
        specializationController.text = results[2];
        hospitalController.text = results[3];
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Could not load profile: $error', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    if (isSaving || isDeleting || isLoggingOut) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      await LocalStorageService.updateDoctorProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        specialization: specializationController.text.trim(),
        hospital: hospitalController.text.trim(),
      );

      await LocalStorageService.saveDoctorToDirectory();

      if (!mounted) return;
      _showMessage('Doctor profile saved successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not save profile: ${_errorText(error)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _logout() async {
    if (isSaving || isDeleting || isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of your doctor account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isLoggingOut = true);

    try {
      await LocalStorageService.logoutDoctor();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const DoctorLoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoggingOut = false);
      _showMessage(
        'Could not log out: ${_errorText(error)}',
        isError: true,
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (isSaving || isDeleting || isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Doctor Account?'),
        content: const Text(
          'This permanently deletes your doctor account from the server. '
          'This action cannot be undone. If the account has linked records, '
          'the server may reject the deletion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isDeleting = true);

    try {
      // The service deletes from the backend first.
      // It clears local doctor data only after server confirmation.
      await LocalStorageService.deleteDoctorAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor account deleted successfully.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const DoctorLoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => isDeleting = false);

      _showMessage(
        'Account deletion failed: ${_errorText(error)}',
        isError: true,
      );
    }
  }

  String _errorText(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
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
    final busy = isSaving || isDeleting || isLoggingOut;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.teal.shade700,
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your professional information',
                        textAlign: TextAlign.center,
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
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: specializationController,
                        label: 'Specialization',
                        hint: 'Example: Cardiologist',
                        icon: Icons.medical_information_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: hospitalController,
                        label: 'Hospital',
                        hint: 'Enter hospital name',
                        icon: Icons.local_hospital_outlined,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: busy ? null : _saveProfile,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            isSaving ? 'Saving...' : 'Save Profile',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _logout,
                        icon: isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(
                          isLoggingOut ? 'Logging Out...' : 'Log Out',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade800,
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide(color: Colors.teal.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _deleteAccount,
                        icon: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.delete_forever_rounded),
                        label: Text(
                          isDeleting
                              ? 'Deleting Account...'
                              : 'Delete Account',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
    TextInputType keyboardType = TextInputType.text,
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
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
