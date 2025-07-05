import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  
  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps * 2 - 1,
        (index) {
          if (index.isOdd) {
            // ライン
            return _buildStepLine(index ~/ 2 < currentStep - 1);
          } else {
            // サークル
            final stepNumber = index ~/ 2 + 1;
            return _buildStepCircle(
              stepNumber <= currentStep,
              stepNumber < currentStep ? '✓' : stepNumber.toString(),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildStepCircle(bool isActive, String label) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      color: isActive ? AppColors.primaryColor : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
