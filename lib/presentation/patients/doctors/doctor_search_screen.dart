import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Priya Sharma',
      'specialization': 'Cardiologist',
      'hospital': 'CityCare Multispeciality Hospital',
      'location': 'Bhubaneswar',
      'rating': '4.8',
      'experience': '12 years',
      'fee': '₹600',
      'available': true,
      'patients': '1200+',
    },
    {
      'name': 'Dr. Rahul Mehta',
      'specialization': 'Neurologist',
      'hospital': 'Apollo Health Centre',
      'location': 'Bhubaneswar',
      'rating': '4.7',
      'experience': '10 years',
      'fee': '₹700',
      'available': true,
      'patients': '980+',
    },
    {
      'name': 'Dr. Ananya Das',
      'specialization': 'Dermatologist',
      'hospital': 'KIMS Hospital',
      'location': 'Bhubaneswar',
      'rating': '4.9',
      'experience': '8 years',
      'fee': '₹500',
      'available': false,
      'patients': '850+',
    },
    {
      'name': 'Dr. Arjun Patel',
      'specialization': 'Orthopedic',
      'hospital': 'SUM Ultimate Medicare',
      'location': 'Bhubaneswar',
      'rating': '4.6',
      'experience': '15 years',
      'fee': '₹800',
      'available': true,
      'patients': '1500+',
    },
    {
      'name': 'Dr. Neha Singh',
      'specialization': 'Pediatrician',
      'hospital': 'CityCare Multispeciality Hospital',
      'location': 'Bhubaneswar',
      'rating': '4.8',
      'experience': '9 years',
      'fee': '₹550',
      'available': true,
      'patients': '1100+',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredDoctors {
    final query = searchController.text.trim().toLowerCase();

    return doctors.where((doctor) {
      final matchesSearch =
          query.isEmpty ||
          doctor['name'].toString().toLowerCase().contains(query) ||
          doctor['specialization']
              .toString()
              .toLowerCase()
              .contains(query) ||
          doctor['hospital']
              .toString()
              .toLowerCase()
              .contains(query);

      bool matchesFilter = true;

      if (selectedFilter == 'Available') {
        matchesFilter = doctor['available'] == true;
      } else if (selectedFilter == 'Top Rated') {
        matchesFilter =
            double.parse(doctor['rating'].toString()) >= 4.8;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _openDoctorDetails(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailsScreen(
          doctor: doctor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredDoctors;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find a Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              18,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Search doctor, specialty or hospital',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                    ),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              )
                            : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F7F7),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _filterChip('All'),
                      _filterChip('Available'),
                      _filterChip('Top Rated'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _doctorCard(results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filter) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        selectedColor: const Color(0xFFD8F3EF),
        labelStyle: TextStyle(
          color: isSelected
              ? const Color(0xFF167C71)
              : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _doctorCard(Map<String, dynamic> doctor) {
    final bool available = doctor['available'] == true;

    return GestureDetector(
      onTap: () => _openDoctorDetails(doctor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8F3EF),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: Color(0xFF167C71),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        doctor['specialization'],
                        style: const TextStyle(
                          color: Color(0xFF167C71),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            doctor['rating'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            doctor['experience'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    doctor['hospital'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 7),
                Text(
                  doctor['location'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  doctor['fee'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: available
                        ? const Color(0xFFEAF8F5)
                        : Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    available
                        ? 'Available today'
                        : 'Currently unavailable',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: available
                          ? const Color(0xFF167C71)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),

                const Spacer(),

                const Text(
                  'View Profile',
                  style: TextStyle(
                    color: Color(0xFF167C71),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
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
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3EF),
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 42,
                color: Color(0xFF167C71),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No doctors found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Try searching for another doctor or specialty.',
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

// ============================================================
// DOCTOR DETAILS
// ============================================================

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
  });

  void _bookAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDateScreen(
          doctor: doctor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool available = doctor['available'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8F3EF),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: Color(0xFF167C71),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    doctor['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    doctor['specialization'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF167C71),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        doctor['rating'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        doctor['experience'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _infoCard(
              Icons.local_hospital_outlined,
              'Hospital',
              doctor['hospital'],
            ),

            _infoCard(
              Icons.location_on_outlined,
              'Location',
              doctor['location'],
            ),

            _infoCard(
              Icons.people_outline_rounded,
              'Patients Consulted',
              doctor['patients'],
            ),

            _infoCard(
              Icons.currency_rupee_rounded,
              'Consultation Fee',
              doctor['fee'],
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                  Icon(
                    available
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: available
                        ? const Color(0xFF35AFA0)
                        : Colors.grey,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      available
                          ? 'This doctor is available for appointments.'
                          : 'This doctor is currently unavailable.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: available
                    ? () => _bookAppointment(context)
                    : null,
                icon: const Icon(
                  Icons.calendar_month_rounded,
                ),
                label: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F5),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF167C71),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
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
}

// ============================================================
// APPOINTMENT DATE
// ============================================================

class AppointmentDateScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const AppointmentDateScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<AppointmentDateScreen> createState() =>
      _AppointmentDateScreenState();
}

class _AppointmentDateScreenState
    extends State<AppointmentDateScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _doctorMiniCard(doctor),

            const SizedBox(height: 28),

            const Text(
              'Select Appointment Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(
                    Duration(days: index),
                  );

                  final selected =
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      padding:
                          const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFD8F3EF)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF35AFA0)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF35AFA0)
                                  : Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              _formatDate(date),
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color:
                                  Color(0xFF35AFA0),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AppointmentTimeScreen(
                        doctor: doctor,
                        selectedDate: selectedDate,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorMiniCard(
      Map<String, dynamic> doctor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFD8F3EF),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF167C71),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  doctor['specialization'],
                  style: const TextStyle(
                    color: Color(0xFF167C71),
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

  String _formatDate(DateTime date) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[date.weekday % 7]}, '
        '${date.day} ${months[date.month - 1]} '
        '${date.year}';
  }
}

// ============================================================
// APPOINTMENT TIME
// ============================================================

class AppointmentTimeScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final DateTime selectedDate;

  const AppointmentTimeScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
  });

  @override
  State<AppointmentTimeScreen> createState() =>
      _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState
    extends State<AppointmentTimeScreen> {
  String? selectedTime;

  final List<String> timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Choose an available time for your appointment.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  final selected =
                      selectedTime == time;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF35AFA0)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF35AFA0)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedTime == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppointmentConfirmationScreen(
                              doctor: widget.doctor,
                              selectedDate:
                                  widget.selectedDate,
                              selectedTime:
                                  selectedTime!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONFIRMATION
// ============================================================

class AppointmentConfirmationScreen
    extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final DateTime selectedDate;
  final String selectedTime;

  const AppointmentConfirmationScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
  });

  Future<void> _saveAppointment(
      BuildContext context) async {
    await LocalStorageService.saveAppointment(
      doctorName: doctor['name'].toString(),
      specialization:
          doctor['specialization'].toString(),
      hospitalName:
          doctor['hospital'].toString(),
      date: _formatDate(selectedDate),
      time: selectedTime,
      fee: doctor['fee'].toString(),
    );

    if (!context.mounted) return;

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Appointment Confirmed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3EF),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 58,
                color: Color(0xFF35AFA0),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Appointment Confirmed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your appointment has been scheduled successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    doctor['name'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    doctor['specialization'].toString(),
                    style: const TextStyle(
                      color: Color(0xFF167C71),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Divider(height: 30),

                  _detailRow(
                    Icons.calendar_month_rounded,
                    'Date',
                    _formatDate(selectedDate),
                  ),

                  const SizedBox(height: 16),

                  _detailRow(
                    Icons.access_time_rounded,
                    'Time',
                    selectedTime,
                  ),

                  const SizedBox(height: 16),

                  _detailRow(
                    Icons.local_hospital_outlined,
                    'Hospital',
                    doctor['hospital'].toString(),
                  ),

                  const SizedBox(height: 16),

                  _detailRow(
                    Icons.currency_rupee_rounded,
                    'Consultation Fee',
                    doctor['fee'].toString(),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _saveAppointment(context),
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                ),
                label: const Text(
                  'Save & Back to Home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF35AFA0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF167C71),
          size: 21,
        ),

        const SizedBox(width: 12),

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

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[date.weekday % 7]}, '
        '${date.day} ${months[date.month - 1]} '
        '${date.year}';
  }
}