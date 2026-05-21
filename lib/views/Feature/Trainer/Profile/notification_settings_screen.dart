import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _pushController = ValueNotifier<bool>(true);
  final _reminderController = ValueNotifier<bool>(true);
  final _offersController = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pushController.dispose();
    _reminderController.dispose();
    _offersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                _buildSectionTitle("General"),
                _buildSwitchItem(
                  icon: Icons.notifications_none_rounded,
                  title: "Push Notifications",
                  controller: _pushController,
                ),
                _buildSwitchItem(
                  icon: Icons.calendar_today_outlined,
                  title: "Class Reminder Notification",
                  controller: _reminderController,
                ),
                _buildSwitchItem(
                  icon: Icons.monetization_on_outlined,
                  title: "Offers Notifications",
                  controller: _offersController,
                ),
              ],
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
                "Notifications Settings",
                style: AppTextStyles.base16SemiBold.copyWith(color: Colors.white, fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: AppText(
        title,
        style: AppTextStyles.base16SemiBold.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required ValueNotifier<bool> controller,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              title,
              style: AppTextStyles.sm14Medium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          AdvancedSwitch(
            controller: controller,
            activeColor: AppColors.actionPrimary,
            inactiveColor: const Color(0xFF94A3B8),
            width: 44.w,
            height: 24.h,
          ),
        ],
      ),
    );
  }
}
