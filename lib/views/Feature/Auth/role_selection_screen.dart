import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fitness/Helpers/route.dart';

import '../../Base/AppButton/appButton.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'Trainer'; // Default selection from screenshot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.0, -1.0),
                radius: 2.5,
                colors: [
                  const Color(0xFFFFA6B4).withValues(alpha: 0.5),
                  const Color(0xFFFFE0B9).withValues(alpha: 0.25),
                  Colors.white,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: AppText(
                    'Are you a Member or\nTrainer?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.twoXL24Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                
                // Role Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          title: 'Member',
                          image: 'assets/images/memberImg.png',
                          isSelected: selectedRole == 'Member',
                          onTap: () => setState(() => selectedRole = 'Member'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRoleCard(
                          title: 'Trainer',
                          image: 'assets/images/trainerImg.png',
                          isSelected: selectedRole == 'Trainer',
                          onTap: () => setState(() => selectedRole = 'Trainer'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppButton(
                    text: "Continue", 
                    onTap: () {
                      if (selectedRole == 'Member') {
                        Get.toNamed(AppRoutes.memberSignUpScreen);
                      } else {
                        Get.toNamed(AppRoutes.trainerSignUpScreen);
                      }
                    }, 
                    showArrow: true
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String image,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 350.h,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.actionPrimary, width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFF7869A).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Selection Indicator
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.actionPrimary : AppColors.iconDisabled,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.actionPrimary,
                        ),
                      )
                    : const SizedBox(width: 10, height: 10),
              ),
            ),
            
            // Image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Label
            Positioned(
              top: 15,
              left: 45,
              child: AppText(
                title,
                style: AppTextStyles.base16Medium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}