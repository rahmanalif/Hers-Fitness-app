import 'package:fitness/controllers/member/my_classes_controller.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MemberMyClassesScreen extends StatelessWidget {
  MemberMyClassesScreen({super.key});

  final MyClassesController controller = Get.put(MyClassesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: _buildFilters(),
          ),
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'All Schedules',
              style: AppTextStyles.xs12SemiBold.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Obx(() {
              final schedules = controller.filteredSchedules;

              if (controller.isLoading.value && schedules.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.actionPrimary,
                  ),
                );
              }

              if (schedules.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.actionPrimary,
                onRefresh: () => controller.fetchBookings(showError: true),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                  itemCount: schedules.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    final bookingId = schedule['id']?.toString() ?? '';

                    return _ClassScheduleCard(
                      schedule: schedule,
                      onFeedback: () => _showFeedbackDialog(context),
                      onComplete: () => controller.completeBooking(bookingId),
                      onAccept: () => controller.acceptReschedule(bookingId),
                      onReschedule: () =>
                          _showRescheduleModal(context, bookingId),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        MediaQuery.of(context).padding.top + 14.h,
        16.w,
        12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.actionPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          _HeaderCircleButton(
            icon: Icons.arrow_back_ios_new,
            iconSize: 17.sp,
            onTap: () => Get.back(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Classes',
                style: AppTextStyles.sm14SemiBold.copyWith(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          _HeaderCircleButton(
            icon: Icons.add,
            iconSize: 22.sp,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: controller.filters.map((filter) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;

            return GestureDetector(
              onTap: () => controller.setFilter(filter),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 32.h,
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.actionPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(9.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.actionPrimary
                        : AppColors.borderPrimary,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.xxs9SemiBold.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No classes found for this filter',
        style: AppTextStyles.sm14Medium.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How was your workout?',
                style: AppTextStyles.xs12SemiBold.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Help us make your fitness journey even better',
                style: AppTextStyles.xxs9Regular.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < 2 ? Icons.star_rounded : Icons.star_border_rounded,
                    color: index < 2
                        ? const Color(0xFFF5A623)
                        : AppColors.textTertiary,
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                height: 74.h,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Write here...',
                    style: AppTextStyles.xxs9Regular.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '0/120',
                  style: AppTextStyles.xxs9Regular.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              _SheetPrimaryButton(label: 'Post', onTap: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }

  void _showRescheduleModal(BuildContext context, String bookingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 22.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 58.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderPrimary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reschedule Booking',
                        style: AppTextStyles.xs12SemiBold.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.borderPrimary),
                        ),
                        child: Icon(Icons.close, size: 18.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: AppColors.borderSecondary, height: 1.h),
                SizedBox(height: 18.h),
                _FieldLabel(text: 'New Date'),
                SizedBox(height: 8.h),
                Obx(
                  () => _ModalField(
                    value: controller.selectedRescheduleDate.value,
                    icon: Icons.calendar_month_outlined,
                    onTap: () => _pickDate(context),
                  ),
                ),
                SizedBox(height: 16.h),
                _FieldLabel(text: 'New Time'),
                SizedBox(height: 8.h),
                Obx(
                  () => _ModalField(
                    value: controller.selectedRescheduleTime.value,
                    icon: Icons.schedule_rounded,
                    onTap: () => _pickTime(context),
                  ),
                ),
                SizedBox(height: 20.h),
                _SheetPrimaryButton(
                  label: 'Confirm Reschedule',
                  onTap: () {
                    Get.back();
                    controller.requestReschedule(bookingId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.actionPrimary),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      controller.updateRescheduleDate(
        DateFormat('MM/dd/yyyy').format(pickedDate),
      );
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.actionPrimary,
            primaryContainer: AppColors.actionPrimary,
            onPrimaryContainer: Colors.white,
            secondary: AppColors.actionPrimary,
            secondaryContainer: AppColors.actionPrimary,
            onSecondaryContainer: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      controller.updateRescheduleTime(DateFormat('hh:mm a').format(dateTime));
    }
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _HeaderCircleButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ClassScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onFeedback;
  final VoidCallback onComplete;
  final VoidCallback onAccept;
  final VoidCallback onReschedule;

  const _ClassScheduleCard({
    required this.schedule,
    required this.onFeedback,
    required this.onComplete,
    required this.onAccept,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final status = schedule['status']?.toString() ?? 'Upcoming';

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['title']?.toString() ?? 'Class',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xs12SemiBold.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'With ${schedule['trainer'] ?? 'Trainer'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xxs9Regular.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusIndicator(status: status),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderSecondary),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  text: schedule['date']?.toString() ?? '',
                ),
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  text: schedule['time']?.toString() ?? '',
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          _CardActions(
            schedule: schedule,
            onFeedback: onFeedback,
            onComplete: onComplete,
            onAccept: onAccept,
            onReschedule: onReschedule,
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'Completed') {
      return Text(
        'Completed',
        style: AppTextStyles.xxs9Medium.copyWith(
          color: AppColors.statusInfo,
          letterSpacing: 0,
        ),
      );
    }

    return Container(
      width: 10.w,
      height: 10.w,
      margin: EdgeInsets.only(top: 3.h),
      decoration: BoxDecoration(
        color: AppColors.actionPrimary.withValues(alpha: 0.58),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: AppColors.actionPrimary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.xxs9SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardActions extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onFeedback;
  final VoidCallback onComplete;
  final VoidCallback onAccept;
  final VoidCallback onReschedule;

  const _CardActions({
    required this.schedule,
    required this.onFeedback,
    required this.onComplete,
    required this.onAccept,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final status = schedule['status']?.toString() ?? 'Upcoming';
    final canMarkComplete = schedule['canMarkComplete'] == true;
    final canAcceptReschedule = schedule['canAcceptReschedule'] == true;
    final waitingForTrainer = schedule['waitingForTrainer'] == true;

    if (status == 'Completed') {
      return _CardButton(
        label: 'Feedback',
        backgroundColor: AppColors.bgTertiary,
        foregroundColor: AppColors.textPrimary,
        bordered: true,
        onTap: onFeedback,
      );
    }

    if (canAcceptReschedule) {
      return _CardButton(
        label: 'Accept New Time',
        backgroundColor: AppColors.actionSecondary,
        foregroundColor: Colors.white,
        onTap: onAccept,
      );
    }

    if (waitingForTrainer) {
      return _CardButton(
        label: 'Waiting for Trainer',
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textSecondary,
        bordered: true,
      );
    }

    if (canMarkComplete || status == 'Pending') {
      return _CardButton(
        label: 'Mark as complete',
        backgroundColor: AppColors.actionSecondary,
        foregroundColor: Colors.white,
        onTap: onComplete,
      );
    }

    return Row(
      children: [
        Expanded(
          child: _CardButton(
            label: 'Cancel',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            bordered: true,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _CardButton(
            label: 'Rescheduled',
            backgroundColor: AppColors.actionSecondary,
            foregroundColor: Colors.white,
            onTap: onReschedule,
          ),
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool bordered;
  final VoidCallback? onTap;

  const _CardButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.bordered = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(7.r),
          border: bordered ? Border.all(color: AppColors.borderPrimary) : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.xxs9SemiBold.copyWith(
            color: foregroundColor,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.xxs9SemiBold.copyWith(
        color: AppColors.textPrimary,
        letterSpacing: 0,
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ModalField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.contains('/') || value.contains(':');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value : 'mm/dd/yyyy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.xxs9Regular.copyWith(
                  color: hasValue ? AppColors.textPrimary : AppColors.textTertiary,
                  letterSpacing: 0,
                ),
              ),
            ),
            Icon(icon, color: AppColors.textPrimary, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

class _SheetPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SheetPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.actionSecondary,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.xxs9SemiBold.copyWith(
            color: Colors.white,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
