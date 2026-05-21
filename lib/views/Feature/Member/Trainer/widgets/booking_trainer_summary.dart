import 'package:fitness/controllers/member/book_trainer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/AppColor/app_colors.dart';
import '../../../../../utils/AppTextStyle/app_text_styles.dart';

class BookingTrainerSummary extends StatelessWidget {
  final BookTrainerController controller;
  final bool showChevron;
  final EdgeInsetsGeometry? margin;

  const BookingTrainerSummary({
    super.key,
    required this.controller,
    this.showChevron = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              controller.trainerImageUrl,
              width: 70.w,
              height: 70.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70.w,
                height: 70.w,
                color: AppColors.bgTertiary,
                child: Icon(Icons.person, size: 26.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.trainerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sm14SemiBold.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xFFF59E0B),
                      size: 14.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      controller.trainerRating.toStringAsFixed(1),
                      style: AppTextStyles.xs12Medium.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.groups_rounded,
                      color: AppColors.actionPrimary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${controller.reviewCount} Reviews',
                      style: AppTextStyles.xs12Regular.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.iconPrimary,
              size: 24.sp,
            ),
        ],
      ),
    );
  }
}
