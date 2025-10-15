import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusSchedulePage extends StatefulWidget {
  @override
  _BusSchedulePageState createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedDay = "Sunday-Thursday";

  @override
  void initState() {
    super.initState();
    selectedDay = _getDayCategory();
  }

  String _getDayCategory() {
    String day = DateFormat('EEEE').format(DateTime.now());
    if (day == 'Friday') return 'Friday';
    if (day == 'Saturday') return 'Saturday';
    return 'Sunday-Thursday';
  }

  List<String> _splitTimes(String? timeString) {
    if (timeString == null || timeString.isEmpty) return [];
    return timeString.split(',').map((e) => e.trim()).toList();
  }

  String? _getNextBusTime(List<String> times) {
    DateTime now = DateTime.now();
    for (String time in times) {
      try {
        DateTime busTime = DateFormat('h:mma').parse(time.toUpperCase());
        DateTime todayBus = DateTime(
          now.year,
          now.month,
          now.day,
          busTime.hour,
          busTime.minute,
        );
        if (todayBus.isAfter(now)) return time;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'LU Bus Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Day Selector Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dayButton("Friday"),
                const SizedBox(width: 10),
                _dayButton("Saturday"),
                const SizedBox(width: 10),
                _dayButton("Sunday-Thursday"),
              ],
            ),
          ),

          // 🔹 Bus Schedule List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('bus_schedule').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No schedule available.'));
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];
                    String routeName = data['route'] ?? 'Unknown Route';
                    String stoppages = data['stoppages'] ?? '';

                    Map<String, dynamic> startMap =
                        Map<String, dynamic>.from(data['startTimes'] ?? {});
                    Map<String, dynamic> returnMap =
                        Map<String, dynamic>.from(data['returnTimes'] ?? {});

                    List<String> startTimes =
                        _splitTimes(startMap[selectedDay]);
                    List<String> returnTimes =
                        _splitTimes(returnMap[selectedDay]);

                    String? nextStart = _getNextBusTime(startTimes);
                    String? nextReturn = _getNextBusTime(returnTimes);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00BFA6),
                            Color.fromARGB(255, 1, 149, 208)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_bus,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    routeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stoppages,
                              style: const TextStyle(
                                color: Color.fromARGB(253, 255, 255, 255),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const Divider(
                                color: Color.fromARGB(248, 255, 255, 255),
                                height: 22),

                            const Text(
                              'Start Times',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: startTimes.map((time) {
                                bool isNext = time == nextStart;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isNext
                                        ? Colors.deepOrangeAccent
                                        : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      color: isNext
                                          ? Colors.white
                                          : Colors.teal.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Return Times',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: returnTimes.map((time) {
                                bool isNext = time == nextReturn;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isNext
                                        ? Colors.deepOrangeAccent
                                        : Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      color: isNext
                                          ? Colors.white
                                          : Colors.teal.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled,
                                      color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      nextStart != null || nextReturn != null
                                          ? "Next Start: ${nextStart ?? '-'}   |   Next Return: ${nextReturn ?? '-'}"
                                          : "No more buses today",
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Button Widget
  Widget _dayButton(String label) {
    bool isSelected = selectedDay == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedDay = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
