import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() =>
      _AvailabilityScreenState();
}

class _AvailabilityScreenState
    extends State<AvailabilityScreen> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, bool> available = {};

  final Map<String, TimeOfDay?> startTimes = {};
  final Map<String, TimeOfDay?> endTimes = {};

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    for (final day in days) {
      available[day] = false;
      startTimes[day] = null;
      endTimes[day] = null;
    }

    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final prefs =
        await SharedPreferences.getInstance();

    for (final day in days) {
      available[day] =
          prefs.getBool('availability_${day}_enabled') ??
              false;

      final startHour =
          prefs.getInt('availability_${day}_start_hour');

      final startMinute =
          prefs.getInt('availability_${day}_start_minute');

      final endHour =
          prefs.getInt('availability_${day}_end_hour');

      final endMinute =
          prefs.getInt('availability_${day}_end_minute');

      if (startHour != null && startMinute != null) {
        startTimes[day] = TimeOfDay(
          hour: startHour,
          minute: startMinute,
        );
      }

      if (endHour != null && endMinute != null) {
        endTimes[day] = TimeOfDay(
          hour: endHour,
          minute: endMinute,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveAvailability() async {
    setState(() {
      isSaving = true;
    });

    final prefs =
        await SharedPreferences.getInstance();

    for (final day in days) {
      await prefs.setBool(
        'availability_${day}_enabled',
        available[day] ?? false,
      );

      final start = startTimes[day];
      final end = endTimes[day];

      if (start != null) {
        await prefs.setInt(
          'availability_${day}_start_hour',
          start.hour,
        );

        await prefs.setInt(
          'availability_${day}_start_minute',
          start.minute,
        );
      }

      if (end != null) {
        await prefs.setInt(
          'availability_${day}_end_hour',
          end.hour,
        );

        await prefs.setInt(
          'availability_${day}_end_minute',
          end.minute,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Availability saved successfully',
        ),
      ),
    );
  }

  Future<void> _selectStartTime(String day) async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          startTimes[day] ??
              const TimeOfDay(
                hour: 9,
                minute: 0,
              ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      startTimes[day] = selected;
    });
  }

  Future<void> _selectEndTime(String day) async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          endTimes[day] ??
              const TimeOfDay(
                hour: 17,
                minute: 0,
              ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      endTimes[day] = selected;
    });
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select time';
    }

    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9F9),

      appBar: AppBar(
        title: const Text(
          'Availability',
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 20),

                  const Text(
                    'Weekly Availability',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Select the days and time you are available for appointments.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...days.map(
                    (day) => _buildDayCard(day),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed:
                          isSaving
                              ? null
                              : _saveAvailability,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),
                      label: Text(
                        isSaving
                            ? 'Saving...'
                            : 'Save Availability',
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
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
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
            BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.access_time_rounded,
              size: 30,
              color: Color(0xFF167C71),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Your Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Let patients know when you are available.',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final isAvailable =
        available[day] ?? false;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Switch(
                  value: isAvailable,
                  activeThumbColor:
                      const Color(0xFF35AFA0),
                  onChanged: (value) {
                    setState(() {
                      available[day] = value;
                    });
                  },
                ),
              ],
            ),

            if (isAvailable) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _timeButton(
                      label: 'Start',
                      time: startTimes[day],
                      onTap: () =>
                          _selectStartTime(day),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _timeButton(
                      label: 'End',
                      time: endTimes[day],
                      onTap: () =>
                          _selectEndTime(day),
                    ),
                  ),
                ],
              ),
            ] else
              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  'Not Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF9),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 17,
                  color: Color(0xFF167C71),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}