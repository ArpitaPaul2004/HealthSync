import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends State<DoctorAppointmentsScreen> {
  final List<Map<String, String>> appointments = [
    {
      'patient': 'Sohan Das',
      'date': '05 Sep 2026',
      'time': '10:00 AM',
      'reason': 'General Checkup',
      'status': 'Pending',
    },
    {
      'patient': 'Soham Kundu',
      'date': '05 Sep 2026',
      'time': '11:30 AM',
      'reason': 'Follow-up',
      'status': 'Accepted',
    },
    {
      'patient': 'Augnik Ganguly',
      'date': '06 Sep 2026',
      'time': '02:00 PM',
      'reason': 'Fever and Cold',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments'),
        centerTitle: true,
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text(
                'No appointments found',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _appointmentCard(
                  appointments[index],
                  index,
                );
              },
            ),
    );
  }

  Widget _appointmentCard(
    Map<String, String> appointment,
    int index,
  ) {
    final status = appointment['status']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['patient']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['reason']!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(appointment['date']!),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(appointment['time']!),
              ],
            ),

            const SizedBox(height: 16),

            if (status == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _rejectAppointment(index);
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _acceptAppointment(index);
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),

            if (status == 'Accepted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _completeAppointment(index);
                  },
                  child: const Text('Mark Completed'),
                ),
              ),

            if (status == 'Completed')
              const Center(
                child: Text(
                  'Appointment Completed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _acceptAppointment(int index) {
    setState(() {
      appointments[index]['status'] = 'Accepted';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment accepted'),
      ),
    );
  }

  void _rejectAppointment(int index) {
    setState(() {
      appointments[index]['status'] = 'Rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment rejected'),
      ),
    );
  }

  void _completeAppointment(int index) {
    setState(() {
      appointments[index]['status'] = 'Completed';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment completed'),
      ),
    );
  }
}