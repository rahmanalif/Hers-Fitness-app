import 'package:fitness/models/member_class_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../controllers/member/book_trainer_controller.dart';
import '../../../../../utils/AppColor/app_colors.dart';
import '../../../../../utils/AppTextStyle/app_text_styles.dart';
import '../widgets/booking_trainer_summary.dart';

class BookingSessionSelect extends StatelessWidget {
  final BookTrainerController controller;

  const BookingSessionSelect({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 116.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingTrainerSummary(controller: controller),
          SizedBox(height: 18.h),
          Text(
            'Select Class',
            style: AppTextStyles.sm14SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          _ClassSelector(controller: controller),
          SizedBox(height: 18.h),
          Obx(() {
            final klass = controller.selectedClass;
            final isMonthly = klass?.isMonthlySession ?? false;
            return Text(
              isMonthly ? 'Select Date & Time Slots' : 'Select One Slot',
              style: AppTextStyles.sm14SemiBold.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            );
          }),
          SizedBox(height: 10.h),
          Obx(() {
            if (controller.isLoadingClasses.value &&
                controller.selectedClassSlots.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.actionPrimary,
                  ),
                ),
              );
            }

            if (controller.selectedClass == null) {
              return _emptyState(
                controller.classesErrorMessage.value.isNotEmpty
                    ? controller.classesErrorMessage.value
                    : 'No classes match this class type.',
                isError: controller.classesErrorMessage.value.isNotEmpty,
              );
            }

            if (controller.selectedClassSlots.isEmpty) {
              return _emptyState('No slots were returned for this class.');
            }

            final groupedSlots = _groupSlots(controller.selectedClassSlots);
            return Column(
              children: groupedSlots.entries.map((entry) {
                return _SlotDayGroup(
                  title: entry.key,
                  slots: entry.value,
                  controller: controller,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyState(String message, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Text(
        message,
        style: AppTextStyles.xs12Medium.copyWith(
          color: isError ? AppColors.statusError : AppColors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Map<String, List<MemberAvailabilitySlotModel>> _groupSlots(
    List<MemberAvailabilitySlotModel> slots,
  ) {
    final grouped = <String, List<MemberAvailabilitySlotModel>>{};
    for (final slot in slots) {
      grouped.putIfAbsent(slot.displayDate, () => []).add(slot);
    }
    return grouped;
  }
}

class _ClassSelector extends StatelessWidget {
  final BookTrainerController controller;

  const _ClassSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classes = controller.filteredClasses;

      if (classes.isEmpty) {
        final errorMessage = controller.classesErrorMessage.value;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Text(
            controller.isLoadingClasses.value
                ? 'Loading classes...'
                : errorMessage.isNotEmpty
                ? errorMessage
                : 'No active classes are available for this type.',
            style: AppTextStyles.xs12Medium.copyWith(
              color: errorMessage.isNotEmpty
                  ? AppColors.statusError
                  : AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(classes.length, (index) {
            final item = classes[index];
            final selected = controller.selectedClassIndex.value == index;

            return GestureDetector(
              onTap: () => controller.setClassIndex(index),
              child: Container(
                width: 210.w,
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.actionPrimary
                      : AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected
                        ? AppColors.actionPrimary
                        : AppColors.borderPrimary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xs12SemiBold.copyWith(
                        color: selected
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${_planLabel(item.sessionPlanType)} • ${item.availableSlots.where((slot) => slot.isBookable).length} available',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xxs9Medium.copyWith(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.82)
                            : AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  String _planLabel(String? value) {
    final text = (value ?? '').toUpperCase();
    if (text.contains('MONTH')) return 'Monthly';
    return 'Single';
  }
}

class _SlotDayGroup extends StatelessWidget {
  final String title;
  final List<MemberAvailabilitySlotModel> slots;
  final BookTrainerController controller;

  const _SlotDayGroup({
    required this.title,
    required this.slots,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 16.sp,
                color: AppColors.iconSecondary,
              ),
              SizedBox(width: 7.w),
              Text(
                title,
                style: AppTextStyles.xs12SemiBold.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: slots.map((slot) {
              return Obx(() {
                final selected = controller.selectedSlotIds.contains(slot.id);
                return _SlotChip(
                  slot: slot,
                  selected: selected,
                  onTap: () => controller.selectSlot(slot),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final MemberAvailabilitySlotModel slot;
  final bool selected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = slot.isBookable;
    final spots = slot.spotsRemaining;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 108.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.actionSecondary
              : enabled
              ? Colors.white
              : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? AppColors.actionSecondary
                : enabled
                ? AppColors.borderPrimary
                : AppColors.borderPrimary.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.displayTime,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.xs12SemiBold.copyWith(
                color: selected
                    ? Colors.white
                    : enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              enabled
                  ? spots == null
                        ? 'Available'
                        : '$spots spots'
                  : _disabledLabel(slot.status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.xxs9Medium.copyWith(
                color: selected
                    ? Colors.white.withValues(alpha: 0.82)
                    : enabled
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _disabledLabel(String? status) {
    final value = status?.trim();
    if (value == null || value.isEmpty) return 'Unavailable';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
