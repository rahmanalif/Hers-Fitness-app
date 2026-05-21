import 'package:fitness/Helpers/route.dart';
import 'package:fitness/controllers/my_classes_controller.dart';
import 'package:fitness/controllers/trainer/trainer_profile_controller.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:fitness/views/Feature/Trainer/Home/widgets/class_details_bottom_sheet.dart';
import 'package:fitness/views/Feature/Trainer/Home/widgets/dashboard_stat_card.dart';
import 'package:fitness/views/Feature/Trainer/Home/widgets/next_class_card.dart';
import 'package:fitness/views/Feature/Trainer/Home/widgets/timeline_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  void _showDetails(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClassDetailsBottomSheet(classData: classData),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is available
    final MyClassesController classesController = Get.isRegistered<MyClassesController>() ? Get.find<MyClassesController>() : Get.put(MyClassesController());
    final TrainerProfileController profileController =
        Get.isRegistered<TrainerProfileController>()
        ? Get.find<TrainerProfileController>()
        : Get.put(TrainerProfileController());
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context, profileController),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Dashboard Section ──────────────────────────
                  AppText(
                    "Dashboard",
                    style: AppTextStyles.base16SemiBold.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8.h,
                    crossAxisSpacing: 8.w,
                    childAspectRatio: 1.25,
                    children: const [
                      DashboardStatCard(
                        title: "Total Classes",
                        value: "20",
                        icon: Icons.calendar_month_rounded,
                        iconColor: Color(0xFFF7869A), // Pinkish from screenshot
                      ),
                      DashboardStatCard(
                        title: "Total Attendance",
                        value: "18",
                        icon: Icons.people_alt_rounded,
                        iconColor: Color(0xFF0284C7), // Blueish
                      ),
                      DashboardStatCard(
                        title: "Avg Class Size",
                        value: "18",
                        icon: Icons.trending_up_rounded,
                        iconColor: Color(0xFF16A34A), // Greenish
                      ),
                      DashboardStatCard(
                        title: "Overall Rating",
                        value: "4.5",
                        icon: Icons.star_rounded,
                        iconColor: Color(0xFFF59E0B), // Yellowish
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // ── Next Class Section ──────────────────────────
                  AppText(
                    "Next Class",
                    style: AppTextStyles.base16SemiBold.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 16.h),

                  // Reactive display of only the first class
                  Obx(() {
                    if (classesController.isLoading.value &&
                        classesController.classes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: CircularProgressIndicator(
                            color: AppColors.actionPrimary,
                          ),
                        ),
                      );
                    }

                    if (classesController.classes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: AppText(
                            "No classes scheduled yet",
                            style: AppTextStyles.sm14Medium.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }
                    final nextClass = classesController.classes.first;
                    return NextClassCard(
                      classData: nextClass,
                      onTap: () => _showDetails(context, nextClass),
                    );
                  }),
                  SizedBox(height: 32.h),

                  // ── Today's Schedule Section ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        "Today's Schedule",
                        style: AppTextStyles.base16SemiBold.copyWith(color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.scheduleScreen);
                        },
                        child: AppText(
                          "View all",
                          style: AppTextStyles.sm14Medium.copyWith(color: const Color(0xFFF7869A)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  Obx(() {
                    final scheduleItems = classesController.classes.take(2).toList();

                    if (classesController.isLoading.value &&
                        scheduleItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: CircularProgressIndicator(
                            color: AppColors.actionPrimary,
                          ),
                        ),
                      );
                    }

                    if (scheduleItems.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: AppText(
                            "No schedule available",
                            style: AppTextStyles.sm14Medium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(scheduleItems.length, (index) {
                        final item = scheduleItems[index];
                        return TimelineScheduleCard(
                          time: item["time"]?.toString() ?? "N/A",
                          title: item["title"]?.toString() ?? "Class",
                          date: item["date"]?.toString() ?? "",
                          icon: Icons.fitness_center_rounded,
                          isLast: index == scheduleItems.length - 1,
                        );
                      }),
                    );
                  }),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TrainerProfileController profileController,
  ) {
    return Obx(() {
      final imageUrl = profileController.profileImageUrl;

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
            // Profile Image
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.trainerProfileScreen);
              },
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white, width: 2),
                  image: imageUrl.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                ),
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 14.w),
            // Greeting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Welcome back",
                    style: AppTextStyles.xs12Regular.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  AppText(
                    profileController.displayName,
                    style: AppTextStyles.base16SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Notification Icon
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.notificationScreen),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/notificationIcon.svg",
                    width: 24.w,
                    height: 24.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
