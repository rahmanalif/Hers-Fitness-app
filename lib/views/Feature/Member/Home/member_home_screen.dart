import 'package:fitness/controllers/member/member_home_controller.dart';
import 'package:fitness/controllers/member/member_notification_controller.dart';
import 'package:fitness/controllers/member/member_profile_controller.dart';
import 'package:fitness/models/member_next_workout_model.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness/views/Feature/Member/Home/widgets/trainer_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../Helpers/route.dart';
import '../../../Base/AppText/appText.dart';

class MemberHomeScreen extends StatelessWidget {
  MemberHomeScreen({super.key});

  final MemberHomeController controller = Get.put(MemberHomeController());
  final MemberProfileController profileController =
      Get.isRegistered<MemberProfileController>()
      ? Get.find<MemberProfileController>()
      : Get.put(MemberProfileController());
  final MemberNotificationController notificationController =
      Get.isRegistered<MemberNotificationController>()
      ? Get.find<MemberNotificationController>()
      : Get.put(MemberNotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          _buildTopGradient(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategories(),
                      SizedBox(height: 22.h),
                      _buildSectionHeader(
                        "My Next Workouts",
                        () => Get.toNamed(AppRoutes.myClassesScreen),
                      ),
                      SizedBox(height: 16.h),
                      _buildNextWorkoutCard(),
                      SizedBox(height: 22.h),
                      Obx(
                        () => _buildSectionHeader(
                          controller.trainerSectionTitle,
                          () => Get.toNamed(AppRoutes.trainerListScreen),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildTrainerList(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopGradient(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).padding.top + 250.h,
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFDADF).withValues(alpha: 0.9),
                    const Color(0xFFFFECEE).withValues(alpha: 0.8),
                    const Color(0xFFFFF7F5).withValues(alpha: 0.58),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.46, 0.78, 1],
                ),
              ),
            ),
            Positioned(
              left: -78.w,
              top: -38.h,
              width: 220.w,
              height: 220.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFBECB).withValues(alpha: 0.5),
                      const Color(0xFFFFDDE4).withValues(alpha: 0.26),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -76.w,
              top: -26.h,
              width: 230.w,
              height: 230.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFC1CF).withValues(alpha: 0.45),
                      const Color(0xFFFFE1E7).withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final imageUrl = profileController.profileImageUrl;
      final displayName = profileController.displayName;
      final firstName = displayName.split(' ').first;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          14.w,
          MediaQuery.of(context).padding.top + 18.h,
          14.w,
          18.h,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.memberProfileScreen);
              },
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2.w),
                  image: imageUrl.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                ),
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        color: AppColors.textTertiary,
                        size: 22.sp,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "${_greeting()} $firstName",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.base16SemiBold.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    DateFormat('EEE, d MMMM yyyy').format(DateTime.now()),
                    style: AppTextStyles.sm14Regular.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.notificationScreen),
              child: Obx(() {
                final unreadCount = notificationController.unreadCount.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.92),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.actionPrimary.withValues(
                              alpha: 0.62,
                            ),
                            blurRadius: 0,
                            offset: Offset(0, 3.h),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14.r,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/notificationIcon.svg",
                          width: 23.w,
                          height: 23.w,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2.w,
                        top: -2.h,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.w,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            color: AppColors.statusError,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: AppTextStyles.xxs9SemiBold.copyWith(
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.categories.map((category) {
          return Obx(() {
            bool isSelected = controller.selectedCategory.value == category;
            return GestureDetector(
              onTap: () => controller.setCategory(category),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.actionPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.borderPrimary),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.sm14Medium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.sm14SemiBold.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              "View all",
              style: AppTextStyles.xs12Regular.copyWith(
                color: AppColors.actionPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextWorkoutCard() {
    return Obx(() {
      final workout = controller.selectedWorkout;
      final hasWorkout = workout != null;
      final title = workout?.title ?? 'No upcoming workouts';
      final subtitle =
          workout?.subtitle ?? 'Book a trainer to start your next session';
      final date = workout?.compactDate ?? '--';
      final duration = workout?.durationLabel ?? '';

      return GestureDetector(
        onTap: hasWorkout
            ? () => _showWorkoutDetailsBottomSheet(workout)
            : null,
        child: Container(
          width: double.infinity,
          height: 176.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderSecondary),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 150.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  child: Image.asset(
                    "assets/images/workout.png",
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgTertiary,
                      child: Icon(
                        Icons.self_improvement_rounded,
                        color: AppColors.actionPrimary,
                        size: 44.sp,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 18.w, 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildIconLabel(Icons.calendar_today_outlined, date),
                        if (duration.isNotEmpty) ...[
                          SizedBox(width: 16.w),
                          _buildIconLabel(Icons.access_time, duration),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: AppTextStyles.base16SemiBold.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.xs12Regular.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20.w,
                bottom: 20.h,
                child: GestureDetector(
                  onTap: hasWorkout ? controller.showNextWorkout : null,
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasWorkout
                          ? AppColors.actionPrimary
                          : AppColors.actionPrimaryDisabled,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIconLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.actionSecondary),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppTextStyles.xs12Medium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  Widget _buildTrainerList() {
    return Obx(() {
      if (controller.isLoadingTrainers.value && controller.trainers.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.actionPrimary),
          ),
        );
      }

      if (controller.trainers.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Text(
            controller.emptyTrainerMessage,
            style: AppTextStyles.sm14Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Column(
        children: controller.trainers.take(3).map((trainer) {
          final imageUrl = trainer["imageUrl"]?.toString();

          return TrainerCard(
            name: trainer["name"]?.toString() ?? "Trainer",
            expertise: trainer["expertise"]?.toString() ?? "Fitness Trainer",
            rating: trainer["rating"] is num
                ? (trainer["rating"] as num).toDouble()
                : 0,
            price: trainer["price"]?.toString() ?? "Price unavailable",
            imageUrl: imageUrl != null && imageUrl.isNotEmpty
                ? imageUrl
                : "https://as1.ftcdn.net/jpg/02/26/49/16/1000_F_226491635_4Qp2RzkMlglsfSLIzXjLeRmqdTnaD4p8.jpg",
            distance: trainer["distance"]?.toString().isNotEmpty == true
                ? trainer["distance"].toString()
                : null,
            reviewCount: trainer["reviewCount"] is num
                ? (trainer["reviewCount"] as num).toInt()
                : null,
            isActiveNow:
                trainer["locationLabel"] == "Active Now" ||
                trainer["isActiveNow"] == true,
            onTap: () {
              Get.toNamed(
                AppRoutes.trainerDetailsScreen,
                arguments: controller.trainerArgs(trainer),
              );
            },
          );
        }).toList(),
      );
    });
  }

  void _showWorkoutDetailsBottomSheet(MemberNextWorkoutModel workout) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 60.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderPrimary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    "Your Next Workout",
                    style: AppTextStyles.base16SemiBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF9F9F9),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.actionPrimary,
                            blurRadius: 0,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.close, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildWorkoutTrainerSummary(workout.trainer, workout.priceLabel),
              SizedBox(height: 16.h),
              _buildDetailCard(
                icon: Icons.location_on_rounded,
                title: "Location & Time",
                children: [
                  Text(
                    workout.locationTime.location ?? 'Location unavailable',
                    style: AppTextStyles.sm14Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 20.sp,
                        color: const Color(0xFF0284C7),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        workout.displayDate,
                        style: AppTextStyles.sm14Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 20.sp,
                        color: const Color(0xFF0284C7),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        workout.displayTime,
                        style: AppTextStyles.sm14Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildDetailCard(
                icon: Icons.phone_rounded,
                title: "Phone Number",
                children: [
                  Text(
                    workout.trainer.phoneNumber ?? 'Phone number unavailable',
                    style: AppTextStyles.sm14Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildWorkoutTrainerSummary(
    MemberWorkoutTrainer trainer,
    String priceLabel,
  ) {
    final imageUrl = trainer.profileImageUrl;
    final expertise = trainer.classesTaught ?? 'Fitness Trainer';
    final distance = trainer.distanceLabel;
    final rating = trainer.averageRating;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.bgTertiary,
            backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
            child: imageUrl == null
                ? Icon(Icons.person, color: AppColors.textTertiary, size: 24.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.base16Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (rating != null) ...[
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final starValue = index + 1;
                        return Icon(
                          rating >= starValue
                              ? Icons.star
                              : rating >= starValue - 0.5
                              ? Icons.star_half
                              : Icons.star_border,
                          size: 17.sp,
                          color: Colors.orange,
                        );
                      }),
                      SizedBox(width: 6.w),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.xs12Medium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (trainer.reviewCount != null) ...[
                        SizedBox(width: 4.w),
                        Text(
                          '(${trainer.reviewCount})',
                          style: AppTextStyles.xs12Regular.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                SizedBox(height: 7.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildSmallInfo(Icons.monitor_heart_outlined, expertise),
                    if (distance != null)
                      _buildSmallInfo(Icons.location_on, distance),
                    _buildSmallInfo(Icons.payments_outlined, priceLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textTertiary),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTextStyles.xs12Medium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF8E8E93),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: AppTextStyles.base16Medium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          ),
        ],
      ),
    );
  }
}
