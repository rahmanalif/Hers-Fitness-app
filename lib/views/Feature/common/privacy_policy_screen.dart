import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContentSection(
                      "Privacy Policy for Hers Fitness App",
                      "Effective Date: [Insert Date of launching app]\nHers Fitness (“we,” “our,” or “us”) values your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the Hers Fitness mobile application (the “App”).",
                    ),
                    SizedBox(height: 24.h),
                    _buildContentSection(
                      "1. Information We Collect",
                      "We may collect the following types of information:",
                    ),
                    _buildBulletPoint("a. Personal Information", "Name, Email address, Phone number, Account login credentials"),
                    _buildBulletPoint("b. Fitness & Health Information", "Workout activity and class attendance, Fitness goals and preferences, Progress tracking data (e.g., weight, measurements, performance metrics)"),
                    _buildBulletPoint("c. Payment Information", "Billing details (processed securely through third-party payment providers)"),
                    _buildBulletPoint("d. Device & Usage Information", ""),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 16.h,
        20.w,
        24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.actionPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                "Privacy Policy",
                style: AppTextStyles.base16SemiBold.copyWith(color: Colors.white, fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 44.w)
        ],
      ),
    );
  }

  Widget _buildContentSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          style: AppTextStyles.base16SemiBold.copyWith(color: AppColors.textPrimary),
        ),
        if (content.isNotEmpty) ...[
          SizedBox(height: 12.h),
          AppText(
            content,
            style: AppTextStyles.sm14Regular.copyWith(color: const Color(0xFF454F5B), height: 1.5),
          ),
        ],
      ],
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: AppTextStyles.sm14Medium.copyWith(color: AppColors.textPrimary),
          ),
          if (content.isNotEmpty) ...[
            SizedBox(height: 4.h),
            AppText(
              "• $content",
              style: AppTextStyles.sm14Regular.copyWith(color: const Color(0xFF454F5B), height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
