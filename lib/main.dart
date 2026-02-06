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

// 受験日入力画面
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalityTestScreen(
                        examDate: DateTime(selectedYear, selectedMonth, selectedDay),
                      ),
                    ),
                  );
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

// 性格診断画面
class PersonalityTestScreen extends StatefulWidget {
  final DateTime examDate;
  const PersonalityTestScreen({super.key, required this.examDate});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  int currentQuestion = 0;
  final Map<String, String> answers = {};

  final List<Map<String, dynamic>> questions = [
    {'question': '朝と夜、どちらが集中できる？', 'options': ['朝型', '夜型'], 'key': 'timePreference'},
    {'question': '学習スタイルは？', 'options': ['短期集中', 'コツコツ'], 'key': 'studyStyle'},
    {'question': '平日の学習時間は？', 'options': ['15分以下', '30分', '1時間以上'], 'key': 'weekdayTime'},
    {'question': '週末の学習時間は？', 'options': ['30分以下', '1時間', '2時間以上'], 'key': 'weekendTime'},
    {'question': '一番忙しい曜日は？', 'options': ['月・火', '水・木', '金・土', '日'], 'key': 'busyDay'},
  ];

  void _selectOption(String option) {
    setState(() {
      answers[questions[currentQuestion]['key']] = option;
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelTestScreen(
              examDate: widget.examDate,
              personality: answers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 40),
            Text('質問 ${currentQuestion + 1}/${questions.length}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Text(question['question'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ...List.generate((question['options'] as List<String>).length, (index) {
              final option = (question['options'] as List<String>)[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectOption(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// レベル診断画面
class LevelTestScreen extends StatefulWidget {
  final DateTime examDate;
  final Map<String, String> personality;
  const LevelTestScreen({super.key, required this.examDate, required this.personality});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  int currentQuestion = 0;
  int correctCount = 0;

  final List<Map<String, dynamic>> questions = [
    {'question': 'She ___ to the office every day.', 'options': ['go', 'goes', 'going', 'gone'], 'answer': 'goes'},
    {'question': 'I have ___ finished my homework.', 'options': ['yet', 'already', 'still', 'soon'], 'answer': 'already'},
    {'question': 'The meeting will be held ___ Monday.', 'options': ['in', 'at', 'on', 'by'], 'answer': 'on'},
  ];

  void _selectAnswer(String answer) {
    if (answer == questions[currentQuestion]['answer']) {
      correctCount++;
    }
    
    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    final score = (correctCount / questions.length * 100).round();
    String level = score >= 70 ? '上級' : score >= 40 ? '中級' : '初級';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('診断完了'),
        content: Text('正解率: $score%\nレベル: $level'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 山道画面へ
            },
            child: const Text('開始'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('レベル診断', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 40),
            Text('問題 ${currentQuestion + 1}/${questions.length}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Text(question['question'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ...List.generate((question['options'] as List<String>).length, (index) {
              final option = (question['options'] as List<String>)[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}