import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  final patientController = TextEditingController();
  final reportTitleController = TextEditingController();

  String? selectedFilePath;
  String? selectedFileName;
  bool isUploading = false;

  Future<void> _pickReport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result.isNotEmpty && result.single.path != null) {
      setState(() {
        selectedFilePath = result.single.path;
        selectedFileName = result.single.name;
      });
    }
  }

  Future<void> _uploadReport() async {
    final patientName = patientController.text.trim();
    final reportTitle = reportTitleController.text.trim();

    if (patientName.isEmpty) {
      _showMessage('Please enter patient name');
      return;
    }

    if (reportTitle.isEmpty) {
      _showMessage('Please enter report title');
      return;
    }

    if (selectedFilePath == null) {
      _showMessage('Please select a report file');
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final file = File(selectedFilePath!);

      if (!await file.exists()) {
        _showMessage('Selected file could not be found');
        setState(() {
          isUploading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      final reports = prefs.getStringList('doctor_reports') ?? [];

      final reportData =
          '$patientName|||$reportTitle|||$selectedFileName|||$selectedFilePath|||${DateTime.now().toIso8601String()}';

      reports.add(reportData);

      await prefs.setStringList(
        'doctor_reports',
        reports,
      );

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      patientController.clear();
      reportTitleController.clear();

      setState(() {
        selectedFilePath = null;
        selectedFileName = null;
      });

      _showMessage('Report uploaded successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      _showMessage('Failed to upload report');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    patientController.dispose();
    reportTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Patient Report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Upload a medical report for a patient.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: patientController,
              decoration: InputDecoration(
                labelText: 'Patient Name',
                hintText: 'Enter patient name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: reportTitleController,
              decoration: InputDecoration(
                labelText: 'Report Title',
                hintText: 'e.g. Blood Test Report',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 55,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Select Report File',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'PDF, JPG, JPEG or PNG',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 15),

                  OutlinedButton.icon(
                    onPressed: _pickReport,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choose File'),
                  ),

                  if (selectedFileName != null) ...[
                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFileName!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : _uploadReport,
                icon: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  isUploading
                      ? 'Uploading...'
                      : 'Upload Report',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}