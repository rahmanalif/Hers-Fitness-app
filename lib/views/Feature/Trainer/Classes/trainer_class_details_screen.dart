import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/models/trainer_class_model.dart';
import 'package:fitness/services/trainer_class_service.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/utils/booking_action_visibility.dart';
import 'package:fitness/utils/app_snackbar.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrainerClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const TrainerClassDetailsScreen({super.key, required this.classData});

  @override
  State<TrainerClassDetailsScreen> createState() =>
      _TrainerClassDetailsScreenState();
}

class _TrainerClassDetailsScreenState extends State<TrainerClassDetailsScreen> {
  final TrainerClassService _classService = TrainerClassService();
  Future<Map<String, dynamic>>? _detailsFuture;
  String? _completingBookingId;

  @override
  void initState() {
    super.initState();
    final id = _readString(widget.classData, const ['id']);
    if (id != null) {
      _detailsFuture = _classService.getClassDetails(id);
    }
  }

  void _refreshDetails(String id) {
    setState(() {
      _detailsFuture = _classService.getClassDetails(id);
    });
  }

  Future<void> _completeTrainerBooking(
    String bookingId,
    Map<String, dynamic> classData,
  ) async {
    if (_completingBookingId != null) return;

    final classId = _readString(classData, const ['id']);
    setState(() => _completingBookingId = bookingId);

    try {
      await _classService.completeBooking(bookingId);
      showAppSnackbar(
        'Class completed',
        'Trainer confirmation has been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (classId != null && mounted) _refreshDetails(classId);
    } on ApiException catch (error) {
      showAppSnackbar(
        'Complete failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      showAppSnackbar(
        'Complete failed',
        'Could not mark this booking as complete.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _completingBookingId = null);
    }
  }

  Future<void> _openRescheduleSheet(Map<String, dynamic> classData) async {
    final id = _readString(classData, const ['id']);
    if (id == null) {
      showAppSnackbar(
        'Missing class',
        'Class id was not found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final didSubmit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RescheduleBottomSheet(
        classId: id,
        classService: _classService,
        durationMinutes: _readInt(classData, const [
          'durationMinutes',
          'duration_minutes',
          'duration',
        ]),
      ),
    );

    if (didSubmit != true || !mounted) return;

    showAppSnackbar(
      'Reschedule requested',
      'Proposed slot sent for member approval.',
      snackPosition: SnackPosition.BOTTOM,
    );
    _refreshDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: _detailsFuture == null
                ? _DetailsBody(
                    classData: widget.classData,
                    completingBookingId: _completingBookingId,
                    onReschedule: () => _openRescheduleSheet(widget.classData),
                    onCompleteBooking: (bookingId) =>
                        _completeTrainerBooking(bookingId, widget.classData),
                  )
                : FutureBuilder<Map<String, dynamic>>(
                    future: _detailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.actionPrimary,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        final message = snapshot.error is ApiException
                            ? (snapshot.error as ApiException).message
                            : 'Could not load class details.';
                        return _ErrorState(message: message);
                      }

                      final classData = snapshot.data ?? widget.classData;
                      return _DetailsBody(
                        classData: classData,
                        completingBookingId: _completingBookingId,
                        onReschedule: () => _openRescheduleSheet(classData),
                        onCompleteBooking: (bookingId) =>
                            _completeTrainerBooking(bookingId, classData),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Map<String, dynamic> classData;
  final String? completingBookingId;
  final VoidCallback onReschedule;
  final ValueChanged<String> onCompleteBooking;

  const _DetailsBody({
    required this.classData,
    required this.completingBookingId,
    required this.onReschedule,
    required this.onCompleteBooking,
  });

  @override
  Widget build(BuildContext context) {
    final title = _readString(classData, const ['name', 'title']) ?? 'Class';
    final classType = _displayClassType(
      _readString(classData, const ['classType', 'class_type', 'apiClassType']),
    );
    final sessionFormat = _displaySessionFormat(
      _readString(classData, const [
        'sessionFormat',
        'session_format',
        'apiSessionFormat',
      ]),
    );
    final duration = _readInt(classData, const [
      'durationMinutes',
      'duration_minutes',
      'duration',
    ]);
    final price = _readDouble(classData, const [
      'pricePerMember',
      'price_per_member',
      'price',
    ]);
    final slots = _readList(classData, const [
      'availableSlots',
      'available_slots',
      'availabilitySlots',
      'availability_slots',
    ]);
    final firstSlot = slots.isNotEmpty ? _asMap(slots.first) : null;
    final bookedSlots = _readList(classData, const [
      'bookedSlots',
      'booked_slots',
    ]);
    final isGroup = sessionFormat.toLowerCase() == 'group';
    final bookedMemberCount = _readInt(classData, const [
      'bookedMemberCount',
      'booked_member_count',
    ]);
    final rescheduleStatus = _readString(classData, const [
      'rescheduleStatus',
      'reschedule_status',
    ]);
    final rescheduleNote = _readString(classData, const [
      'rescheduleNote',
      'reschedule_note',
    ]);
    final rescheduleRequestedAt = _readString(classData, const [
      'rescheduleRequestedAt',
      'reschedule_requested_at',
    ]);
    final proposedSlots = _readList(classData, const [
      'proposedRescheduleSlots',
      'proposed_reschedule_slots',
    ]);
    final hasRescheduleState =
        (rescheduleStatus != null && rescheduleStatus.isNotEmpty) ||
        proposedSlots.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderSecondary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.base16SemiBold.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                AppText(
                  _displayDate(firstSlot),
                  style: AppTextStyles.xs12SemiBold.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 8.h),
                AppText(
                  _displayTime(firstSlot, duration),
                  style: AppTextStyles.xs12SemiBold.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 16.h),
                _InfoPanel(
                  children: [
                    _InfoItem(label: 'Class type', value: classType),
                    _InfoItem(label: 'Session Format', value: sessionFormat),
                  ],
                ),
                SizedBox(height: 12.h),
                _InfoPanel(
                  children: [
                    _InfoItem(
                      label: 'Per Member',
                      value: '\$${price.toStringAsFixed(0)}',
                    ),
                    _InfoItem(label: 'Duration (min)', value: '$duration min'),
                  ],
                ),
                if (isGroup) ...[
                  SizedBox(height: 12.h),
                  _CapacityPanel(
                    slot: firstSlot,
                    classData: classData,
                    bookedMemberCount: bookedMemberCount,
                  ),
                ],
                if (hasRescheduleState) ...[
                  SizedBox(height: 12.h),
                  _RescheduleStatusPanel(
                    status: rescheduleStatus,
                    note: rescheduleNote,
                    requestedAt: rescheduleRequestedAt,
                    slots: proposedSlots,
                  ),
                ],
                SizedBox(height: 18.h),
                GestureDetector(
                  onTap: onReschedule,
                  child: Container(
                    height: 42.h,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.actionSecondary,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: AppText(
                      'Rescheduled',
                      style: AppTextStyles.sm14SemiBold.copyWith(
                        color: AppColors.textInverse,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          AppText(
            'Join Members',
            style: AppTextStyles.base16SemiBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 14.h),
          if (bookedSlots.isEmpty)
            _EmptyMembers()
          else
            ...bookedSlots.map((item) {
              final member = _memberMap(item);
              final booking = _bookingActionSource(item, classData, firstSlot);
              final bookingId = _readString(booking, const [
                'bookingId',
                'booking_id',
                'id',
              ]);
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _MemberTile(
                  member: member,
                  booking: booking,
                  isCompleting:
                      bookingId != null && bookingId == completingBookingId,
                  onComplete: bookingId == null
                      ? null
                      : () => onCompleteBooking(bookingId),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _displayDate(Map<String, dynamic>? slot) {
    final startAt = _readString(slot, const ['startAt', 'start_at']);
    final parsedStartAt = startAt == null ? null : DateTime.tryParse(startAt);
    if (parsedStartAt != null) {
      return DateFormat('EEEE, MMMM d, yyyy').format(parsedStartAt);
    }

    final date = _readString(slot, const ['date', 'scheduledDate']);
    final parsedDate = date == null ? null : DateTime.tryParse(date);
    if (parsedDate != null) {
      return DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);
    }

    return date ?? '';
  }

  String _displayTime(Map<String, dynamic>? slot, int duration) {
    final start = _timeText(
      _readString(slot, const ['startTime', 'start_time']),
    );
    final end = _timeText(_readString(slot, const ['endTime', 'end_time']));
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end (${duration}m)';
    }

    final fallback = _readString(classData, const ['time']);
    return fallback == null ? '${duration}m' : '$fallback (${duration}m)';
  }
}

class _CapacityPanel extends StatelessWidget {
  final Map<String, dynamic>? slot;
  final Map<String, dynamic> classData;
  final int bookedMemberCount;

  const _CapacityPanel({
    required this.slot,
    required this.classData,
    required this.bookedMemberCount,
  });

  @override
  Widget build(BuildContext context) {
    final slotBooked = _readInt(slot, const ['bookedCount', 'booked_count']);
    final booked = bookedMemberCount > 0 ? bookedMemberCount : slotBooked;
    final held = _readInt(slot, const ['heldCount', 'held_count']);
    final remaining = _readInt(slot, const [
      'spotsRemaining',
      'spots_remaining',
    ]);
    final capacity = _readInt(slot, const ['capacity']) == 0
        ? _readInt(classData, const ['capacity', 'maxMembers'])
        : _readInt(slot, const ['capacity']);
    final displayCapacity = capacity == 0 ? '--' : capacity.toString();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Max Member',
            style: AppTextStyles.xxs9Regular.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.group_outlined,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  '$booked/$displayCapacity Spots remaining',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.xxs9SemiBold.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (remaining > 0) ...[
                SizedBox(width: 4.w),
                AppText(
                  '($remaining left)',
                  style: AppTextStyles.xxs9Medium.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.error_rounded,
                size: 16.sp,
                color: AppColors.statusWarning,
              ),
              SizedBox(width: 8.w),
              AppText(
                '$held Spot Held',
                style: AppTextStyles.xxs9SemiBold.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RescheduleStatusPanel extends StatelessWidget {
  final String? status;
  final String? note;
  final String? requestedAt;
  final List<dynamic> slots;

  const _RescheduleStatusPanel({
    required this.status,
    required this.note,
    required this.requestedAt,
    required this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final noteText = note;
    final requestedAtText = _requestedAtText(requestedAt);
    final proposedSlots = slots
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .take(3)
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.statusWarningSubtle,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions_rounded,
                size: 18.sp,
                color: AppColors.statusWarning,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  _formatStatus(status ?? 'Pending approval'),
                  style: AppTextStyles.sm14SemiBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (noteText != null && noteText.isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              noteText,
              style: AppTextStyles.xs12Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (requestedAtText.isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              requestedAtText,
              style: AppTextStyles.xs12Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (proposedSlots.isNotEmpty) ...[
            SizedBox(height: 10.h),
            ...proposedSlots.map((slot) {
              return Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 16.sp,
                      color: AppColors.statusWarning,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AppText(
                        '${_slotDate(slot)}  ${_slotTime(slot)}',
                        style: AppTextStyles.xs12SemiBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (slots.length > proposedSlots.length) ...[
              SizedBox(height: 8.h),
              AppText(
                '+${slots.length - proposedSlots.length} more proposed slots',
                style: AppTextStyles.xs12Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatStatus(String value) {
    final words = value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1));
    return words.join(' ');
  }

  String _requestedAtText(String? value) {
    final parsedDate = value == null ? null : DateTime.tryParse(value);
    if (parsedDate == null) return '';
    return 'Requested ${DateFormat('d MMM yyyy, hh:mm a').format(parsedDate)}';
  }

  String _slotDate(Map<String, dynamic> slot) {
    final startAt = _readString(slot, const ['startAt', 'start_at']);
    final parsedStartAt = startAt == null ? null : DateTime.tryParse(startAt);
    if (parsedStartAt != null) {
      return DateFormat('d MMM yyyy').format(parsedStartAt);
    }

    final date = _readString(slot, const ['date', 'scheduledDate']);
    final parsedDate = date == null ? null : DateTime.tryParse(date);
    if (parsedDate != null) return DateFormat('d MMM yyyy').format(parsedDate);

    return date ?? '';
  }

  String _slotTime(Map<String, dynamic> slot) {
    final start = _timeText(
      _readString(slot, const ['startTime', 'start_time']),
    );
    final end = _timeText(_readString(slot, const ['endTime', 'end_time']));
    if (start.isEmpty && end.isEmpty) return '';
    return '$start - $end';
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        MediaQuery.of(context).padding.top + 14.h,
        16.w,
        22.h,
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
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 5.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                'Class Details',
                style: AppTextStyles.base16SemiBold.copyWith(
                  color: AppColors.textInverse,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          SizedBox(width: 38.w),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final List<_InfoItem> children;

  const _InfoPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Row(
        children: List.generate(children.length, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(child: children[index]),
                if (index != children.length - 1)
                  Container(
                    width: 1,
                    height: 38.h,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    color: AppColors.borderSecondary,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.xs12SemiBold.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8.h),
        AppText(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.sm14SemiBold.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Map<String, String> member;
  final Map<String, dynamic> booking;
  final bool isCompleting;
  final VoidCallback? onComplete;

  const _MemberTile({
    required this.member,
    required this.booking,
    required this.isCompleting,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  member['image'] ?? '',
                  width: 58.w,
                  height: 58.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 58.w,
                    height: 58.w,
                    color: AppColors.borderPrimary,
                    child: Icon(
                      Icons.person_rounded,
                      size: 24.sp,
                      color: AppColors.iconSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      member['name'] ?? 'Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.base16SemiBold.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      member['subtitle'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xs12SemiBold.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canShowTrainerComplete(booking)) ...[
            SizedBox(height: 12.h),
            _TrainerBookingButton(
              label: 'Mark as Complete',
              isLoading: isCompleting,
              onTap: isCompleting ? null : onComplete,
            ),
          ] else if (canShowTrainerWaitingForMember(booking)) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              height: 42.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: AppText(
                'Waiting for member confirmation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.xs12SemiBold.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrainerBookingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _TrainerBookingButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

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
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isLoading
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : AppText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.xs12SemiBold.copyWith(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: AppText(
        'No members joined yet',
        textAlign: TextAlign.center,
        style: AppTextStyles.sm14Medium.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: AppText(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.sm14Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RescheduleBottomSheet extends StatefulWidget {
  final String classId;
  final TrainerClassService classService;
  final int durationMinutes;

  const _RescheduleBottomSheet({
    required this.classId,
    required this.classService,
    required this.durationMinutes,
  });

  @override
  State<_RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<_RescheduleBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _syncEndTimeWithDuration();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.actionPrimary),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
      _errorText = null;
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.actionPrimary,
            primaryContainer: AppColors.actionPrimary,
            onPrimaryContainer: Colors.white,
            secondary: AppColors.actionPrimary,
            secondaryContainer: AppColors.actionPrimary,
            onSecondaryContainer: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (pickedTime == null) return;
    setState(() {
      if (isStart) {
        _startTime = pickedTime;
        _syncEndTimeWithDuration();
      } else {
        _endTime = pickedTime;
      }
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      setState(() => _errorText = 'Please select a proposed date.');
      return;
    }

    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (!endDateTime.isAfter(startDateTime)) {
      setState(() => _errorText = 'End time must be after start time.');
      return;
    }

    final durationMinutes = endDateTime.difference(startDateTime).inMinutes;
    if (widget.durationMinutes > 0 &&
        durationMinutes != widget.durationMinutes) {
      setState(
        () => _errorText = 'Proposed slot duration must match class duration.',
      );
      return;
    }

    final note = _noteController.text.trim();
    if (note.isEmpty) {
      setState(() => _errorText = 'Please add a reschedule note.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await widget.classService.requestReschedule(
        id: widget.classId,
        availableSlots: [
          AvailabilitySlotModel(
            date: DateFormat('yyyy-MM-dd').format(selectedDate),
            startTime: DateFormat('HH:mm').format(startDateTime),
            endTime: DateFormat('HH:mm').format(endDateTime),
          ),
        ],
        note: note,
      );

      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Could not request reschedule.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDate;
    final errorText = _errorText;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      'Request Reschedule',
                      style: AppTextStyles.xl20SemiBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      size: 24.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _SheetLabel('Proposed date'),
              SizedBox(height: 8.h),
              _SheetPickerField(
                value: selectedDate == null
                    ? 'Select date'
                    : DateFormat('d MMM yyyy').format(selectedDate),
                icon: Icons.calendar_month_outlined,
                onTap: _isSaving ? null : _pickDate,
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SheetLabel('Start Time'),
                        SizedBox(height: 8.h),
                        _SheetPickerField(
                          value: _formatSheetTime(_startTime),
                          icon: Icons.schedule_rounded,
                          onTap: _isSaving
                              ? null
                              : () => _pickTime(isStart: true),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SheetLabel('End Time'),
                        SizedBox(height: 8.h),
                        _SheetPickerField(
                          value: _formatSheetTime(_endTime),
                          icon: Icons.schedule_rounded,
                          onTap: _isSaving
                              ? null
                              : () => _pickTime(isStart: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _SheetLabel('Note'),
              SizedBox(height: 8.h),
              TextField(
                controller: _noteController,
                enabled: !_isSaving,
                maxLines: 3,
                cursorColor: AppColors.actionPrimary,
                decoration: InputDecoration(
                  hintText: 'Trainer is unavailable at the original time.',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.actionPrimary),
                  ),
                ),
              ),
              if (errorText != null) ...[
                SizedBox(height: 10.h),
                AppText(
                  errorText,
                  style: AppTextStyles.xs12Medium.copyWith(
                    color: AppColors.statusError,
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              GestureDetector(
                onTap: _isSaving ? null : _submit,
                child: Container(
                  height: 54.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isSaving
                        ? AppColors.actionSecondaryHover
                        : AppColors.actionSecondary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : AppText(
                          'Submit',
                          style: AppTextStyles.sm14SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSheetTime(TimeOfDay value) {
    return DateFormat(
      'hh:mm a',
    ).format(DateTime(2026, 1, 1, value.hour, value.minute));
  }

  void _syncEndTimeWithDuration() {
    final duration = widget.durationMinutes;
    if (duration <= 0) return;

    final end = DateTime(
      2026,
      1,
      1,
      _startTime.hour,
      _startTime.minute,
    ).add(Duration(minutes: duration));
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;

  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.sm14Medium.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _SheetPickerField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _SheetPickerField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                value,
                style: AppTextStyles.sm14Medium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(icon, size: 18.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}

String? _readString(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value == null || value is Map || value is Iterable) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return null;
}

int _readInt(Map<String, dynamic>? json, List<String> keys) {
  final value = _readString(json, keys);
  return int.tryParse(value ?? '') ??
      double.tryParse(value ?? '')?.round() ??
      0;
}

double _readDouble(Map<String, dynamic>? json, List<String> keys) {
  final value = _readString(json, keys);
  return double.tryParse(value ?? '') ?? 0;
}

String _displayClassType(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'IN_PERSON':
      return 'in person';
    case 'ONLINE':
      return 'online';
    default:
      return (value ?? 'N/A').toLowerCase();
  }
}

String _displaySessionFormat(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'PRIVATE':
      return 'One-to-one';
    case 'GROUP':
      return 'Group';
    default:
      return value ?? 'Session';
  }
}

String _timeText(String? value) {
  final text = value ?? '';
  final parts = text.split(':');
  if (parts.length < 2) return text;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return text;

  return DateFormat('hh:mm a').format(DateTime(2026, 1, 1, hour, minute));
}

Map<String, dynamic> _bookingActionSource(
  dynamic item,
  Map<String, dynamic> classData,
  Map<String, dynamic>? slot,
) {
  final booking = _asMap(item) ?? const <String, dynamic>{};
  final locationTime =
      _asMap(booking['locationTime']) ??
      _asMap(booking['location_time']) ??
      const <String, dynamic>{};

  String? first(List<String> keys) {
    return _readString(booking, keys) ??
        _readString(locationTime, keys) ??
        _readString(slot, keys) ??
        _readString(classData, keys);
  }

  return {
    ...booking,
    'bookingId': _readString(booking, const ['bookingId', 'booking_id', 'id']),
    'bookingStatus': first(const [
          'bookingStatus',
          'booking_status',
          'status',
        ]) ??
        'CONFIRMED',
    'paymentStatus': first(const ['paymentStatus', 'payment_status']) ?? '',
    'scheduledDate': first(const [
          'scheduledDate',
          'scheduled_date',
          'date',
          'slotDate',
          'slot_date',
        ]) ??
        '',
    'startTime': first(const [
          'startTime',
          'start_time',
          'time',
          'scheduledStartTime',
        ]) ??
        '',
    'endTime': first(const ['endTime', 'end_time', 'scheduledEndTime']),
    'startAt': first(const ['startAt', 'start_at']),
    'endAt': first(const ['endAt', 'end_at']),
    'memberCompletedAt': first(const [
      'memberCompletedAt',
      'member_completed_at',
    ]),
    'trainerCompletedAt': first(const [
      'trainerCompletedAt',
      'trainer_completed_at',
    ]),
    'completedAt': first(const ['completedAt', 'completed_at']),
  };
}

Map<String, String> _memberMap(dynamic item) {
  final booking = _asMap(item) ?? const <String, dynamic>{};
  final member =
      _asMap(booking['member']) ??
      _asMap(booking['memberUser']) ??
      _asMap(booking['user']) ??
      const <String, dynamic>{};
  final name =
      _readString(member, const [
        'name',
        'displayName',
        'display_name',
        'fullName',
        'full_name',
      ]) ??
      [
        _readString(member, const ['firstName', 'first_name']),
        _readString(member, const ['lastName', 'last_name']),
      ].whereType<String>().join(' ');
  final image =
      _readString(member, const [
        'imageUrl',
        'image_url',
        'profileImageUrl',
        'profile_image_url',
        'avatar',
      ]) ??
      '';

  return {
    'name': name.trim().isEmpty ? 'Member' : name,
    'subtitle': 'Yoga Flow - 5 Series Workout',
    'image': image,
  };
}
