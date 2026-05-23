import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../controllers/member/book_trainer_controller.dart';
import '../../../../../utils/AppColor/app_colors.dart';
import '../../../../../utils/AppTextStyle/app_text_styles.dart';
import '../widgets/booking_trainer_summary.dart';
import '../widgets/booking_session_card.dart';

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
          SizedBox(height: 24.h),
          
          Text(
            'Select Class Type',
            style: AppTextStyles.sm14SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8.h),
          _ClassTypePicker(controller: controller),
          SizedBox(height: 18.h),
          Text(
            'Select Class',
            style: AppTextStyles.sm14SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 12.h),
          _ClassSelector(controller: controller),
          SizedBox(height: 24.h),

          Obx(() {
            if (controller.isLoadingClasses.value &&
                controller.selectedClassSlots.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(
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

            if (controller.isMonthlySelection) {
              return _buildMonthlySelection();
            } else {
              return _buildSingleSelection();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSingleSelection() {
    final slots = controller.selectedClassSlots;
    if (slots.isEmpty) {
      return _emptyState('No slots were returned for this class.');
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set reminder',
              style: AppTextStyles.base16Medium.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
            Obx(
              () => Switch.adaptive(
                value: controller.isReminderEnabled.value,
                onChanged: (value) =>
                    controller.isReminderEnabled.value = value,
                activeColor: AppColors.actionPrimary,
                activeTrackColor: AppColors.actionPrimary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...slots.map((slot) {
          final isSelected = controller.selectedSlotIds.contains(slot.id);
          final klass = controller.selectedClass!;
          
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: BookingSessionCard(
              title: klass.title,
              date: slot.displayDate,
              time: slot.displayTime,
              location: klass.location ?? 'Location unavailable',
              classType: klass.classType ?? 'In Person',
              sessionFormat: klass.sessionFormat ?? 'One-to-One',
              price: '\$${klass.price}',
              isSelected: isSelected,
              onTap: () => controller.selectSlot(slot),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: AppTextStyles.sm14SemiBold.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 12.h),
        _CalendarView(controller: controller),
        SizedBox(height: 12.h),
        Row(
          children: [
            _legendItem(const Color(0xFF22C55E), 'Booked'),
            const Spacer(),
            _legendItem(AppColors.actionPrimary, 'Available'),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set reminder',
              style: AppTextStyles.base16Medium.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
            Obx(
              () => Switch.adaptive(
                value: controller.isReminderEnabled.value,
                onChanged: (value) =>
                    controller.isReminderEnabled.value = value,
                activeColor: AppColors.actionPrimary,
                activeTrackColor: AppColors.actionPrimary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Time',
              style: AppTextStyles.sm14SemiBold.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
            _AmPmToggle(controller: controller),
          ],
        ),
        SizedBox(height: 16.h),
        _TimeSlotsGrid(controller: controller),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppTextStyles.xs12Regular.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(12.r),
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
            Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
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
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.actionPrimary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected
                        ? AppColors.actionPrimary
                        : AppColors.borderPrimary,
                  ),
                  boxShadow: selected ? [
                    BoxShadow(
                      color: AppColors.actionPrimary.withValues(alpha: 0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    )
                  ] : null,
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
                            ? Colors.white
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
                            ? Colors.white.withValues(alpha: 0.8)
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

class _CalendarView extends StatelessWidget {
  final BookTrainerController controller;

  const _CalendarView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final focusedDate = controller.focusedDate.value;
      final selectedDate = controller.selectedDate.value;
      
      // For monthly, we want to highlight all days that have a selected slot
      final selectedSlotDates = controller.selectedSlots.map((s) {
        final d = DateTime.tryParse(s.date);
        return d != null ? DateTime(d.year, d.month, d.day) : null;
      }).whereType<DateTime>().toSet();

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.borderSecondary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDate,
          selectedDayPredicate: (day) {
            final dateOnly = DateTime(day.year, day.month, day.day);
            return selectedSlotDates.contains(dateOnly) || isSameDay(selectedDate, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectDate(selectedDay, focusedDay);
          },
          onPageChanged: (focusedDay) {
            controller.focusedDate.value = focusedDay;
          },
          rowHeight: 44.h,
          daysOfWeekHeight: 32.h,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: false,
            titleTextStyle: AppTextStyles.base16SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
            leftChevronVisible: true,
            rightChevronVisible: true,
            leftChevronIcon: Icon(Icons.chevron_left_rounded, size: 24.sp, color: AppColors.textPrimary),
            rightChevronIcon: Icon(Icons.chevron_right_rounded, size: 24.sp, color: AppColors.textPrimary),
            headerPadding: EdgeInsets.only(bottom: 16.h),
            // Position chevrons on the right
            leftChevronPadding: EdgeInsets.zero,
            rightChevronPadding: EdgeInsets.zero,
            leftChevronMargin: EdgeInsets.only(left: 180.w), 
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.xxs9Medium.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0,
            ),
            weekendStyle: AppTextStyles.xxs9Medium.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: AppColors.actionPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.actionSecondary,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: AppTextStyles.sm14Medium.copyWith(
              color: AppColors.textPrimary,
            ),
            weekendTextStyle: AppTextStyles.sm14Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              return _dateBubble(day.day, AppColors.actionSecondary, Colors.white);
            },
            defaultBuilder: (context, day, focusedDay) {
              if (controller.hasBookedSlot(day)) {
                return _dateBubble(day.day, const Color(0xFF22C55E), Colors.white);
              }
              if (controller.hasAvailableSlot(day)) {
                return _dateBubble(day.day, AppColors.actionPrimary, Colors.white);
              }
              return null;
            },
          ),
        ),
      );
    });
  }

  Widget _dateBubble(int day, Color background, Color foreground) {
    return Center(
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Text(
          '$day',
          style: AppTextStyles.sm14Medium.copyWith(
            color: foreground,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AmPmToggle extends StatelessWidget {
  final BookTrainerController controller;

  const _AmPmToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedPeriod = controller.selectedPeriod.value;

      return Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          children: [
            _toggleItem('AM', selectedPeriod),
            _toggleItem('PM', selectedPeriod),
          ],
        ),
      );
    });
  }

  Widget _toggleItem(String label, String selectedPeriod) {
    final isSelected = selectedPeriod == label;
    return GestureDetector(
      onTap: () => controller.setPeriod(label),
      child: Container(
        width: 58.w,
        height: 32.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.actionPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.xs12SemiBold.copyWith(
            color: isSelected ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _TimeSlotsGrid extends StatelessWidget {
  final BookTrainerController controller;

  const _TimeSlotsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slots = controller.availableSlots;

      if (slots.isEmpty) {
        return _emptyState('No available slots for this date.');
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 2.2,
        ),
        itemCount: slots.length,
        itemBuilder: (_, index) {
          final time = slots[index];
          final isSelected = controller.filteredSlots[index].id ==
              controller.selectedSlot?.id;
              
          return GestureDetector(
            onTap: () => controller.setTimeSlot(index),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.actionSecondary
                    : AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                time,
                style: AppTextStyles.xs12Medium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: AppTextStyles.xs12Medium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
