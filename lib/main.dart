import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumo TOEIC',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const ExamDateScreen(),
    );
  }
}

class ExamDateScreen extends StatefulWidget {
  const ExamDateScreen({super.key});

  @override
  State<ExamDateScreen> createState() => _ExamDateScreenState();
}

class _ExamDateScreenState extends State<ExamDateScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TOEIC受験日を選択',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDropdown(
                    value: selectedYear,
                    items: List.generate(3, (i) => DateTime.now().year + i),
                    onChanged: (val) => setState(() => selectedYear = val!),
                    suffix: '年',
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown(
                    value: selectedMonth,
                    items: List.generate(12, (i) => i + 1),
                    onChanged: (val) => setState(() => selectedMonth = val!),
                    suffix: '月',
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown(
                    value: selectedDay,
                    items: List.generate(31, (i) => i + 1),
                    onChanged: (val) => setState(() => selectedDay = val!),
                    suffix: '日',
                  ),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  // TODO: 次の画面へ
                  print('選択: $selectedYear/$selectedMonth/$selectedDay');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('次へ', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        items: items.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text('$value$suffix'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}