import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import '../hospitals/hospital_search_screen.dart';
import '../doctors/doctor_search_screen.dart';
import '../profile/patient_profile_screen.dart';
import '../records/patient_records_screen.dart';
import '../notifications/patient_notifications_screen.dart';
import '../hospitals/my_bed_bookings_screen.dart';
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> appointments = [];
  bool appointmentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // ============================================================
  // LOAD APPOINTMENTS
  // ============================================================

  Future<void> _loadAppointments() async {
    try {
      final data = await LocalStorageService.getAppointments();

      if (!mounted) return;

      setState(() {
        appointments = data.reversed.toList();
        appointmentsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        appointments = [];
        appointmentsLoading = false;
      });
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _buildHome(),
            _buildAppointments(),
            const PatientRecordsScreen(),
            const PatientNotificationsScreen(),
            const PatientProfileScreen(),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          // Refresh appointments whenever the tab is opened.
          if (index == 1) {
            _loadAppointments();
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD8F3EF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),

      // ============================================================
      // AI BUTTON
      // ============================================================

      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                _showComingSoon('HealthSync AI Assistant');
              },
              backgroundColor: const Color(0xFF35AFA0),
              foregroundColor: Colors.white,
              icon: const Icon(
                Icons.smart_toy_rounded,
              ),
              label: const Text(
                'HealthSync AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHome() {
    return RefreshIndicator(
      color: const Color(0xFF35AFA0),
      onRefresh: _loadAppointments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildSearchBar(),

            const SizedBox(height: 22),

            _buildEmergencyBanner(),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'What do you need?',
              'View all',
              () {},
            ),

            const SizedBox(height: 14),

            _buildQuickActions(),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Upcoming Appointment',
              'View all',
              () {
                setState(() {
                  selectedIndex = 1;
                });

                _loadAppointments();
              },
            ),

            const SizedBox(height: 14),

            _buildUpcomingAppointment(),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Nearby Hospitals',
              'See all',
              () {
                _openHospitalSearch();
              },
            ),

            const SizedBox(height: 14),

            _buildHospitalCard(
              hospitalName:
                  'CityCare Multispeciality Hospital',
              location: 'Bhubaneswar, Odisha',
              rating: '4.7',
              distance: '2.4 km',
              beds: '24 beds available',
            ),

            const SizedBox(height: 14),

            _buildHospitalCard(
              hospitalName: 'Apollo Health Centre',
              location: 'Bhubaneswar, Odisha',
              rating: '4.6',
              distance: '4.1 km',
              beds: '18 beds available',
            ),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Live Bed Availability',
              'View hospitals',
              () {
                _openHospitalSearch();
              },
            ),

            const SizedBox(height: 14),

            _buildBedAvailabilityCard(),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'HealthSync AI',
              '',
              () {},
            ),

            const SizedBox(height: 14),

            _buildAiCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD8F3EF),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFF167C71),
            size: 28,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening 👋',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Arpita Paul',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                selectedIndex = 3;
              });
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openHospitalSearch,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),

            Icon(
              Icons.search_rounded,
              color: Colors.grey.shade600,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'Search hospitals, doctors...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(right: 7),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3EF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF167C71),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMERGENCY
  // ============================================================

  Widget _buildEmergencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD1D1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD8D8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.red,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: const [
                Text(
                  'Emergency?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find nearby emergency care',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              _showComingSoon('Emergency SOS');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SOS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (action.isNotEmpty)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFF168B7D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

Widget _buildQuickActions() {
  return SizedBox(
    height: 108,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _quickAction(
          Icons.local_hospital_outlined,
          'Hospitals',
          _openHospitalSearch,
        ),

        _quickAction(
          Icons.medical_services_outlined,
          'Doctors',
          _openDoctorSearch,
        ),

        _quickAction(
          Icons.calendar_month_outlined,
          'Appointments',
          () {
            setState(() {
              selectedIndex = 1;
            });

            _loadAppointments();
          },
        ),

        _quickAction(
          Icons.folder_copy_outlined,
          'Records',
          () {
            setState(() {
              selectedIndex = 2;
            });
          },
        ),

        _quickAction(
          Icons.bed_rounded,
          'Bed Bookings',
          _openMyBedBookings,
        ),
      ],
    ),
  );
}

  Widget _quickAction(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF167C71),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UPCOMING APPOINTMENT
  // ============================================================

  Widget _buildUpcomingAppointment() {
    final upcoming = appointments.where((appointment) {
      return appointment['status'] == 'Upcoming';
    }).toList();

    if (appointmentsLoading) {
      return _appointmentLoadingCard();
    }

    if (upcoming.isEmpty) {
      return _emptyUpcomingAppointment();
    }

    return _buildAppointmentCard(
      upcoming.first,
      compact: true,
    );
  }

  Widget _appointmentLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF35AFA0),
        ),
      ),
    );
  }

  Widget _emptyUpcomingAppointment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD8F3EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 30,
              color: Color(0xFF167C71),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Book an appointment with a doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: _openDoctorSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF35AFA0),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Find a Doctor',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPOINTMENT CARD
  // ============================================================

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment, {
    bool compact = false,
  }) {
    final doctorName =
        appointment['doctorName']?.toString() ??
            'Doctor';

    final specialization =
        appointment['specialization']?.toString() ??
            'Specialist';

    final hospitalName =
        appointment['hospitalName']?.toString() ??
            'Hospital';

    final date =
        appointment['date']?.toString() ?? '';

    final time =
        appointment['time']?.toString() ?? '';

    final fee =
        appointment['fee']?.toString() ?? '';

    final status =
        appointment['status']?.toString() ??
            'Upcoming';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EEFF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF3567B8),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      specialization,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Color(0xFF167C71),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  date.isEmpty
                      ? 'Date not available'
                      : date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Color(0xFF167C71),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  time.isEmpty
                      ? 'Time not available'
                      : time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF167C71),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  hospitalName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          if (fee.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 18,
                  color: Color(0xFF167C71),
                ),
                const SizedBox(width: 8),
                Text(
                  'Consultation fee: ₹$fee',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          if (!compact && status == 'Upcoming') ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  _confirmCancelAppointment(
                    appointment,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel Appointment',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isUpcoming = status == 'Upcoming';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isUpcoming
            ? const Color(0xFFDFF6EA)
            : const Color(0xFFFFE4E4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: isUpcoming
              ? const Color(0xFF167C55)
              : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRM CANCEL
  // ============================================================

  void _confirmCancelAppointment(
    Map<String, dynamic> appointment,
  ) {
    final doctorName =
        appointment['doctorName']?.toString() ??
            'this doctor';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Appointment?',
          ),
          content: Text(
            'Are you sure you want to cancel your appointment with $doctorName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final id =
                    appointment['id']?.toString();

                if (id == null) return;

                await LocalStorageService
                    .cancelAppointment(id);

                await _loadAppointments();

                if (!mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Appointment cancelled.',
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HOSPITAL
  // ============================================================

  Widget _buildHospitalCard({
    required String hospitalName,
    required String location,
    required String rating,
    required String distance,
    required String beds,
  }) {
    return GestureDetector(
      onTap: _openHospitalSearch,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 38,
                color: Color(0xFF35AFA0),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    hospitalName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                      ),

                      const SizedBox(width: 3),

                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        distance,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    beds,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF167C71),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LIVE BED AVAILABILITY
  // ============================================================

  Widget _buildBedAvailabilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF163F3B),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bed_rounded,
                color: Colors.white,
              ),

              SizedBox(width: 9),

              Text(
                'Real-Time Bed Availability',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Updated just now',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.65,
              ),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _bedItem(
                  'General',
                  '18',
                  'Available',
                ),
              ),

              Expanded(
                child: _bedItem(
                  'ICU',
                  '6',
                  'Available',
                ),
              ),

              Expanded(
                child: _bedItem(
                  'Emergency',
                  '4',
                  'Available',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: _openHospitalSearch,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.4,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'View Live Bed Status',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bedItem(
    String type,
    String number,
    String status,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          type,
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.85,
            ),
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          status,
          style: const TextStyle(
            color: Color(0xFF82E2B9),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI
  // ============================================================

  Widget _buildAiCard() {
    return GestureDetector(
      onTap: () {
        _showComingSoon(
          'HealthSync AI Assistant',
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD8F3EF),
              Color(0xFFEAF8F5),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF35AFA0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask HealthSync AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Find verified hospitals, doctors '
                    'and healthcare services.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APPOINTMENTS TAB
  // ============================================================

  Widget _buildAppointments() {
    return RefreshIndicator(
      color: const Color(0xFF35AFA0),
      onRefresh: _loadAppointments,
      child: appointmentsLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF35AFA0),
              ),
            )
          : appointments.isEmpty
              ? _buildEmptyAppointments()
              : ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    100,
                  ),
                  children: [
                    const Text(
                      'My Appointments',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Manage your doctor appointments',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 22),

                    ...appointments.map(
                      (appointment) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),
                          child: _buildAppointmentCard(
                            appointment,
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyAppointments() {
    return RefreshIndicator(
      color: const Color(0xFF35AFA0),
      onRefresh: _loadAppointments,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                    0.28,
          ),

          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3EF),
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 45,
                color: Color(0xFF167C71),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Center(
            child: Text(
              'No Appointments Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Text(
                'Book an appointment with a doctor and it will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: ElevatedButton(
              onPressed: _openDoctorSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF35AFA0),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Find a Doctor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECORDS
  // ============================================================





  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile() {
    return _simplePage(
      Icons.person_rounded,
      'My Profile',
      'Manage your HealthSync profile.',
    );
  }

  // ============================================================
  // SIMPLE PAGE
  // ============================================================

  Widget _simplePage(
    IconData icon,
    String title,
    String subtitle,
  ) {
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
                    BorderRadius.circular(28),
              ),
              child: Icon(
                icon,
                size: 42,
                color: const Color(0xFF167C71),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              subtitle,
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

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openHospitalSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HospitalSearchScreen(),
      ),
    );
  }

  void _openDoctorSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const DoctorSearchScreen(),
      ),
    );
  }
  void _openMyBedBookings() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MyBedBookingsScreen(),
    ),
  );
}

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected next.',
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}