import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import '../screens/patient_login_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState
    extends State<PatientProfileScreen> {
  String patientName = 'Patient';
  String patientEmail = '';
  String patientPhone = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final name =
        await LocalStorageService.getPatientName();

    final email =
        await LocalStorageService.getPatientEmail();

    final phone =
        await LocalStorageService.getPatientPhone();

    if (!mounted) return;

    setState(() {
      patientName = name;
      patientEmail = email;
      patientPhone = phone;
      isLoading = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF35AFA0),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF35AFA0),
              onRefresh: _loadProfile,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  40,
                ),

                child: Column(
                  children: [
                    _buildProfileHeader(),

                    const SizedBox(height: 25),

                    _buildPersonalInformation(),

                    const SizedBox(height: 18),

                    _buildAccountOptions(),

                    const SizedBox(height: 18),

                    _buildDangerZone(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,

            decoration: BoxDecoration(
              color: const Color(0xFFD8F3EF),
              shape: BoxShape.circle,

              border: Border.all(
                color: const Color(0xFF35AFA0),
                width: 2,
              ),
            ),

            child: const Icon(
              Icons.person_rounded,
              size: 50,
              color: Color(0xFF167C71),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            patientName,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            patientEmail.isEmpty
                ? 'Patient Account'
                : patientEmail,

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 45,

            child: OutlinedButton.icon(
              onPressed: _editProfile,

              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),

              label: const Text(
                'Edit Profile',
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF167C71),

                side: const BorderSide(
                  color: Color(0xFF35AFA0),
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    return _sectionCard(
      title: 'Personal Information',

      children: [
        _profileInfoTile(
          icon: Icons.person_outline_rounded,
          title: 'Full Name',
          value: patientName,
        ),

        const Divider(height: 1),

        _profileInfoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: patientEmail.isEmpty
              ? 'Not available'
              : patientEmail,
        ),

        const Divider(height: 1),

        _profileInfoTile(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: patientPhone.isEmpty
              ? 'Not available'
              : patientPhone,
        ),
      ],
    );
  }

  Widget _profileInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFD8F3EF),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF167C71),
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
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

  // ============================================================
  // ACCOUNT OPTIONS
  // ============================================================

  Widget _buildAccountOptions() {
    return _sectionCard(
      title: 'Account',

      children: [
        _optionTile(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          subtitle:
              'Update your account password',
          onTap: _changePassword,
        ),

        const Divider(height: 1),

        _optionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy & Security',
          subtitle:
              'Manage your account privacy',
          onTap: () {
            _showMessage(
              'Privacy settings will be connected later.',
            );
          },
        ),

        const Divider(height: 1),

        _optionTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle:
              'Get help with HealthSync',
          onTap: () {
            _showMessage(
              'Help & Support will be connected later.',
            );
          },
        ),
      ],
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      leading: Container(
        width: 45,
        height: 45,

        decoration: BoxDecoration(
          color: const Color(0xFFD8F3EF),
          borderRadius:
              BorderRadius.circular(13),
        ),

        child: Icon(
          icon,
          color: const Color(0xFF167C71),
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Padding(
        padding:
            const EdgeInsets.only(top: 3),

        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ),

      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
      ),

      onTap: onTap,
    );
  }

  // ============================================================
  // DANGER ZONE
  // ============================================================

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),

      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 46,

            child: OutlinedButton.icon(
              onPressed: _logout,

              icon: const Icon(
                Icons.logout_rounded,
              ),

              label: const Text(
                'Logout',
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,

                side: const BorderSide(
                  color: Colors.red,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: _deleteAccount,

            child: const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void _editProfile() {
    final nameController =
        TextEditingController(
      text: patientName,
    );

    final phoneController =
        TextEditingController(
      text: patientPhone,
    );

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon:
                        Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: phoneController,
                  keyboardType:
                      TextInputType.phone,

                  decoration:
                      const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon:
                        Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final name =
                    nameController.text.trim();

                final phone =
                    phoneController.text.trim();

                if (name.isEmpty) {
                  _showMessage(
                    'Name cannot be empty.',
                  );
                  return;
                }

                await LocalStorageService
                    .updatePatientProfile(
                  name: name,
                  phone: phone,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadProfile();

                if (!mounted) return;

                _showMessage(
                  'Profile updated successfully.',
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF35AFA0),
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  void _changePassword() {
    final passwordController =
        TextEditingController();

    final confirmController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Change Password',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: passwordController,
                obscureText: true,

                decoration:
                    const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon:
                      Icon(Icons.lock_outline),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: confirmController,
                obscureText: true,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Confirm Password',
                  prefixIcon:
                      Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final password =
                    passwordController.text;

                final confirm =
                    confirmController.text;

                if (password.length < 6) {
                  _showMessage(
                    'Password must be at least 6 characters.',
                  );
                  return;
                }

                if (password != confirm) {
                  _showMessage(
                    'Passwords do not match.',
                  );
                  return;
                }

                await LocalStorageService
                    .updatePatientPassword(
                  password,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                _showMessage(
                  'Password changed successfully.',
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF35AFA0),
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout?',
          ),

          content: const Text(
            'Are you sure you want to logout from HealthSync?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await LocalStorageService.logoutPatient();

                if (!mounted) return;
                Navigator.pop(dialogContext);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const PatientLoginScreen(),
                  ),
                  (route) => false,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  void _deleteAccount() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Account?',
          ),

          content: const Text(
            'This will permanently delete your patient account from HealthSync and remove local appointments. This action cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  await LocalStorageService.deletePatientAccount();
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const PatientLoginScreen(),
                    ),
                    (route) => false,
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString().replaceFirst('Exception: ', ''),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}