import 'package:fitness/controllers/member/member_notification_controller.dart';
import 'package:fitness/Helpers/route.dart';
import 'package:fitness/core/storage/token_storage.dart';
import 'package:fitness/models/app_notification_model.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MemberNotificationController>()
        ? Get.find<MemberNotificationController>()
        : Get.put(MemberNotificationController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.actionPrimary,
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchNotifications(showError: true),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 96.h,
                    ),
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textTertiary,
                        size: 46.sp,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        controller.errorMessage.value.isNotEmpty
                            ? controller.errorMessage.value
                            : 'No notifications yet.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sm14Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(showError: true),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: () => controller.openNotification(notification),
                      onDelete: () =>
                          controller.deleteNotification(notification.id),
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

  Widget _buildHeader(
    BuildContext context,
    MemberNotificationController controller,
  ) {
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
          GestureDetector(
            onTap: () {
              _goBack(context);
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                "Notification",
                style: AppTextStyles.base16SemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          Obx(() {
            final hasNotifications = controller.notifications.isNotEmpty;
            return PopupMenuButton<String>(
              enabled: hasNotifications,
              color: Colors.white,
              icon: Icon(
                Icons.more_vert_rounded,
                color: hasNotifications
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
              onSelected: (value) {
                if (value == 'read_all') controller.markAllAsRead();
                if (value == 'clear_all') controller.deleteAllNotifications();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'read_all', child: Text('Mark all read')),
                PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _goBack(BuildContext context) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    final role = (await TokenStorage().getUserRole())?.toLowerCase();
    Get.offAllNamed(
      role == 'trainer'
          ? AppRoutes.trainerBottomNavScreen
          : AppRoutes.memberBottomNavScreen,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRead
                ? AppColors.borderSecondary
                : AppColors.actionPrimary.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: isRead ? 0.12 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(_icon, color: _iconColor, size: 23.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sm14SemiBold.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!isRead) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 9.w,
                          height: 9.w,
                          decoration: const BoxDecoration(
                            color: AppColors.actionPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    SizedBox(height: 5.h),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.xs12Regular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTime(notification.createdAt),
                          style: AppTextStyles.xs12Regular.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.statusError,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case 'CHAT_MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      case 'BOOKING_PAYMENT_FAILED':
        return Icons.payment_rounded;
      case 'BOOKING_CONFIRMED':
      case 'BOOKING_RESCHEDULE_REQUESTED':
      case 'BOOKING_RESCHEDULED':
      case 'BOOKING_COMPLETED':
      case 'CLASS_CANCELLED':
        return Icons.event_available_rounded;
      case 'ACCOUNT_VERIFICATION_APPROVED':
      case 'ACCOUNT_VERIFICATION_REJECTED':
        return Icons.verified_user_outlined;
      case 'TRAINER_REVIEW_RECEIVED':
        return Icons.star_border_rounded;
      case 'TEST_PUSH':
        return Icons.notification_important_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get _iconColor {
    if (notification.type == 'BOOKING_PAYMENT_FAILED' ||
        notification.type == 'ACCOUNT_VERIFICATION_REJECTED') {
      return AppColors.statusError;
    }
    return AppColors.actionPrimary;
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';

    final local = value.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat('MMM d, yyyy').format(local);
  }
}
