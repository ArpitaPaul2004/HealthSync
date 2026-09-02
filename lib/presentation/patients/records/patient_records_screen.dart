import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() =>
      _PatientRecordsScreenState();
}

class _PatientRecordsScreenState
    extends State<PatientRecordsScreen> {
  String selectedCategory = 'All';

  List<Map<String, dynamic>> records = [];

  final List<String> categories = [
    'All',
    'Lab Report',
    'Prescription',
    'Scan / X-Ray',
    'Doctor Report',
    'Medical History',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prescriptions =
        await LocalStorageService.getPrescriptions();

    final prescriptionRecords =
        prescriptions.map<Map<String, dynamic>>((prescription) {
      final createdAt =
          prescription['createdAt']?.toString() ?? '';

      String date = '';

      if (createdAt.isNotEmpty) {
        try {
          final parsedDate = DateTime.parse(createdAt);

          date =
              '${parsedDate.day.toString().padLeft(2, '0')} '
              '${_monthName(parsedDate.month)} '
              '${parsedDate.year}';
        } catch (_) {
          date = '';
        }
      }

      return {
        'title': 'Prescription',
        'type': 'Prescription',
        'doctor':
            prescription['doctorName']?.toString() ??
                'Doctor',
        'hospital': 'HealthSync',
        'date': date,
        'icon': Icons.medication_rounded,
        'diagnosis':
            prescription['diagnosis']?.toString() ?? '',
        'medicine':
            prescription['medicine']?.toString() ?? '',
        'dosage':
            prescription['dosage']?.toString() ?? '',
        'instructions':
            prescription['instructions']?.toString() ?? '',
        'patientName':
            prescription['patientName']?.toString() ?? '',
      };
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      records = prescriptionRecords;
    });
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = selectedCategory == 'All'
        ? records
        : records.where((record) {
            return record['type'] == selectedCategory;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Medical Records',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showComingSoon(
                'Upload medical record',
              );
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFF167C71),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: const Color(0xFF35AFA0),
        onRefresh: _loadRecords,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            5,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              _buildCategoryFilter(),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your Records',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    '${filteredRecords.length} records',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (filteredRecords.isEmpty)
                _buildEmptyState()
              else
                ...filteredRecords.map(
                  (record) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child:
                          _buildRecordCard(record),
                    );
                  },
                ),
            ],
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showComingSoon(
            'Upload medical record',
          );
        },
        backgroundColor:
            const Color(0xFF35AFA0),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.upload_file_rounded,
        ),
        label: const Text(
          'Upload Record',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD8F3EF),
            Color(0xFFEAF8F5),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.folder_copy_rounded,
              size: 31,
              color: Color(0xFF167C71),
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Health Records',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Keep your medical information '
                  'organized in one place.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category =
              categories[index];

          final isSelected =
              selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF35AFA0)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF35AFA0)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    Map<String, dynamic> record,
  ) {
    final String title =
        record['title']?.toString() ??
            'Medical Record';

    final String type =
        record['type']?.toString() ??
            'Record';

    final String doctor =
        record['doctor']?.toString() ??
            'Doctor';

    final String hospital =
        record['hospital']?.toString() ??
            'Hospital';

    final String date =
        record['date']?.toString() ?? '';

    final IconData icon =
        record['icon'] as IconData;

    return GestureDetector(
      onTap: () {
        _openRecordDetails(record);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFD8F3EF),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color:
                    const Color(0xFF167C71),
                size: 27,
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
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEAF8F5),
                      borderRadius:
                          BorderRadius.circular(7),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 9,
                        color:
                            Color(0xFF167C71),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    doctor,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    hospital,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 14),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFD8F3EF),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              size: 38,
              color: Color(0xFF167C71),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No Records Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'There are no records in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _openRecordDetails(
    Map<String, dynamic> record,
  ) {
    final title =
        record['title']?.toString() ??
            'Medical Record';

    final type =
        record['type']?.toString() ??
            'Record';

    final doctor =
        record['doctor']?.toString() ??
            'Doctor';

    final hospital =
        record['hospital']?.toString() ??
            'Hospital';

    final date =
        record['date']?.toString() ?? '';

    final IconData icon =
        record['icon'] as IconData;

    final diagnosis =
        record['diagnosis']?.toString() ?? '';

    final medicine =
        record['medicine']?.toString() ?? '';

    final dosage =
        record['dosage']?.toString() ?? '';

    final instructions =
        record['instructions']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
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
          child: SingleChildScrollView(
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

                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFD8F3EF),
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color:
                        const Color(0xFF167C71),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEAF8F5),
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF167C71),
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                _detailRow(
                  Icons.person_outline_rounded,
                  'Doctor',
                  doctor,
                ),

                _detailRow(
                  Icons.local_hospital_outlined,
                  'Hospital',
                  hospital,
                ),

                _detailRow(
                  Icons.calendar_today_outlined,
                  'Date',
                  date,
                ),

                if (type == 'Prescription') ...[
                  const SizedBox(height: 12),

                  _detailRow(
                    Icons.medical_information_outlined,
                    'Diagnosis',
                    diagnosis,
                  ),

                  _detailRow(
                    Icons.medication_outlined,
                    'Medicine',
                    medicine,
                  ),

                  _detailRow(
                    Icons.schedule_outlined,
                    'Dosage',
                    dosage,
                  ),

                  _detailRow(
                    Icons.info_outline,
                    'Instructions',
                    instructions.isEmpty
                        ? 'None'
                        : instructions,
                  ),
                ],

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.visibility_outlined,
                    ),
                    label: const Text(
                      'Close',
                    ),
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
                  ),
                ),
              ],
            ),
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
            size: 19,
            color:
                const Color(0xFF167C71),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 85,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected later.',
        ),
        behavior:
            SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}