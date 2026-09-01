import 'package:flutter/material.dart';
import 'bed_availability_screen.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() =>
      _HospitalSearchScreenState();
}

class _HospitalSearchScreenState
    extends State<HospitalSearchScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> hospitals = [
    {
      'name': 'CityCare Multispeciality Hospital',
      'location': 'Bhubaneswar, Odisha',
      'distance': '2.4 km',
      'rating': '4.7',
      'beds': 24,
      'emergency': true,
      'phone': '+91 674 000 0000',
      'departments': [
        'Cardiology',
        'Neurology',
        'Orthopedics',
        'General Medicine',
      ],
      'facilities': [
        '24/7 Emergency',
        'Pharmacy',
        'Laboratory',
        'Ambulance',
        'Blood Bank',
      ],
    },
    {
      'name': 'Apollo Health Centre',
      'location': 'Bhubaneswar, Odisha',
      'distance': '4.1 km',
      'rating': '4.6',
      'beds': 18,
      'emergency': true,
      'phone': '+91 674 111 1111',
      'departments': [
        'Cardiology',
        'General Medicine',
        'Pediatrics',
      ],
      'facilities': [
        '24/7 Emergency',
        'Pharmacy',
        'Laboratory',
        'ICU',
      ],
    },
    {
      'name': 'KIMS Hospital',
      'location': 'Bhubaneswar, Odisha',
      'distance': '5.2 km',
      'rating': '4.5',
      'beds': 31,
      'emergency': true,
      'phone': '+91 674 222 2222',
      'departments': [
        'Neurology',
        'Pediatrics',
        'Surgery',
        'Orthopedics',
      ],
      'facilities': [
        'Emergency',
        'Pharmacy',
        'MRI',
        'CT Scan',
        'Ambulance',
      ],
    },
    {
      'name': 'SUM Ultimate Medicare',
      'location': 'Bhubaneswar, Odisha',
      'distance': '7.0 km',
      'rating': '4.6',
      'beds': 25,
      'emergency': false,
      'phone': '+91 674 333 3333',
      'departments': [
        'Cardiology',
        'Oncology',
        'Orthopedics',
      ],
      'facilities': [
        'Pharmacy',
        'Laboratory',
        'ICU',
        'Ambulance',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_refreshSearch);
  }

  void _refreshSearch() {
    setState(() {});
  }

  @override
  void dispose() {
    searchController.removeListener(_refreshSearch);
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredHospitals {
    final query =
        searchController.text.trim().toLowerCase();

    return hospitals.where((hospital) {
      final name =
          hospital['name'].toString().toLowerCase();

      final location =
          hospital['location'].toString().toLowerCase();

      final departments =
          (hospital['departments'] as List)
              .join(' ')
              .toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          location.contains(query) ||
          departments.contains(query);

      bool matchesFilter = true;

      if (selectedFilter == 'Available Beds') {
        matchesFilter = hospital['beds'] > 0;
      } else if (selectedFilter == 'Emergency') {
        matchesFilter = hospital['emergency'] == true;
      } else if (selectedFilter == 'Top Rated') {
        matchesFilter =
            double.parse(hospital['rating']) >= 4.6;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Hospitals',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _filterOption('All'),
              _filterOption('Available Beds'),
              _filterOption('Emergency'),
              _filterOption('Top Rated'),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String filter) {
    return ListTile(
      title: Text(filter),
      leading: Radio<String>(
        value: filter,
        groupValue: selectedFilter,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            selectedFilter = value;
          });

          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });

        Navigator.pop(context);
      },
    );
  }

  void _openHospitalDetails(
    Map<String, dynamic> hospital,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalDetailsScreen(
          hospital: hospital,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredHospitals;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF9),
        elevation: 0,
        title: const Text(
          'Find Hospitals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search hospital or department',
                      prefixIcon:
                          const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
                                )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: _showFilterSheet,
                    icon: const Icon(
                      Icons.tune,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 52,
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                _chip('All'),
                _chip('Available Beds'),
                _chip('Emergency'),
                _chip('Top Rated'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              12,
            ),
            child: Row(
              children: [
                Text(
                  '${results.length} hospitals found',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                ),
                const SizedBox(width: 4),
                const Text('Nearby'),
              ],
            ),
          ),

          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    itemCount: results.length,
                    itemBuilder:
                        (context, index) {
                      return _hospitalCard(
                        results[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String filter) {
    final isSelected =
        selectedFilter == filter;

    return Padding(
      padding:
          const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        selectedColor:
            Colors.teal.shade100,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.teal.shade900
              : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _hospitalCard(
    Map<String, dynamic> hospital,
  ) {
    final int beds = hospital['beds'];

    return GestureDetector(
      onTap: () {
        _openHospitalDetails(hospital);
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color:
                        Colors.teal.shade50,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    size: 34,
                    color:
                        Colors.teal.shade700,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'],
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hospital['location'],
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 17,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hospital['rating'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.near_me_outlined,
                            size: 16,
                            color:
                                Colors.grey.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            hospital['distance'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.teal.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bed_outlined,
                          size: 18,
                          color:
                              Colors.teal.shade700,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '$beds beds available',
                          style: TextStyle(
                            color: Colors
                                .teal.shade800,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                if (hospital['emergency'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Text(
                      'Emergency',
                      style: TextStyle(
                        color:
                            Colors.red.shade700,
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 12,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            const Text(
              'No hospitals found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another hospital name or filter.',
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
// HOSPITAL DETAILS
// ============================================================

class HospitalDetailsScreen
    extends StatelessWidget {
  final Map<String, dynamic> hospital;

  const HospitalDetailsScreen({
    super.key,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    final departments =
        hospital['departments'] as List;

    final facilities =
        hospital['facilities'] as List;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7FAF9),
        elevation: 0,
        title:
            const Text('Hospital Details'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.local_hospital,
              size: 90,
              color: Colors.teal.shade700,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            hospital['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  hospital['location'],
                ),
              ),
              const Icon(
                Icons.star,
                size: 18,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                hospital['rating'],
                style:
                    const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _quickInfo(
                  Icons.bed_outlined,
                  '${hospital['beds']}',
                  'Beds',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickInfo(
                  Icons.near_me_outlined,
                  hospital['distance'],
                  'Distance',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickInfo(
                  Icons.star_outline,
                  hospital['rating'],
                  'Rating',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ==================================================
          // BED AVAILABILITY BUTTON
          // ==================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BedAvailabilityScreen(
                      hospitalName:
                          hospital['name'],
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.bed_rounded,
              ),
              label: const Text(
                'Check Bed Availability',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.teal.shade700,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // EMERGENCY
          // ==================================================

          Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  hospital['emergency'] == true
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  hospital['emergency'] == true
                      ? Icons.emergency
                      : Icons.info_outline,
                  color:
                      hospital['emergency'] == true
                          ? Colors.red
                          : Colors.grey.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['emergency'] == true
                            ? '24/7 Emergency Available'
                            : 'Emergency Service Unavailable',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital['phone'],
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // DEPARTMENTS
          // ==================================================

          const Text(
            'Departments',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                departments.map((department) {
              return Chip(
                avatar: const Icon(
                  Icons.medical_services_outlined,
                  size: 17,
                ),
                label:
                    Text(department.toString()),
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // FACILITIES
          // ==================================================

          const Text(
            'Facilities',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...facilities.map(
            (facility) {
              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color:
                          Colors.teal.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      facility.toString(),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // ==================================================
          // DOCTORS
          // ==================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Doctors',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showMessage(
                    context,
                    'Doctor list will be connected next.',
                  );
                },
                child:
                    const Text('View all'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _doctorPreview(
            context,
            'Dr. Priya Sharma',
            'Cardiologist',
            '4.8',
          ),

          const SizedBox(height: 10),

          _doctorPreview(
            context,
            'Dr. Rahul Mehta',
            'Neurologist',
            '4.7',
          ),

          const SizedBox(height: 30),

          // ==================================================
          // BOOK APPOINTMENT
          // ==================================================

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                _showMessage(
                  context,
                  'Appointment booking will be added next.',
                );
              },
              icon: const Icon(
                Icons.calendar_month,
              ),
              label: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // MAP
          // ==================================================

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {
                _showMessage(
                  context,
                  'Google Maps will be connected later.',
                );
              },
              icon: const Icon(
                Icons.map_outlined,
              ),
              label: const Text(
                'View on Map',
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _quickInfo(
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style:
                const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorPreview(
    BuildContext context,
    String name,
    String specialty,
    String rating,
  ) {
    return GestureDetector(
      onTap: () {
        _showMessage(
          context,
          '$name details will be connected next.',
        );
      },
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Colors.teal.shade50,
              child: Icon(
                Icons.person,
                size: 30,
                color:
                    Colors.teal.shade700,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 15,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}