import 'package:flutter/material.dart';


class CgpaCalculatorPage extends StatefulWidget {
  const CgpaCalculatorPage({super.key});

  @override
  State<CgpaCalculatorPage> createState() => _CgpaCalculatorPageState();
}

class _CgpaCalculatorPageState extends State<CgpaCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final List<_CourseEntry> _courses = [_CourseEntry()];

  static const Map<String, double> gradePoints = {
    'A+': 4.00,
    'A': 3.75,
    'A-': 3.50,
    'B+': 3.25,
    'B': 3.00,
    'B-': 2.75,
    'C+': 2.50,
    'C': 2.25,
    'D': 2.00,
    'F': 0.00,
  };

  double _cgpa = 0.0;
  double _totalCredits = 0.0;

  void _addCourse() {
    setState(() => _courses.add(_CourseEntry()));
  }

  void _removeCourse(int index) {
    setState(() => _courses.removeAt(index));
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    double totalWeighted = 0.0;
    double credits = 0.0;

    for (final c in _courses) {
      final gradePoint = gradePoints[c.selectedGrade]!;
      final credit = double.tryParse(c.creditController.text.trim()) ?? 0.0;
      totalWeighted += gradePoint * credit;
      credits += credit;
    }

    setState(() {
      _cgpa = credits > 0 ? totalWeighted / credits : 0.0;
      _totalCredits = credits;
    });
  }

  Color _cgpaColor(double gpa) {
    if (gpa >= 3.75) return Colors.green;
    if (gpa >= 3.25) return Colors.lightBlue;
    if (gpa >= 3.0) return Colors.orange;
    if (gpa >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _remarks(double gpa) {
    if (gpa >= 3.75) return 'Excellent';
    if (gpa >= 3.25) return 'Very Good';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.0) return 'Pass';
    return 'Fail';
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CGPA Calculator"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        label: const Text("Add Course"),
        icon: const Icon(Icons.add),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            Card(
              color: _cgpaColor(_cgpa),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your CGPA",
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _cgpa.toStringAsFixed(3),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _remarks(_cgpa),
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Credits: ${_totalCredits.toStringAsFixed(1)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),


            ..._courses.asMap().entries.map((entry) {
              final i = entry.key;
              final course = entry.value;
              return _CourseCard(
                index: i,
                course: course,
                decorationBuilder: _inputDecoration,
                onRemove: () => _removeCourse(i),
              );
            }),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text("Calculate CGPA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Formula: CGPA = Σ(Grade Point × Credit) ÷ Σ(Credit)",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final int index;
  final _CourseEntry course;
  final VoidCallback onRemove;
  final InputDecoration Function({required String label, required IconData icon})
      decorationBuilder;

  const _CourseCard({
    required this.index,
    required this.course,
    required this.onRemove,
    required this.decorationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text("Course ${index + 1}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color.fromARGB(255, 89, 196, 128)),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                )
              ],
            ),
            TextFormField(
              controller: course.titleController,
              textInputAction: TextInputAction.next,
              decoration: decorationBuilder(label: "Course Title (optional)", icon: Icons.book_rounded),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Grade
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: course.selectedGrade,
                    items: _CgpaCalculatorPageState.gradePoints.keys
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => course.selectedGrade = v ?? 'A',
                    decoration: decorationBuilder(label: "Grade", icon: Icons.grade_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                // Credit
                Expanded(
                  child: TextFormField(
                    controller: course.creditController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d = double.tryParse((v ?? "").trim());
                      if (d == null || d <= 0) return "Enter valid credit";
                      return null;
                    },
                    decoration: decorationBuilder(label: "Credit", icon: Icons.timelapse_rounded),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CourseEntry {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController creditController =
      TextEditingController(text: "3.0");
  String selectedGrade = 'A';
}