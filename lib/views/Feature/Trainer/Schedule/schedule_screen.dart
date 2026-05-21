import 'package:fitness/controllers/my_classes_controller.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/AppColor/app_colors.dart';
import '../Classes/widgets/class_type_bottom_sheet.dart';
import 'widgets/custom_schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDateIndex = 0;
  List<DateTime> weekDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  String displayMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());
  late final MyClassesController classesController;

  @override
  void initState() {
    super.initState();
    classesController = Get.isRegistered<MyClassesController>()
        ? Get.find<MyClassesController>()
        : Get.put(MyClassesController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              children: [
                Obx(() {
                  final selectedDate = weekDates[selectedDateIndex];
                  final dayClasses = _classesForDate(selectedDate);

                  if (classesController.isLoading.value && dayClasses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: CircularProgressIndicator(
                          color: AppColors.actionPrimary,
                        ),
                      ),
                    );
                  }

                  if (dayClasses.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 80.h),
                      child: Center(
                        child: AppText(
                          "No classes scheduled for this day",
                          style: AppTextStyles.sm14Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(dayClasses.length, (index) {
                      final item = dayClasses[index];
                      final timeParts = _splitTime(item['time']?.toString());

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: CustomScheduleCard(
                          timeText: timeParts.$1,
                          ampm: timeParts.$2,
                          title: item['title']?.toString() ?? 'Class',
                          duration: "${item['duration'] ?? '--'} min",
                          isCompleted: false,
                          isBooked: true,
                        ),
                      );
                    }),
                  );
                }),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.h, bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.actionPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Center(child: Icon(Icons.arrow_back_ios_new, size: 20)),
                  ),
                ),
                AppText(
                  "Schedule",
                  style: AppTextStyles.xl20Medium.copyWith(color: Colors.white),
                ),
                GestureDetector(
                  onTap: _openCreateSheet,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Center(child: Icon(Icons.add, size: 28, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppText(
              displayMonthYear,
              style: AppTextStyles.base16Medium.copyWith(color: AppColors.textInverse),
            ),
          ),
          SizedBox(height: 12.h),

          /// Horizontal Dates Strip
          SizedBox(
            height: 105.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                DateTime date = weekDates[index];
                String dayName = DateFormat('EEE').format(date);
                String dayNumber = DateFormat('d').format(date);
                
                return _buildDateItem(
                  day: dayName,
                  date: dayNumber,
                  isSelected: index == selectedDateIndex,
                  onTap: () {
                    setState(() {
                      selectedDateIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem({required String day, required String date, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65.w,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE06F83).withOpacity(0.8),
          borderRadius: BorderRadius.circular(35),
          border: isSelected ? Border.all(color: const Color(0xFFE06F83), width: 1) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    spreadRadius: 4,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              day,
              style: AppTextStyles.xs12Regular.copyWith(
                color: isSelected ? Colors.black87 : Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            AppText(
              date,
              style: AppTextStyles.base16Medium.copyWith(
                color: isSelected ? Colors.black87 : Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFA6A85) : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String) _splitTime(String? value) {
    if (value == null || value.isEmpty || value == 'N/A') return ('--:--', '');

    final parts = value.split(' ');
    if (parts.length < 2) return (value, '');

    return (parts.first, parts.last);
  }

  List<Map<String, dynamic>> _classesForDate(DateTime selectedDate) {
    final dayClasses = <Map<String, dynamic>>[];

    for (final item in classesController.classes) {
      final slots = item['availableSlots'];

      if (slots is List && slots.isNotEmpty) {
        for (final slot in slots) {
          final startDateTime = _slotStartDateTime(slot);
          if (startDateTime == null ||
              !_isSameDay(startDateTime, selectedDate)) {
            continue;
          }

          dayClasses.add({
            ...item,
            'time': _slotDisplayTime(slot),
            'startDateTime': startDateTime,
          });
        }
        continue;
      }

      final startDateTime = item['startDateTime'];
      if (startDateTime is DateTime &&
          _isSameDay(startDateTime, selectedDate)) {
        dayClasses.add(item);
      }
    }

    dayClasses.sort((a, b) {
      final first = a['startDateTime'];
      final second = b['startDateTime'];
      if (first is DateTime && second is DateTime) {
        return first.compareTo(second);
      }
      return 0;
    });

    return dayClasses;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  DateTime? _slotStartDateTime(dynamic slot) {
    if (slot is! Map) return null;

    final date = _slotValue(slot, const ['date', 'slotDate', 'slot_date']);
    final startTime = _slotValue(
      slot,
      const ['startTime', 'start_time', 'time'],
    );

    if (date == null || startTime == null) return null;

    final normalizedTime = startTime.length == 5 ? '$startTime:00' : startTime;
    return DateTime.tryParse('${date}T$normalizedTime');
  }

  String _slotDisplayTime(dynamic slot) {
    if (slot is! Map) return 'N/A';

    final startTime = _slotValue(
      slot,
      const ['startTime', 'start_time', 'time'],
    );
    if (startTime == null || startTime.isEmpty) return 'N/A';

    final upper = startTime.toUpperCase();
    if (upper.contains('AM') || upper.contains('PM')) return startTime;

    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return startTime;

    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour12:${minute.toString().padLeft(2, '0')} $suffix";
  }

  String? _slotValue(Map slot, List<String> keys) {
    for (final key in keys) {
      final value = slot[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }

    return null;
  }

  void _openCreateSheet() {
    showCreateClassFlow(context);
  }

}
