import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../controllers/member/book_trainer_controller.dart';
import '../../../../../utils/AppColor/app_colors.dart';
import '../../../../../utils/AppTextStyle/app_text_styles.dart';
import '../../../../Base/CustomTextfield/CustomTextfield.dart';
import '../widgets/booking_trainer_summary.dart';

class BookingPersonalInfo extends StatelessWidget {
  final BookTrainerController controller;

  const BookingPersonalInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 116.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingTrainerSummary(controller: controller),
          SizedBox(height: 18.h),
          _buildLabel('Full Name'),
          _field(
            controller.fullNameController,
            'Full name',
            Icons.person_outline_rounded,
          ),
          _buildLabel('Email'),
          _field(
            controller.emailController,
            'Email address',
            Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildLabel('Phone Number'),
          _field(
            controller.phoneController,
            'Phone number',
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _buildLabel('Location'),
          _field(
            controller.locationController,
            'Location',
            Icons.location_on_outlined,
          ),
          SizedBox(height: 14.h),
          _buildLabel('Select Class Type'),
          _ClassTypePicker(controller: controller),
          SizedBox(height: 18.h),
          Text(
            'Additional Information',
            style: AppTextStyles.xs12SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          _buildLabel('Comment'),
          CustomTextField(
            controller: controller.commentController,
            hintText: 'Add a note for the trainer',
            maxLines: 4,
            contentPaddingVertical: 12.h,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController textController,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return CustomTextField(
      controller: textController,
      hintText: hint,
      keyboardType: keyboardType,
      contentPaddingVertical: 12.h,
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18.sp),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 7.h),
      child: Text(
        text,
        style: AppTextStyles.xs12Medium.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ClassTypePicker extends StatelessWidget {
  final BookTrainerController controller;

  const _ClassTypePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 48.h),
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      onSelected: controller.setClassType,
      itemBuilder: (_) => controller.classTypes
          .map(
            (type) => PopupMenuItem<String>(
              value: type,
              height: 42.h,
              child: Text(
                type == 'IN_PERSON' ? 'In person' : 'Online',
                style: AppTextStyles.xs12Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  letterSpacing: 0,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  controller.selectedClassType.value == 'IN_PERSON'
                      ? 'In person'
                      : 'Online',
                  style: AppTextStyles.xs12Regular.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
