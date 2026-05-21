import 'package:fitness/controllers/member/member_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../Helpers/route.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  int selectedYear = DateTime.now().year;
  late final MemberProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<MemberProfileController>()
        ? Get.find<MemberProfileController>()
        : Get.put(MemberProfileController());
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10),
              lastDate: DateTime(DateTime.now().year + 10),
              initialDate: DateTime.now(),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime dateTime) {
                setState(() {
                  selectedYear = dateTime.year;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, _profileController.profileImageUrl),
              if (_profileController.isLoading.value)
                LinearProgressIndicator(color: AppColors.actionPrimary),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    AppText(
                      _profileController.displayName,
                      style: AppTextStyles.xl20SemiBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        AppText(
                          _profileController.displayLocation,
                          style: AppTextStyles.sm14Medium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ── Monthly Activity ──────────────────────────────────
                    _buildMonthlyActivity(context),
                    SizedBox(height: 32.h),

                    // ── Stats Row ─────────────────────────────────────────
                    _buildStatsRow(),
                    SizedBox(height: 24.h),

                    // ── Refer a Friend ────────────────────────────────────
                    _buildReferFriendButton(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String imageUrl) {
    return SizedBox(
      height: 235.h,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: 190.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Top Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeaderCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back(),
                ),
                _HeaderCircleButton(
                  icon: Icons.settings_outlined,
                  onTap: () =>
                      Get.toNamed(AppRoutes.memberAccountSettingsScreen),
                ),
              ],
            ),
          ),
          // Profile Image
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white, width: 4),
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
                      color: AppColors.textSecondary,
                      size: 40.w,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivity(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "Monthly Activity",
                style: AppTextStyles.base16SemiBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => _showYearPicker(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      AppText(
                        "$selectedYear",
                        style: AppTextStyles.xs12Regular.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ── High-Fidelity Monthly Bar Chart ──────────────────────────
          SizedBox(
            height: 200.h,
            child: Row(
              children: [
                // Y-Axis Labels
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 24.h,
                  ), // Align with chart area
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["100", "90", "80", "70", "60"].map((label) {
                      return AppText(
                        label,
                        style: AppTextStyles.xs12Regular.copyWith(
                          color: const Color(0xFF828282),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 12.w),
                // Chart Area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Grid Lines (Horizontal)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                5,
                                (index) => _DashedGridLine(),
                              ),
                            ),
                            // Bars Area (12 months)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: _buildMonthlyBars(),
                            ),
                          ],
                        ),
                      ),
                      // Month Labels Row
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _buildMonthlyLabels(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        _Bar(day: "Jan", value: 70, width: 14),
        _Bar(day: "Feb", value: 75, width: 14),
        _Bar(day: "Mar", value: 85, width: 14),
        _Bar(day: "Apr", value: 72, width: 14),
        _Bar(day: "May", value: 80, width: 14),
        _Bar(day: "Jun", value: 90, width: 14),
        _Bar(day: "Jul", value: 78, width: 14),
        _Bar(day: "Aug", value: 74, width: 14),
        _Bar(day: "Sep", value: 71, width: 14),
        _Bar(day: "Oct", value: 76, width: 14),
        _Bar(day: "Nov", value: 82, width: 14),
        _Bar(day: "Dec", value: 75, width: 14),
      ],
    );
  }

  Widget _buildMonthlyLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
          ].map((mon) {
            return SizedBox(
              width: 14.w,
              child: Center(
                child: AppText(
                  mon.substring(0, 1), // J, F, M...
                  style: AppTextStyles.xs12Regular.copyWith(
                    color: const Color(0xFF828282),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          icon: Icons.calendar_month,
          iconColor: AppColors.actionPrimary,
          value: "18",
          unit: "yr",
          label: "Current Age",
        ),
        _buildStatCard(
          icon: Icons.monitor_weight,
          iconColor: const Color(0xFF16A34A),
          value: "75",
          unit: "kg",
          label: "Current weight",
        ),
        _buildStatCard(
          icon: Icons.restaurant_menu_rounded,
          iconColor: const Color(0xFF0284C7),
          value: "Carbo Diet",
          unit: "",
          label: "specific diet",
          isSmallValue: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
    bool isSmallValue = false,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderSecondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(height: 16.h),
            isSmallValue
                ? AppText(
                    value,
                    style: AppTextStyles.base16Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        value,
                        style: AppTextStyles.xl20Bold.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 24.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: AppText(
                          unit,
                          style: AppTextStyles.sm14Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 8.h),
            AppText(
              label,
              style: AppTextStyles.xs12Regular.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferFriendButton() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.share_outlined,
              color: const Color(0xFF0284C7),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: AppText(
              "Refer a Friend",
              style: AppTextStyles.base16Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textPrimary,
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, size: 20, color: Colors.black)),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double value; // Value between 60 and 100
  final double width;

  const _Bar({required this.day, required this.value, required this.width});

  @override
  Widget build(BuildContext context) {
    // Scaling value from 60-100 range to 0-1 percentage
    double heightFactor = (value - 60) / 40;
    if (heightFactor < 0) heightFactor = 0;
    if (heightFactor > 1) heightFactor = 1;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Background Column (Full height of the grid area)
        Container(
          width: width.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        // Data Bar (Actual value)
        FractionallySizedBox(
          heightFactor: heightFactor,
          child: Container(
            width: width.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedGridLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1.h,
      child: CustomPaint(
        painter: _DashedLinePainter(color: Colors.grey.shade300),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
