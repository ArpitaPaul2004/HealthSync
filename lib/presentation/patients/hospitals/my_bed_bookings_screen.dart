import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';

class MyBedBookingsScreen extends StatefulWidget {
  const MyBedBookingsScreen({super.key});

  @override
  State<MyBedBookingsScreen> createState() =>
      _MyBedBookingsScreenState();
}

class _MyBedBookingsScreenState
    extends State<MyBedBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final savedBookings =
        await LocalStorageService.getBedBookings();

    if (!mounted) return;

    setState(() {
      bookings = savedBookings.reversed.toList();
      isLoading = false;
    });
  }

  Future<void> _cancelBooking(
    Map<String, dynamic> booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cancel Bed Booking?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this bed booking?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await LocalStorageService.cancelBedBooking(
      booking['bookingId'],
    );

    await _loadBookings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bed booking cancelled successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBookingDetails(
    Map<String, dynamic> booking,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            30,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 20),

                _detailRow(
                  'Booking ID',
                  booking['bookingId'],
                ),

                _detailRow(
                  'Patient',
                  booking['patientName'],
                ),

                _detailRow(
                  'Phone',
                  booking['phone'],
                ),

                _detailRow(
                  'Age',
                  booking['age'],
                ),

                _detailRow(
                  'Gender',
                  booking['gender'],
                ),

                _detailRow(
                  'Hospital',
                  booking['hospitalName'],
                ),

                _detailRow(
                  'Bed Type',
                  booking['bedType'],
                ),

                _detailRow(
                  'Stay',
                  '${booking['days']} day'
                      '${booking['days'] == 1 ? '' : 's'}',
                ),

                _detailRow(
                  'Estimated Cost',
                  booking['price'],
                ),

                _detailRow(
                  'Status',
                  booking['status'],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF172033),
        elevation: 0,
        title: const Text(
          'My Bed Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : bookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(
                        bookings[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
  ) {
    final bool cancelled =
        booking['status'] == 'Cancelled';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: cancelled
              ? Colors.red.shade100
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cancelled
                      ? Colors.red.shade50
                      : const Color(0xFFE0F2F1),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.bed_rounded,
                  color: cancelled
                      ? Colors.red
                      : Colors.teal.shade700,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['hospitalName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      booking['bedType'],
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.teal.shade700,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                booking['status'],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                _smallInfo(
                  Icons.confirmation_number_outlined,
                  'Booking ID',
                  booking['bookingId'],
                ),
                const SizedBox(height: 9),
                _smallInfo(
                  Icons.person_outline,
                  'Patient',
                  booking['patientName'],
                ),
                const SizedBox(height: 9),
                _smallInfo(
                  Icons.calendar_today_outlined,
                  'Stay',
                  '${booking['days']} day'
                      '${booking['days'] == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 9),
                _smallInfo(
                  Icons.payments_outlined,
                  'Estimated Cost',
                  booking['price'],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showBookingDetails(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'View Details',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.teal.shade700,
                    side: BorderSide(
                      color:
                          Colors.teal.shade200,
                    ),
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

              if (!cancelled) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _cancelBooking(
                        booking,
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Cancel',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red.shade50,
                      foregroundColor:
                          Colors.red.shade700,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(
    String status,
  ) {
    final bool cancelled =
        status == 'Cancelled';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cancelled
            ? Colors.red.shade50
            : Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cancelled
              ? Colors.red.shade700
              : Colors.orange.shade800,
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE0F2F1),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.bed_outlined,
                size: 45,
                color: Colors.teal.shade700,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Bed Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your bed bookings will appear here after you book a hospital bed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}