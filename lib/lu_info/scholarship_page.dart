import 'package:flutter/material.dart';

class ScholarshipPage extends StatelessWidget {
  const ScholarshipPage({super.key});

  // Static data (based on Leading University - Scholarship & Aid page)
  static const List<Map<String, dynamic>> scholarshipItems = [
    {
      "title": "Golden GPA Scholarships",
      "summary": "Special tuition waivers for top board results",
      "details": [
        {"label": "Golden GPA 5.00 (both SSC & HSC)", "value": "60% tuition waiver"},
        {"label": "GPA 5.00 (one of SSC/HSC)", "value": "45% tuition waiver"},
        {"label": "GPA 5.00 (both)", "value": "40% tuition waiver"},
        {"label": "GPA 4.50 (both SSC & HSC)", "value": "25% tuition waiver"},
        {"label": "GPA 4.00 (both SSC & HSC)", "value": "15% tuition waiver"},
        {"label": "GPA 3.50 (both SSC & HSC)", "value": "10% tuition waiver"},
      ]
    },
    {
      "title": "Special Waivers & Concessions",
      "summary": "Other standard waivers available",
      "details": [
        {"label": "Female Students", "value": "10% tuition waiver"},
        {"label": "Second child of same parents (provisional)", "value": "30% tuition waiver"},
        {"label": "Freedom Fighter's children", "value": "Waiver (see forms)"},
        {"label": "Board Scholarships", "value": "As per board notices—check Notice Board"},
      ]
    },
    {
      "title": "How to Apply / Forms",
      "summary": "Forms & documentation required",
      "details": [
        {"label": "Board Scholarship Form", "value": "Download from Official Forms page"},
        {"label": "Sibling / Tuition Waiver Form", "value": "Apply with required documents"},
        {"label": "Other forms", "value": "See 'Useful Forms' on LU site"},
      ]
    },
    {
      "title": "Notes & Important",
      "summary": "Important reminders",
      "details": [
        {"label": "Source", "value": "Leading University official Scholarship & Aid page"},
        {"label": "Verification", "value": "University may ask for original certificates"},
        {"label": "Updates", "value": "Check official notice board for latest circulars"},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship & Aid'),
        backgroundColor: const Color.fromARGB(255, 25, 125, 192),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe6f2ff), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // header card with short intro
              _headerCard(context),
              const SizedBox(height: 16),
              // list of scholarship categories
              ...scholarshipItems.map((cat) => _buildCategoryCard(cat)).toList(),
              const SizedBox(height: 20),
              _sourceCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3C5D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Scholarship & Aid",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Tuition waiver categories and how to apply. For verification and latest circulars check official LU notices.",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final List details = cat['details'] as List;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          collapsedIconColor: const Color(0xFF0B3C5D),
          iconColor: const Color(0xFF0B3C5D),
          title: Text(
            cat['title'] as String,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(cat['summary'] as String),
          children: details.map((d) {
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: const Icon(Icons.arrow_right_rounded, color: Color(0xFF0B3C5D)),
              title: Text(d['label'] as String),
              trailing: Text(
                d['value'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sourceCard() {
    return Card(
      color: Colors.white70,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Source", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "Information summarized from Leading University (Scholarship & Aid) and official notices. Check official LU website/forms for downloadable application forms and exact conditions.",
            ),
          ],
        ),
      ),
    );
  }
}
