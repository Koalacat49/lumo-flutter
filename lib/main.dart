import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumo TOEIC',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// スプラッシュ画面（データ読み込み）
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc('default_user').get();
      if (!mounted) return;
      
      if (doc.exists && doc.data()?['hasData'] == true) {
        final data = doc.data()!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MountainPathScreen(
              examDate: DateTime.parse(data['examDate']),
              personality: Map<String, String>.from(data['personality'] ?? {}),
              level: data['level'] ?? 'beginner',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LevelDiagnosisWelcome()));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LevelDiagnosisWelcome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// レベル診断Welcome画面
class LevelDiagnosisWelcome extends StatelessWidget {
  const LevelDiagnosisWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('まず実力チェックをしよう', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  const Text('あなたのレベルに合った学習プランを作成するため、簡単な問題を出します。全8問です。', style: TextStyle(fontSize: 15, color: Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LevelDiagnosisQuiz())),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    child: const Text('診断を始める', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// レベル診断Quiz画面
class LevelDiagnosisQuiz extends StatefulWidget {
  const LevelDiagnosisQuiz({super.key});
  @override
  State<LevelDiagnosisQuiz> createState() => _LevelDiagnosisQuizState();
}

class _LevelDiagnosisQuizState extends State<LevelDiagnosisQuiz> {
  List<Map<String, dynamic>> questions = [];
  List<bool> answers = [];
  int currentIndex = 0;
  int? selected;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    // 各レベルから2問ずつ
    final levels = [
      {'name': '300', 'questions': [
        {'q': 'I ___ a student.', 'opts': ['am', 'is', 'are', 'be'], 'ans': 0},
        {'q': 'She ___ to school every day.', 'opts': ['go', 'goes', 'going', 'gone'], 'ans': 1},
      ]},
      {'name': '600', 'questions': [
        {'q': 'If I ___ rich, I would travel the world.', 'opts': ['am', 'was', 'were', 'be'], 'ans': 2},
        {'q': 'The meeting ___ at 3 PM yesterday.', 'opts': ['starts', 'started', 'will start', 'has started'], 'ans': 1},
      ]},
      {'name': '800', 'questions': [
        {'q': 'By the time you arrive, I ___ the report.', 'opts': ['finish', 'finished', 'will finish', 'will have finished'], 'ans': 3},
        {'q': '___ the circumstances, we decided to proceed.', 'opts': ['Despite', 'Although', 'However', 'Because'], 'ans': 0},
      ]},
      {'name': '900', 'questions': [
        {'q': 'The proposal was met with ___ from the board.', 'opts': ['skeptical', 'skepticism', 'skeptically', 'skeptic'], 'ans': 1},
        {'q': 'Had I known, I ___ differently.', 'opts': ['act', 'acted', 'would act', 'would have acted'], 'ans': 3},
      ]},
    ];
    for (var level in levels) {
      for (var q in (level['questions'] as List)) {
        questions.add({'question': q['q'], 'options': q['opts'], 'answer': q['ans'], 'levelName': level['name']});
      }
    }
  }

  void handleAnswer() {
    if (selected == null) return;
    final isCorrect = selected == questions[currentIndex]['answer'];
    setState(() {
      showAnswer = true;
      answers.add(isCorrect);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selected = null;
          showAnswer = false;
        });
      } else {
        final correctCount = answers.where((a) => a).length;
        final level = correctCount >= 7 ? 'advanced' : correctCount >= 4 ? 'intermediate' : 'beginner';
        final scoreLabel = correctCount >= 7 ? '800-900点レベル' : correctCount >= 4 ? '600-800点レベル' : '300-600点レベル';
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LevelDiagnosisResult(level: level, scoreLabel: scoreLabel)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text('実力チェック', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('問題 ${currentIndex + 1} / ${questions.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 12),
                  Text(q['question'], style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 16),
                  ...List.generate(q['options'].length, (idx) {
                    return GestureDetector(
                      onTap: showAnswer ? null : () => setState(() => selected = idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: selected == idx ? const Color(0xFF58CC02) : Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: showAnswer ? (idx == q['answer'] ? Colors.green.shade50 : selected == idx ? Colors.red.shade50 : Colors.white) : selected == idx ? Colors.grey.shade100 : Colors.white,
                        ),
                        child: Text(q['options'][idx], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ),
                    );
                  }),
                  if (showAnswer)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: selected == q['answer'] ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(selected == q['answer'] ? '正解' : '不正解', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (selected == null || showAnswer) ? null : handleAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (selected == null || showAnswer) ? Colors.grey : const Color(0xFF58CC02),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('回答する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// レベル診断Result画面
class LevelDiagnosisResult extends StatelessWidget {
  final String level;
  final String scoreLabel;
  const LevelDiagnosisResult({super.key, required this.level, required this.scoreLabel});

  @override
  Widget build(BuildContext context) {
    final labels = {'beginner': '初級', 'intermediate': '中級', 'advanced': '上級'};
    final colors = {'beginner': Colors.blue, 'intermediate': Colors.orange, 'advanced': Colors.purple};
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('診断結果', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  Text(scoreLabel, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors[level])),
                  const SizedBox(height: 8),
                  Text(labels[level]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PersonalityTest(level: level))),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                    child: const Text('次へ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 性格診断
class PersonalityTest extends StatefulWidget {
  final String level;
  const PersonalityTest({super.key, required this.level});
  @override
  State<PersonalityTest> createState() => _PersonalityTestState();
}

class _PersonalityTestState extends State<PersonalityTest> {
  int currentQuestion = 0;
  final Map<String, String> answers = {};
  final List<Map<String, dynamic>> questions = [
    {'q': '毎日決まった時間に勉強できる？', 'opts': ['できる', 'できない'], 'key': 'routine'},
    {'q': '一度に長時間集中できる？', 'opts': ['できる', 'できない'], 'key': 'focus'},
    {'q': 'ゲーム感覚で学ぶのが好き？', 'opts': ['好き', '苦手'], 'key': 'gamified'},
  ];

  void handleAnswer(String answer) {
    setState(() {
      answers[questions[currentQuestion]['key']] = answer;
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExamDateInput(personality: answers, level: widget.level)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('質問 ${currentQuestion + 1} / ${questions.length}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Text(q['q'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 24),
                  ...q['opts'].map<Widget>((opt) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => handleAnswer(opt),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 受験日入力
class ExamDateInput extends StatefulWidget {
  final Map<String, String> personality;
  final String level;
  const ExamDateInput({super.key, required this.personality, required this.level});
  @override
  State<ExamDateInput> createState() => _ExamDateInputState();
}

class _ExamDateInputState extends State<ExamDateInput> {
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
              const Text('TOEIC受験日を選択', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDropdown(value: selectedYear, items: List.generate(3, (i) => DateTime.now().year + i), onChanged: (val) => setState(() => selectedYear = val!), suffix: '年'),
                  const SizedBox(width: 16),
                  _buildDropdown(value: selectedMonth, items: List.generate(12, (i) => i + 1), onChanged: (val) => setState(() => selectedMonth = val!), suffix: '月'),
                  const SizedBox(width: 16),
                  _buildDropdown(value: selectedDay, items: List.generate(31, (i) => i + 1), onChanged: (val) => setState(() => selectedDay = val!), suffix: '日'),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  final examDate = DateTime(selectedYear, selectedMonth, selectedDay);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MountainPathScreen(examDate: examDate, personality: widget.personality, level: widget.level)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
                child: const Text('冒険を開始！', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required int value, required List<int> items, required ValueChanged<int?> onChanged, required String suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButton<int>(value: value, underline: const SizedBox(), items: items.map((int value) => DropdownMenuItem<int>(value: value, child: Text('$value$suffix'))).toList(), onChanged: onChanged),
    );
  }
}

// 山道画面（メイン）
class MountainPathScreen extends StatefulWidget {
  final DateTime examDate;
  final Map<String, String> personality;
  final String level;
  const MountainPathScreen({super.key, required this.examDate, required this.personality, required this.level});
  @override
  State<MountainPathScreen> createState() => _MountainPathScreenState();
}

class _MountainPathScreenState extends State<MountainPathScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'default_user';
  List<Map<String, dynamic>> tasks = [];
  List<bool> tasksCompleted = [];
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadData();
    });
    // 仮のタスク生成（AIスケジュール生成は次のステップ）
    final diffDays = widget.examDate.difference(DateTime.now()).inDays;
    if (diffDays > 0) {
      for (int i = 0; i < diffDays && i < 30; i++) {
        tasks.add({'day': i + 1, 'task': 'Day ${i + 1}: 単語学習', 'reason': '基礎を固めるため'});
        tasksCompleted.add(false);
      }
    }
  }

  Future<void> _saveData() async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'hasData': true,
        'examDate': widget.examDate.toIso8601String(),
        'personality': widget.personality,
        'level': widget.level,
        'completedCount': completedCount,
        'tasksCompleted': tasksCompleted,
      });
    } catch (e) {
      print('Save error: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        if (data != null && data['tasksCompleted'] != null) {
          setState(() {
            final completed = List<bool>.from(data['tasksCompleted']);
            for (int i = 0; i < tasks.length && i < completed.length; i++) {
              tasksCompleted[i] = completed[i];
            }
            completedCount = tasksCompleted.where((t) => t).length;
          });
        }
      }
    } catch (e) {
      print('Load error: $e');
    }
  }

  void toggleComplete(int i) {
    setState(() {
      tasksCompleted[i] = !tasksCompleted[i];
      completedCount = tasksCompleted.where((t) => t).length;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final progress = tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).round();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF5DADE2), Color(0xFF85C1E9), Color(0xFFAED6F1), Color(0xFFD5F5E3), Color(0xFF7DCEA0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text('Lumo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('$completedCount タスク完了', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('進捗', style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('$progress%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(decoration: BoxDecoration(color: const Color(0xFF58CC02), borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Task list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final done = tasksCompleted[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => toggleComplete(i),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? const Color(0xFF58CC02) : Colors.white,
                                border: Border.all(color: done ? const Color(0xFF58CC02) : Colors.grey.shade400, width: 3),
                              ),
                              child: Center(
                                child: done
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : Text('${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: done ? Colors.green.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Text(
                                task['task'],
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: done ? Colors.grey : Colors.black87, decoration: done ? TextDecoration.lineThrough : null),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}