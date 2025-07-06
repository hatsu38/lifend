import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import '../utils/constants.dart';
import '../widgets/gradient_button.dart';
import '../widgets/step_indicator.dart';
import 'birthday_screen.dart';

class TargetAgeScreen extends StatefulWidget {
  const TargetAgeScreen({Key? key}) : super(key: key);

  @override
  State<TargetAgeScreen> createState() => _TargetAgeScreenState();
}

class _TargetAgeScreenState extends State<TargetAgeScreen>
    with SingleTickerProviderStateMixin {
  int _targetAge = 80;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target_age', _targetAge);
    
    if (mounted) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 500),
          child: const BirthdayScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const StepIndicator(currentStep: 1, totalSteps: 2),
                    const SizedBox(height: 40),
                    
                    const Text(
                      '🎯 自分の寿命を設定しよう！',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '平均寿命を参考にするといいよ',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    _buildAverageLifespanCard(),
                    
                    const Spacer(),
                    
                    _buildAgeSelector(),
                    
                    const Spacer(),
                    
                    GradientButton(
                      text: '次へ →',
                      onPressed: _goToNext,
                      heroTag: 'continue-button',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAverageLifespanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🇯🇵 日本の平均寿命',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLifespanCard(
                '👨',
                '男性',
                AppConstants.japanMaleAverageLifespan,
                AppColors.primaryColor,
              ),
              _buildLifespanCard(
                '👩',
                '女性',
                AppConstants.japanFemaleAverageLifespan,
                AppColors.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLifespanCard(String emoji, String label, int age, Color color) {
    return InkWell( // InkWellを追加
      onTap: () { // onTapハンドラを追加
        setState(() {
          _targetAge = age; // クリックされた年齢を_targetAgeに設定
        });
      },
      borderRadius: BorderRadius.circular(15), // InkWellにborderRadiusを設定
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              '$label: $age歳',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: _targetAge),
            duration: const Duration(milliseconds: 100),
            builder: (context, value, child) {
              return Text(
                '$value歳',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.primaryColor.withOpacity(0.2),
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
              ),
              trackHeight: 8,
            ),
            child: Slider(
              value: _targetAge.toDouble(),
              min: 0,
              max: 120,
              onChanged: (double value) {
                setState(() {
                  _targetAge = value.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
