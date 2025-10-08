import 'package:flutter/material.dart';

class TuitionFeesPage extends StatelessWidget {
  const TuitionFeesPage({super.key});

  // Undergraduate Programs Data
  static const List<Map<String, String>> undergraduatePrograms = [
    {
      "program": "CSE (Computer Science & Engineering)",
      "tuition": "2,250 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "1,500 tk / semester",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 5,15,764 tk"
    },
    {
      "program": "EEE (Electrical & Electronic Engineering)",
      "tuition": "2,100 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "2,000 tk / semester",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 4,97,764 tk"
    },
    {
      "program": "Civil Engineering",
      "tuition": "2,415 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "2,700 tk / semester",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 5,66,224 tk"
    },
    {
      "program": "Architecture",
      "tuition": "2,550 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "2,000 tk / semester",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 7,01,164 tk"
    },
    {
      "program": "BBA (Business Administration)",
      "tuition": "2,500 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 4,90,264 tk"
    },
    {
      "program": "LLB (Law)",
      "tuition": "2,200 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "3,000 tk / semester",
      "transport": "5,250 tk / semester",
      "total": "Approx. 4,47,964 tk"
    },
    {
      "program": "English",
      "tuition": "1,900 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 4,03,764 tk"
    },
    {
      "program": "Islamic Studies",
      "tuition": "200 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 1,65,764 tk"
    },
    {
      "program": "BTHM (Tourism & Hospitality Management)",
      "tuition": "2,200 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 4,45,764 tk"
    },
    {
      "program": "Bangla",
      "tuition": "840 tk per credit",
      "admission": "22,000 tk (One-time)",
      "lab": "0 tk",
      "library": "500 tk / semester",
      "studentActivity": "2,000 tk / semester",
      "transport": "3,500 tk / semester",
      "total": "Approx. 2,04,880 tk"
    },
  ];

  // Masters Programs Data
  static const List<Map<String, String>> mastersPrograms = [
  {
    "program": "MBA (Master of Business Administration)",
    "tuition": "tk 1,600 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 0",
    "library": "tk 500 / semester",
    "studentActivity": "tk 4,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 50% for LU graduates",
    "total": "Approx. tk 1,36,600"
  },
  {
    "program": "MSc in CSE (Computer Science & Engineering)",
    "tuition": "tk 3,000 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 1,200 / semester",
    "library": "tk 500 / semester",
    "studentActivity": "tk 4,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 50% based on merit",
    "total": "Approx. tk 1,51,800"
  },
  {
    "program": "MSc in EEE (Electrical & Electronic Engineering)",
    "tuition": "tk 2,500 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 1,000 / semester",
    "library": "tk 500 / semester",
    "studentActivity": "tk 3,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 50% merit-based",
    "total": "Approx. tk 1,40,000"
  },
  {
    "program": "MSc in Civil Engineering",
    "tuition": "tk 2,600 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 1,500 / semester",
    "library": "tk 500 / semester",
    "studentActivity": "tk 3,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 40% merit-based",
    "total": "Approx. tk 1,48,000"
  },
  {
    "program": "MSc in Architecture",
    "tuition": "tk 2,800 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 1,000 / semester",
    "library": "tk 500 / semester",
    "studentActivity": "tk 4,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 40% based on portfolio & merit",
    "total": "Approx. tk 1,56,000"
  },
  {
    "program": "LLM (Master of Laws)",
    "tuition": "tk 2,000 per credit",
    "admission": "tk 10,000 (One-time)",
    "lab": "tk 0",
    "library": "tk 500 / semester",
    "studentActivity": "tk 3,000 / semester",
    "transport": "tk 3,000 / semester",
    "waiver": "Up to 50% merit-based",
    "total": "Approx. tk 1,25,000"
  },
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tuition Fees"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          children: [
            const Text(
              "Undergraduate Programs",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            ...undergraduatePrograms.map((item) => _buildProgramCard(item)).toList(),
            const SizedBox(height: 24),
            const Text(
              "Masters Programs",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
            ),
            const SizedBox(height: 12),
            ...mastersPrograms.map((item) => _buildProgramCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.lightBlueAccent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['program'] ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          _buildRow("Tuition / Credit", item['tuition']),
          _buildRow("Admission Fee", item['admission']),
          if ((item['lab'] ?? "").isNotEmpty) _buildRow("Lab Fee", item['lab']),
          if ((item['library'] ?? "").isNotEmpty) _buildRow("Library Fee", item['library']),
          _buildRow("Student Activity", item['studentActivity']),
          _buildRow("Transport Fee", item['transport']),
          _buildRow("Waiver Info", item['waiver']),
          _buildRow("Total Approx. Fee", item['total']),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 4,
              child: Text(
                value ?? "",
                style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black54),
                textAlign: TextAlign.end,
              )),
        ],
      ),
    );
  }
}
