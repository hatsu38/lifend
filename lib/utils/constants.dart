import 'package:flutter/material.dart';

class AppColors {
  // プライマリカラー
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color accentColor = Color(0xFFE91E63);
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color backgroundColorDark = Color(0xFFE8EAFF);
  
  // テキストカラー
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);
  
  // グラデーション
  static const List<Color> primaryGradient = [primaryColor, secondaryColor];
  static const List<Color> splashGradient = [
    primaryColor,
    secondaryColor,
    accentColor,
  ];
  static const List<Color> backgroundGradient = [
    backgroundColor,
    backgroundColorDark,
  ];
}

class AppConstants {
  // 日本の平均寿命
  static const int japanMaleAverageLifespan = 81;
  static const int japanFemaleAverageLifespan = 89;
  
  // 占い的なメッセージ
  static const List<String> motivationalTexts = [
    '今日は小さな幸運が舞い込みそう',
    '午後から運気が上昇する予感',
    '新しいことにチャレンジすると吉',
    '周りの人との会話で良いヒントが得られそう',
    '今日は直感が冴えているかも',
    '笑顔でいると良いことが起こりそう',
    '今日のラッキーカラーは青色',
    '午前中の行動が一日を左右しそう',
    '友人からの連絡に注目してみて',
    '今日は健康運が好調です',
  ];
}
