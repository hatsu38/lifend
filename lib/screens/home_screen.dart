import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '../utils/constants.dart';
import 'target_age_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime? _birthDate;
  int? _targetAge;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

  Map<String, dynamic> _calculateTimeLeft() {
    if (_birthDate == null || _targetAge == null) {
      return {
        'years': '0',
        'months': '0',
        'weeks': '0',
        'days': '0',
        'hours': '0'
      };
    }

    final now = DateTime.now();
    final targetDate = DateTime(
      _birthDate!.year + _targetAge!,
      _birthDate!.month,
      _birthDate!.day,
    );
    
    final difference = targetDate.difference(now);
    
    if (difference.isNegative) {
      return {
        'years': '0',
        'months': '0',
        'weeks': '0',
        'days': '0',
        'hours': '0'
      };
    }

    final numberFormat = NumberFormat('#,###', 'ja_JP');
    return {
      'years': numberFormat.format((difference.inDays / 365.25).floor()),
      'months': numberFormat.format((difference.inDays / 30.44).floor()),
      'weeks': numberFormat.format((difference.inDays / 7).floor()),
      'days': numberFormat.format(difference.inDays),
      'hours': numberFormat.format(difference.inHours),
    };
  }

  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const TargetAgeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = _calculateTimeLeft();
    final displayData = [
      {'value': timeLeft['years'], 'unit': '年', 'emoji': '🗓️', 'color': const Color(0xFF6C63FF)},
      {'value': timeLeft['months'], 'unit': 'ヶ月', 'emoji': '📅', 'color': const Color(0xFF9C27B0)},
      {'value': timeLeft['weeks'], 'unit': '週間', 'emoji': '📊', 'color': const Color(0xFFE91E63)},
      {'value': timeLeft['days'], 'unit': '日', 'emoji': '☀️', 'color': const Color(0xFFFF9800)},
      {'value': timeLeft['hours'], 'unit': '時間', 'emoji': '⏰', 'color': const Color(0xFF4CAF50)},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMotivationalMessage(),
              _buildCountdownView(displayData),
              _buildPageIndicator(displayData.length),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🌟', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lifend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryColor,
              ),
              onPressed: _showResetDialog,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMotivationalMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Text(
        AppConstants.motivationalTexts[
          DateTime.now().day % AppConstants.motivationalTexts.length
        ],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildCountdownView(List<Map<String, dynamic>> displayData) {
    return Expanded(
      child: PageView.builder(
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: displayData.length,
        itemBuilder: (context, index) {
          final data = displayData[index];
          return Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _currentIndex == index ? _pulseAnimation.value : 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (data['color'] as Color).withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data['emoji'] as String,
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'あと',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              data['color'] as Color,
                              (data['color'] as Color).withOpacity(0.7),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            '${data['value']}',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${data['unit']}',
                          style: TextStyle(
                            fontSize: 28,
                            color: data['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPageIndicator(int itemCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          itemCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? AppColors.primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('🔄 設定をリセット'),
        content: const Text('生年月日と目標年齢をリセットして、新しくスタートしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'リセット',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
