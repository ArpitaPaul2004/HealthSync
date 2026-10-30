
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../onboarding/role_selection_screen.dart';

class HospitalAdminDashboardScreen extends StatefulWidget {
  final String token;
  final String adminName;
  final Future<void> Function() onLogout;

  const HospitalAdminDashboardScreen({
    super.key,
    required this.token,
    required this.adminName,
    required this.onLogout,
  });

  @override
  State<HospitalAdminDashboardScreen> createState() =>
      _HospitalAdminDashboardScreenState();
}

class _HospitalAdminDashboardScreenState
    extends State<HospitalAdminDashboardScreen> {
  static const String _apiBaseUrl = 'http://192.168.29.21:4000/api';

  static const Color _navy = Color(0xFF142B4A);
  static const Color _blue = Color(0xFF2878D0);
  static const Color _background = Color(0xFFF3F6FB);

  Map<String, dynamic>? _hospital;
  List<Map<String, dynamic>> _assignedDoctors = [];
  List<Map<String, dynamic>> _availableDoctors = [];
  List<Map<String, dynamic>> _beds = [];

  bool _loading = true;
  bool _working = false;
  bool _loggingOut = false;

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    _loggingOut = true;

    try {
      await widget.onLogout();
    } catch (error) {
      debugPrint('Hospital Admin logout error: $error');
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Unexpected server response');
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asStringMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl$path'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    ).timeout(const Duration(seconds: 20));

    final data = _decodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        (data['error'] ?? 'Request failed').toString(),
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 20));

    final data = _decodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        (data['error'] ?? 'Request failed').toString(),
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_apiBaseUrl$path'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    ).timeout(const Duration(seconds: 20));

    final data = _decodeMap(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        (data['error'] ?? 'Request failed').toString(),
      );
    }

    return data;
  }

  Future<void> _loadDashboard({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() => _loading = true);
    }

    try {
      final results = await Future.wait([
        _get('/hospitals/mine'),
        _get('/hospitals/mine/doctors'),
        _get('/doctors/available'),
      ]);

      final hospitalData = _asStringMap(results[0]['hospital']);
      if (hospitalData.isEmpty) {
        throw Exception('Hospital details were not returned');
      }

      final hospitalId = hospitalData['id']?.toString();
      if (hospitalId == null || hospitalId.isEmpty) {
        throw Exception('Hospital ID is missing');
      }

      if (!mounted) return;

      setState(() {
        _hospital = hospitalData;
        _assignedDoctors = _asStringMapList(results[1]['doctors']);
        _availableDoctors = _asStringMapList(results[2]['doctors']);
        _beds = _asStringMapList(hospitalData['beds']);
      });
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _assignDoctor(Map<String, dynamic> doctor) async {
    final id = doctor['id']?.toString();
    if (id == null || id.isEmpty || _working) return;

    setState(() => _working = true);

    try {
      final result = await _post('/hospitals/mine/doctors/$id', {});
      _showMessage(
        (result['message'] ?? 'Doctor assigned successfully').toString(),
      );
      await _loadDashboard(showLoader: false);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _removeDoctor(Map<String, dynamic> doctor) async {
    final id = doctor['id']?.toString();
    if (id == null || id.isEmpty || _working) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove doctor?'),
        content: Text(
          'Remove ${doctor['name'] ?? 'this doctor'} from your hospital? '
          'Their doctor account will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _working = true);

    try {
      final result = await _delete('/hospitals/mine/doctors/$id');
      _showMessage(
        (result['message'] ?? 'Doctor removed successfully').toString(),
      );
      await _loadDashboard(showLoader: false);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _showAddBedsDialog() async {
    if (_working) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => const _AddBedsDialog(),
    );

    if (!mounted || result == null) return;

    await _addBeds(
      result['count'] as int,
      result['prefix'] as String,
      result['ward'] as String,
    );
  }

  Future<void> _addBeds(int count, String prefix, String ward) async {
    final hospitalId = _hospital?['id']?.toString();
    if (hospitalId == null || _working) return;

    // Find the highest existing number for this prefix so that adding beds
    // never starts again at 001 when labels already exist.
    final labelPattern = RegExp(
      '^' + RegExp.escape(prefix) + r'-(\d+)$',
      caseSensitive: false,
    );

    var highestExistingNumber = 0;
    for (final bed in _beds) {
      final existingLabel = bed['label']?.toString().trim();
      if (existingLabel == null) continue;

      final match = labelPattern.firstMatch(existingLabel);
      final number = int.tryParse(match?.group(1) ?? '');
      if (number != null && number > highestExistingNumber) {
        highestExistingNumber = number;
      }
    }

    final beds = List.generate(count, (index) {
      final nextNumber = highestExistingNumber + index + 1;
      return {
        'label': '$prefix-${nextNumber.toString().padLeft(3, '0')}',
        if (ward.isNotEmpty) 'ward': ward,
      };
    });

    setState(() => _working = true);

    try {
      final result = await _post(
        '/hospitals/$hospitalId/beds',
        {'beds': beds},
      );

      _showMessage(
        (result['message'] ?? 'Beds added successfully').toString(),
      );
      await _loadDashboard(showLoader: false);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard(
    Map<String, dynamic> doctor, {
    required bool assigned,
  }) {
    final name = doctor['name']?.toString() ?? 'Unknown doctor';
    final specialization =
        doctor['specialization']?.toString() ?? 'Not specified';
    final email = doctor['email']?.toString() ?? '';

    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: _blue.withValues(alpha: 0.12),
              child: const Icon(
                Icons.medical_services_outlined,
                color: _blue,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    specialization,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (assigned)
              OutlinedButton(
                onPressed: _working ? null : () => _removeDoctor(doctor),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text('Remove'),
              )
            else
              FilledButton(
                onPressed: _working ? null : () => _assignDoctor(doctor),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Assign'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBedsSection() {
    final totalBeds = _hospital?['totalBeds'] ?? _beds.length;
    final availableBeds = _hospital?['availableBeds'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Bed Management',
          'View and add beds in your hospital.',
        ),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Total beds',
                value: '$totalBeds',
                icon: Icons.bed,
                color: _blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: 'Available beds',
                value: '$availableBeds',
                icon: Icons.hotel,
                color: const Color(0xFF159B83),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _working ? null : _showAddBedsDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add beds'),
          ),
        ),
        const SizedBox(height: 12),
        if (_beds.isEmpty)
          _emptyState('No beds have been added yet.', Icons.bed_outlined)
        else
          ..._beds.map((item) {
            return Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.bed_outlined, color: _blue),
                title: Text(item['label']?.toString() ?? 'Bed'),
                subtitle: Text(
                  item['ward']?.toString().isNotEmpty == true
                      ? item['ward'].toString()
                      : 'Ward not specified',
                ),
                trailing: Text(
                  item['available'] == false ? 'Occupied' : 'Available',
                  style: TextStyle(
                    color: item['available'] == false
                        ? Colors.orange.shade800
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hospitalName =
        _hospital?['name']?.toString() ?? 'Your Hospital';
    final city = _hospital?['city']?.toString() ?? '';
    final address = _hospital?['address']?.toString() ?? '';
    final approved = _hospital?['approved'] == true;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text(
          'HealthSync Hospital',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : () => _loadDashboard(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: _loggingOut ? null : _handleLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _loadDashboard(showLoader: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_navy, _blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.local_hospital_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  hospitalName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  [address, city]
                                      .where((part) => part.isNotEmpty)
                                      .join(', '),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Welcome, ${widget.adminName}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    approved
                                        ? 'Approved hospital'
                                        : 'Pending hospital approval',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(
                            'Hospital Overview',
                            'A quick view of your hospital.',
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns =
                                  constraints.maxWidth >= 650 ? 3 : 1;
                              return GridView.count(
                                crossAxisCount: columns,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: columns == 1 ? 3.2 : 1.8,
                                children: [
                                  _statCard(
                                    title: 'Assigned doctors',
                                    value: '${_assignedDoctors.length}',
                                    icon: Icons.medical_services_outlined,
                                    color: _blue,
                                  ),
                                  _statCard(
                                    title: 'Available doctors',
                                    value: '${_availableDoctors.length}',
                                    icon: Icons.person_search_outlined,
                                    color: const Color(0xFF805AD5),
                                  ),
                                  _statCard(
                                    title: 'Total beds',
                                    value: '${_hospital?['totalBeds'] ?? 0}',
                                    icon: Icons.bed_outlined,
                                    color: const Color(0xFF159B83),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _sectionTitle(
                            'Assigned Doctors',
                            'Doctors currently working with your hospital.',
                          ),
                          if (_assignedDoctors.isEmpty)
                            _emptyState(
                              'No doctors assigned yet.',
                              Icons.person_off_outlined,
                            )
                          else
                            ..._assignedDoctors.map((doctor) {
                              return _doctorCard(doctor, assigned: true);
                            }),
                          const SizedBox(height: 24),
                          _sectionTitle(
                            'Available Doctors',
                            'Select doctors to add to your hospital.',
                          ),
                          if (_availableDoctors.isEmpty)
                            _emptyState(
                              'There are no unassigned doctors available.',
                              Icons.search_off_rounded,
                            )
                          else
                            ..._availableDoctors.map((doctor) {
                              return _doctorCard(doctor, assigned: false);
                            }),
                          const SizedBox(height: 24),
                          _buildBedsSection(),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'HealthSync • Hospital Admin Portal',
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
      ),
    );
  }
}

class _AddBedsDialog extends StatefulWidget {
  const _AddBedsDialog();

  @override
  State<_AddBedsDialog> createState() => _AddBedsDialogState();
}

class _AddBedsDialogState extends State<_AddBedsDialog> {
  final _formKey = GlobalKey<FormState>();

  final _countController = TextEditingController(text: '1');
  final _prefixController = TextEditingController(text: 'BED');
  final _wardController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    _prefixController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'count': int.parse(_countController.text),
      'prefix': _prefixController.text.trim(),
      'ward': _wardController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add beds'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of beds',
                    prefixIcon: Icon(Icons.bed_outlined),
                  ),
                  validator: (value) {
                    final count = int.tryParse(value ?? '');
                    if (count == null || count < 1 || count > 100) {
                      return 'Enter a number from 1 to 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prefixController,
                  decoration: const InputDecoration(
                    labelText: 'Bed label prefix',
                    hintText: 'Example: BED',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a prefix';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wardController,
                  decoration: const InputDecoration(
                    labelText: 'Ward (optional)',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Labels will be generated sequentially, such as '
                  'BED-001, BED-002 and BED-003.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add beds'),
        ),
      ],
    );
  }
}