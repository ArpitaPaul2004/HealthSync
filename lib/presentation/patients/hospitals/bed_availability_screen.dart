import 'package:flutter/material.dart';

import '../../../core/storage/local_storage_service.dart';
import 'my_bed_bookings_screen.dart';

class BedAvailabilityScreen extends StatefulWidget {
  const BedAvailabilityScreen({
    super.key,
    this.hospitalName = 'CityCare Hospital',
  });

  final String hospitalName;

  @override
  State<BedAvailabilityScreen> createState() =>
      _BedAvailabilityScreenState();
}

class _BedAvailabilityScreenState
    extends State<BedAvailabilityScreen> {
  final List<Map<String, dynamic>> bedTypes = [
    {
      'name': 'General Ward',
      'icon': Icons.bed_rounded,
      'available': 12,
      'occupied': 28,
      'total': 40,
      'price': '₹1,500/day',
    },
    {
      'name': 'ICU',
      'icon': Icons.monitor_heart_rounded,
      'available': 3,
      'occupied': 17,
      'total': 20,
      'price': '₹5,000/day',
    },
    {
      'name': 'Emergency',
      'icon': Icons.emergency_rounded,
      'available': 5,
      'occupied': 10,
      'total': 15,
      'price': '₹3,000/day',
    },
    {
      'name': 'Private Ward',
      'icon': Icons.hotel_rounded,
      'available': 8,
      'occupied': 12,
      'total': 20,
      'price': '₹3,500/day',
    },
  ];

  int get totalBeds {
    return bedTypes.fold(
      0,
      (sum, bed) => sum + (bed['total'] as int),
    );
  }

  int get totalAvailable {
    return bedTypes.fold(
      0,
      (sum, bed) => sum + (bed['available'] as int),
    );
  }

  int get totalOccupied {
    return bedTypes.fold(
      0,
      (sum, bed) => sum + (bed['occupied'] as int),
    );
  }

  // ------------------------------------------------------------
  // OPEN BOOKING SHEET
  // ------------------------------------------------------------

  void _openBookingSheet(
    Map<String, dynamic> bed,
  ) {
    if (bed['available'] <= 0) {
      _showMessage(
        'No beds available in this ward.',
      );
      return;
    }

    final nameController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final ageController =
        TextEditingController();

    String selectedGender = 'Male';
    int selectedDays = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book a Bed',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${widget.hospitalName} • ${bed['name']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _field(
                      controller:
                          nameController,
                      label: 'Patient Name',
                      icon:
                          Icons.person_outline,
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller:
                          phoneController,
                      label: 'Phone Number',
                      icon:
                          Icons.phone_outlined,
                      keyboardType:
                          TextInputType.phone,
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller:
                          ageController,
                      label: 'Age',
                      icon:
                          Icons.cake_outlined,
                      keyboardType:
                          TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _genderOption(
                          'Male',
                          selectedGender,
                          (value) {
                            setSheetState(() {
                              selectedGender =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(width: 8),

                        _genderOption(
                          'Female',
                          selectedGender,
                          (value) {
                            setSheetState(() {
                              selectedGender =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(width: 8),

                        _genderOption(
                          'Other',
                          selectedGender,
                          (value) {
                            setSheetState(() {
                              selectedGender =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Required stay',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF8FAFC,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color:
                              const Color(
                            0xFFE2E8F0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .calendar_today_outlined,
                            size: 20,
                            color:
                                Color(
                              0xFF2563EB,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Text(
                            '$selectedDays day'
                            '${selectedDays == 1 ? '' : 's'}',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed:
                                selectedDays > 1
                                    ? () {
                                        setSheetState(
                                          () {
                                            selectedDays--;
                                          },
                                        );
                                      }
                                    : null,
                            icon:
                                const Icon(
                              Icons
                                  .remove_circle_outline,
                            ),
                          ),

                          Text(
                            '$selectedDays',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedDays++;
                              });
                            },
                            icon:
                                const Icon(
                              Icons
                                  .add_circle_outline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFEFF6FF,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .payments_outlined,
                            color:
                                Color(
                              0xFF2563EB,
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Estimated cost',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            _calculatePrice(
                              bed['name'],
                              selectedDays,
                            ),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w800,
                              fontSize: 16,
                              color:
                                  Color(
                                0xFF2563EB,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed: () {
                          if (nameController
                                  .text
                                  .trim()
                                  .isEmpty ||
                              phoneController
                                  .text
                                  .trim()
                                  .isEmpty ||
                              ageController
                                  .text
                                  .trim()
                                  .isEmpty) {
                            _showMessage(
                              'Please fill all patient details.',
                            );
                            return;
                          }

                          Navigator.pop(
                            sheetContext,
                          );

                          _saveAndShowBookingConfirmation(
                            patientName:
                                nameController
                                    .text
                                    .trim(),
                            phone:
                                phoneController
                                    .text
                                    .trim(),
                            age:
                                ageController
                                    .text
                                    .trim(),
                            gender:
                                selectedGender,
                            bedType:
                                bed['name'],
                            days:
                                selectedDays,
                          );
                        },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors
                                  .teal
                                  .shade700,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Continue to Confirm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w700,
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
      },
    );
  }

  // ------------------------------------------------------------
  // CALCULATE PRICE
  // ------------------------------------------------------------

  String _calculatePrice(
    String bedType,
    int days,
  ) {
    int pricePerDay;

    switch (bedType) {
      case 'ICU':
        pricePerDay = 5000;
        break;

      case 'Emergency':
        pricePerDay = 3000;
        break;

      case 'Private Ward':
        pricePerDay = 3500;
        break;

      default:
        pricePerDay = 1500;
    }

    return '₹${pricePerDay * days}/-';
  }

  // ------------------------------------------------------------
  // SAVE BOOKING
  // ------------------------------------------------------------

  Future<void>
      _saveAndShowBookingConfirmation({
    required String patientName,
    required String phone,
    required String age,
    required String gender,
    required String bedType,
    required int days,
  }) async {
    final bookingId =
        'HS${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final price = _calculatePrice(
      bedType,
      days,
    );

    await LocalStorageService.saveBedBooking(
      bookingId: bookingId,
      patientName: patientName,
      phone: phone,
      age: age,
      gender: gender,
      hospitalName:
          widget.hospitalName,
      bedType: bedType,
      days: days,
      price: price,
    );

    // Update local bed availability.
    final index = bedTypes.indexWhere(
      (bed) => bed['name'] == bedType,
    );

    if (index != -1 &&
        bedTypes[index]['available'] > 0) {
      setState(() {
        bedTypes[index]['available'] =
            bedTypes[index]['available'] - 1;

        bedTypes[index]['occupied'] =
            bedTypes[index]['occupied'] + 1;
      });
    }

    if (!mounted) return;

    await _showBookingConfirmation(
      bookingId: bookingId,
      patientName: patientName,
      phone: phone,
      age: age,
      gender: gender,
      bedType: bedType,
      days: days,
      price: price,
    );
  }

  // ------------------------------------------------------------
  // BOOKING CONFIRMATION
  // ------------------------------------------------------------

  Future<void> _showBookingConfirmation({
    required String bookingId,
    required String patientName,
    required String phone,
    required String age,
    required String gender,
    required String bedType,
    required int days,
    required String price,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Booking Confirmed',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _bookingRow(
                  'Booking ID',
                  bookingId,
                ),

                _bookingRow(
                  'Patient',
                  patientName,
                ),

                _bookingRow(
                  'Hospital',
                  widget.hospitalName,
                ),

                _bookingRow(
                  'Bed Type',
                  bedType,
                ),

                _bookingRow(
                  'Stay',
                  '$days day${days == 1 ? '' : 's'}',
                ),

                _bookingRow(
                  'Contact',
                  phone,
                ),

                _bookingRow(
                  'Estimated Cost',
                  price,
                ),

                _bookingRow(
                  'Status',
                  'Pending Admission',
                ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF0FDF4,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    'Your bed booking has been saved. '
                    'You can view or cancel it from My Bed Bookings.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color:
                          Color(0xFF166534),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Please carry a valid ID and required medical documents when visiting the hospital.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MyBedBookingsScreen(),
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.teal.shade700,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'View My Booking',
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BOOKING ROW
  // ------------------------------------------------------------

  Widget _bookingRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
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
                color:
                    Color(0xFF64748B),
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration:
          InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
            const Color(0xFFF8FAFC),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // GENDER OPTION
  // ------------------------------------------------------------

  Widget _genderOption(
    String gender,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final isSelected =
        gender == selected;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            onChanged(gender),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration:
              BoxDecoration(
            color: isSelected
                ? const Color(
                    0xFFE0F2FE,
                  )
                : const Color(
                    0xFFF8FAFC,
                  ),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(
                      0xFF2563EB,
                    )
                  : const Color(
                      0xFFE2E8F0,
                    ),
            ),
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: isSelected
                    ? const Color(
                        0xFF2563EB,
                      )
                    : const Color(
                        0xFF475569,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalBeds == 0
            ? 0.0
            : totalAvailable / totalBeds;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(0xFF172033),
        elevation: 0,

        title: const Text(
          'Bed Availability',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip:
                'My Bed Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyBedBookingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons
                  .assignment_turned_in_outlined,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          _buildHospitalHeader(),

          const SizedBox(height: 16),

          _buildOverallAvailability(
            percentage,
          ),

          const SizedBox(height: 20),

          const Text(
            'Available Bed Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Select a bed type to make a booking.',
            style: TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

          ...bedTypes.map(
            (bed) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  _buildBedCard(bed),
            ),
          ),

          const SizedBox(height: 10),

          _buildLiveStatus(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HOSPITAL HEADER
  // ------------------------------------------------------------

  Widget _buildHospitalHeader() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFE0F2F1),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child: Icon(
              Icons
                  .local_hospital_rounded,
              color:
                  Colors.teal.shade700,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  widget.hospitalName,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 5),

                const Row(
                  children: [
                    Icon(
                      Icons
                          .location_on_outlined,
                      size: 15,
                      color:
                          Color(0xFF64748B),
                    ),

                    SizedBox(width: 4),

                    Text(
                      'Bhubaneswar, Odisha',
                      style:
                          TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // OVERALL AVAILABILITY
  // ------------------------------------------------------------

  Widget _buildOverallAvailability(
    double percentage,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color:
            Colors.teal.shade700,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Availability',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(width: 8),

              const Padding(
                padding:
                    EdgeInsets.only(
                  bottom: 7,
                ),
                child: Text(
                  'available',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              backgroundColor:
                  Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Available',
                  '$totalAvailable',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Occupied',
                  '$totalOccupied',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Total',
                  '$totalBeds',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUMMARY ITEM
  // ------------------------------------------------------------

  Widget _summaryItem(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BED CARD
  // ------------------------------------------------------------

  Widget _buildBedCard(
    Map<String, dynamic> bed,
  ) {
    final int available =
        bed['available'] as int;

    final int total =
        bed['total'] as int;

    final int occupied =
        bed['occupied'] as int;

    final percentage =
        total == 0
            ? 0.0
            : available / total;

    final Color statusColor =
        percentage >= 0.30
            ? const Color(0xFF16A34A)
            : percentage >= 0.15
                ? const Color(0xFFF59E0B)
                : const Color(0xFFDC2626);

    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE0F2F1,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  bed['icon'] as IconData,
                  color:
                      Colors.teal.shade700,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      bed['name']
                          as String,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFF172033,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 4),

                    Text(
                      '$available beds available',
                      style:
                          TextStyle(
                        fontSize: 12,
                        color:
                            statusColor,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$available/$total',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172033),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              value: percentage,
              minHeight: 7,
              backgroundColor:
                  const Color(
                0xFFE5E7EB,
              ),
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                statusColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                bed['price'] as String,
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF64748B),
                ),
              ),

              const Spacer(),

              Text(
                '$occupied occupied',
                style:
                    const TextStyle(
                  fontSize: 11,
                  color:
                      Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width:
                double.infinity,
            height: 46,
            child:
                ElevatedButton.icon(
              onPressed:
                  available > 0
                      ? () {
                          _openBookingSheet(
                            bed,
                          );
                        }
                      : null,
              icon: const Icon(
                Icons
                    .event_available_rounded,
                size: 19,
              ),
              label: Text(
                available > 0
                    ? 'Book This Bed'
                    : 'No Beds Available',
              ),
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors
                        .teal
                        .shade700,
                foregroundColor:
                    Colors.white,
                disabledBackgroundColor:
                    Colors
                        .grey
                        .shade300,
                disabledForegroundColor:
                    Colors
                        .grey
                        .shade600,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LIVE STATUS
  // ------------------------------------------------------------

  Widget _buildLiveStatus() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF0FDF4),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFBBF7D0),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color:
                Color(0xFF16A34A),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Bed information is currently local demo data. '
              'Real-time availability and booking will be connected '
              'to the backend later.',
              style:
                  TextStyle(
                fontSize: 12,
                height: 1.4,
                color:
                    Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }
}