
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SuperAdminDashboardScreen extends StatefulWidget {
  final String token;
  final String adminName;
  final VoidCallback onLogout;

  const SuperAdminDashboardScreen({
    super.key,
    required this.token,
    required this.adminName,
    required this.onLogout,
  });

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends State<SuperAdminDashboardScreen> {
  static const String _apiBaseUrl =
      'http://192.168.29.21:4000/api';

  bool _creatingDoctor = false;

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _showCreateDoctorDialog() async {
    if (!mounted || _creatingDoctor) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateDoctorDialog(
        onCreateDoctor: _createDoctor,
      ),
    );
  }

  Future<bool> _createDoctor({
    required String name,
    required String email,
    required String phone,
    required String specialization,
    required String password,
  }) async {
    if (_creatingDoctor) return false;

    setState(() => _creatingDoctor = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/auth/admin/doctors'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.token}',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone.isEmpty ? null : phone,
              'specialization': specialization.isEmpty
                  ? 'General Physician'
                  : specialization,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> data = {};

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } on FormatException {
        // Handle an unexpected response below.
      }

      if (response.statusCode == 201) {
        _showMessage('Doctor account created successfully.');
        return true;
      }

      _showMessage(
        (data['error'] ?? 'Could not create doctor account').toString(),
        isError: true,
      );

      return false;
    } on Exception {
      _showMessage(
        'Unable to connect to the backend. Check the network and API URL.',
        isError: true,
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _creatingDoctor = false);
      }
    }
  }

  void _showHospitalApprovals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HospitalApprovalsScreen(
          token: widget.token,
          apiBaseUrl: _apiBaseUrl,
        ),
      ),
    );
  }

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF142B4A);
    const blue = Color(0xFF2878D0);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text(
          'HealthSync Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [navy, blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Super Admin Dashboard',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome, ${widget.adminName}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manage access and oversee the HealthSync platform.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Platform Management',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Administration areas',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850
                          ? 3
                          : constraints.maxWidth >= 540
                              ? 2
                              : 1;

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: columns == 1 ? 2.1 : 1.45,
                        children: [
                          _managementCard(
                            icon: Icons.medical_services_rounded,
                            title: 'Doctor Accounts',
                            description:
                                'Provision authorized doctor accounts.',
                            color: blue,
                          ),
                          _managementCard(
                            icon: Icons.local_hospital_rounded,
                            title: 'Hospitals',
                            description: 'Hospital management area.',
                            color: const Color(0xFF159B83),
                          ),
                          _managementCard(
                            icon: Icons.fact_check_rounded,
                            title: 'Approvals',
                            description:
                                'Review and approve hospital requests.',
                            color: const Color(0xFFB7791F),
                            onTap: _showHospitalApprovals,
                          ),
                          _managementCard(
                            icon: Icons.people_alt_rounded,
                            title: 'Users',
                            description:
                                'Platform user management area.',
                            color: const Color(0xFF805AD5),
                          ),
                          _managementCard(
                            icon: Icons.bar_chart_rounded,
                            title: 'Statistics',
                            description: 'Platform statistics area.',
                            color: const Color(0xFF3182CE),
                          ),
                          _managementCard(
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            description:
                                'Administrator settings area.',
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Doctor Provisioning',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create authorized doctor credentials.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 36,
                            color: blue,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create a Doctor Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the doctor’s details and set an initial '
                            'password. Only an authenticated Super Admin '
                            'can create doctor accounts.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _creatingDoctor
                                  ? null
                                  : _showCreateDoctorDialog,
                              icon: _creatingDoctor
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(
                                _creatingDoctor
                                    ? 'Creating account...'
                                    : 'Create Doctor Account',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      'HealthSync • Super Admin Portal',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateDoctorDialog extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required String email,
    required String phone,
    required String specialization,
    required String password,
  }) onCreateDoctor;

  const _CreateDoctorDialog({
    required this.onCreateDoctor,
  });

  @override
  State<_CreateDoctorDialog> createState() =>
      _CreateDoctorDialogState();
}

class _CreateDoctorDialogState extends State<_CreateDoctorDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController =
      TextEditingController(text: 'General Physician');
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an email address';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ?? _requiredValidator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    var success = false;

    try {
      success = await widget.onCreateDoctor(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization:
            _specializationController.text.trim().isEmpty
                ? 'General Physician'
                : _specializationController.text.trim(),
        password: _passwordController.text,
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: const Text('Create Doctor Account'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(
                    controller: _nameController,
                    label: 'Doctor full name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _emailController,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _phoneController,
                    label: 'Phone number (optional)',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _specializationController,
                    label: 'Specialization',
                    icon: Icons.medical_services_outlined,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Use at least 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Initial password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share the initial password with the doctor securely.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}


class _HospitalApprovalsScreen extends StatefulWidget {
  final String token;
  final String apiBaseUrl;

  const _HospitalApprovalsScreen({
    required this.token,
    required this.apiBaseUrl,
  });

  @override
  State<_HospitalApprovalsScreen> createState() =>
      _HospitalApprovalsScreenState();
}

class _HospitalApprovalsScreenState
    extends State<_HospitalApprovalsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _hospitals = <Map<String, dynamic>>[];
  final Set<String> _approvingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Future<void> _loadHospitals() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('${widget.apiBaseUrl}/hospitals/managed'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 20));

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw Exception('The server returned an invalid response.');
      }

      if (response.statusCode != 200) {
        final data = _asStringMap(decoded);
        throw Exception(
          (data['error'] ?? 'Could not load hospitals.').toString(),
        );
      }

      final data = _asStringMap(decoded);
      final dynamic rawHospitals =
          decoded is List ? decoded : data['hospitals'];

      if (rawHospitals is! List) {
        throw Exception(
          'The hospital list was not found in the server response.',
        );
      }

      final hospitals = rawHospitals
          .where((item) => item is Map)
          .map((item) => _asStringMap(item))
          .toList();

      if (!mounted) return;
      setState(() {
        _hospitals = hospitals;
        _loading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _approveHospital(Map<String, dynamic> hospital) async {
    final id = (hospital['id'] ?? '').toString();
    final name = (hospital['name'] ?? 'this hospital').toString();

    if (id.isEmpty || _approvingIds.contains(id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve hospital?'),
        content: Text(
          'Are you sure you want to approve $name? '
          'The hospital will become approved on HealthSync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _approvingIds.add(id));

    try {
      final response = await http.patch(
        Uri.parse('${widget.apiBaseUrl}/hospitals/$id/approve'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 20));

      dynamic decoded;
      try {
        decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
      } on FormatException {
        decoded = <String, dynamic>{};
      }

      if (response.statusCode != 200) {
        final data = _asStringMap(decoded);
        throw Exception(
          (data['error'] ?? 'Could not approve this hospital.').toString(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name approved successfully.'),
          backgroundColor: Colors.green.shade700,
        ),
      );

      await _loadHospitals();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _approvingIds.remove(id));
      }
    }
  }

  Widget _hospitalCard(Map<String, dynamic> hospital) {
    final id = (hospital['id'] ?? '').toString();
    final name = (hospital['name'] ?? 'Unnamed hospital').toString();
    final address = (hospital['address'] ?? '').toString();
    final city = (hospital['city'] ?? '').toString();
    final phone = (hospital['phone'] ?? '').toString();
    final approved = hospital['approved'] == true;
    final approving = _approvingIds.contains(id);

    final location = [address, city]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF159B83).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Color(0xFF159B83),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          location,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: approved
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    approved ? 'Approved' : 'Pending approval',
                    style: TextStyle(
                      color: approved
                          ? Colors.green.shade800
                          : Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (!approved)
                  FilledButton(
                    onPressed: approving || id.isEmpty
                        ? null
                        : () => _approveHospital(hospital),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF159B83),
                      foregroundColor: Colors.white,
                    ),
                    child: approving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _hospitals.where((hospital) => hospital['approved'] != true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF142B4A),
        foregroundColor: Colors.white,
        title: const Text('Hospital Approvals'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadHospitals,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 42,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _loadHospitals,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadHospitals,
                    child: _hospitals.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 100),
                              Icon(
                                Icons.domain_disabled_outlined,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No hospitals found.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hospitals created on HealthSync will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(18),
                            children: [
                              Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.pending_actions_rounded,
                                        color: Color(0xFFB7791F),
                                        size: 30,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Pending hospitals',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '$pendingCount awaiting approval',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              ..._hospitals.map(_hospitalCard),
                            ],
                          ),
                  ),
      ),
    );
  }
}

