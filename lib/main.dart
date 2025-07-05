import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const LifendApp());
}

class LifendApp extends StatelessWidget {
  const LifendApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifend',
      theme: ThemeData(
        // ダークテーマで統一
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// 最初に表示される画面（初回起動チェック用）
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  // 初回起動かどうかチェック
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateString = prefs.getString('birth_date');
    final targetAge = prefs.getInt('target_age');

    // データがなければ設定画面へ、あればホーム画面へ
    if (mounted) {
      if (birthDateString == null || targetAge == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetupScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
    );
  }
}

// 初期設定画面
class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  DateTime _selectedDate = DateTime.now(); // 選択された生年月日
  int _targetAge = 80; // 生きたい年齢（デフォルト80歳）
  
  // 生年月日を選択するダイアログを表示
  Future<void> _selectDate(BuildContext context) async {
    // iOSスタイルの日付選択
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: Colors.grey[900],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('キャンセル'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('完了'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                minimumDate: DateTime(1900),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // データを保存して次の画面へ
  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    // 生年月日を文字列として保存
    await prefs.setString('birth_date', _selectedDate.toIso8601String());
    // 生きたい年齢を保存
    await prefs.setInt('target_age', _targetAge);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリ名
              const Text(
                'Lifend',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              
              // 生年月日の選択
              const Text(
                '生年月日を選択',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('yyyy年MM月dd日').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // 生きたい年齢の選択
              const Text(
                '何歳まで生きたい？',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              // スライダーで選択
              Column(
                children: [
                  Text(
                    '$_targetAge歳',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _targetAge.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 60,
                    activeColor: Colors.deepPurple,
                    inactiveColor: Colors.grey[800],
                    onChanged: (double value) {
                      setState(() {
                        _targetAge = value.round();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // 開始ボタン
              ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'カウントダウン開始',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// メイン画面（カウントダウン表示）
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 現在表示中のページ
  DateTime? _birthDate;
  int? _targetAge;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 保存されたデータを読み込む
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateString = prefs.getString('birth_date');
    final targetAge = prefs.getInt('target_age');
    
    if (birthDateString != null) {
      setState(() {
        _birthDate = DateTime.parse(birthDateString);
        _targetAge = targetAge;
      });
    }
  }

  // 残り時間を計算
  Map<String, dynamic> _calculateTimeLeft() {
    if (_birthDate == null || _targetAge == null) {
      return {'years': 0, 'months': 0, 'weeks': 0, 'days': 0, 'hours': 0};
    }

    final now = DateTime.now();
    final deathDate = DateTime(
      _birthDate!.year + _targetAge!,
      _birthDate!.month,
      _birthDate!.day,
    );
    
    final difference = deathDate.difference(now);
    
    if (difference.isNegative) {
      return {'years': 0, 'months': 0, 'weeks': 0, 'days': 0, 'hours': 0};
    }
    
    // 各単位での残り時間を計算
    final years = difference.inDays / 365.25;
    final months = difference.inDays / 30.44;
    final weeks = difference.inDays / 7;
    final days = difference.inDays;
    final hours = difference.inHours;

    return {
      'years': years.toStringAsFixed(1),
      'months': months.round(),
      'weeks': weeks.round(),
      'days': days,
      'hours': hours,
    };
  }

  // 設定をリセット
  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = _calculateTimeLeft();
    final displayData = [
      {'value': timeLeft['years'], 'unit': '年'},
      {'value': timeLeft['months'], 'unit': 'ヶ月'},
      {'value': timeLeft['weeks'], 'unit': '週間'},
      {'value': timeLeft['days'], 'unit': '日'},
      {'value': timeLeft['hours'], 'unit': '時間'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lifend',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('設定をリセット'),
                          content: const Text('生年月日と目標年齢をリセットしますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _resetSettings();
                              },
                              child: const Text('リセット'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // カウントダウン表示（スワイプで切り替え）
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '残り',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${displayData[index]['value']}',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${displayData[index]['unit']}',
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // ページインジケーター（現在のページを示す点）
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  displayData.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
