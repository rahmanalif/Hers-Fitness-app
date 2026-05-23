import 'dart:io';

import 'package:fitness/controllers/common/chat_controller.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/CustomTextfield/CustomTextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatContact contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;
  late final Worker _messagesWorker;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.openConversation(widget.contact);
    });
    _messagesWorker = ever<List<ChatMessage>>(
      controller.messages,
      (_) => _scrollToBottomIfNeeded(),
    );
  }

  @override
  void dispose() {
    _messagesWorker.dispose();
    _scrollController.dispose();
    controller.closeActiveConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildTopGradient(context),
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
              _buildMessageInput(),
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
      height: MediaQuery.of(context).padding.top + 180.h,
      child: IgnorePointer(
        child: DecoratedBox(
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
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: 60.h,
        bottom: 16.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20.sp,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Obx(() {
            final selected = controller.selectedContact.value ?? widget.contact;
            return _buildAvatar(
              selected.avatarUrl,
              42.w,
              selected.isParticipantActive,
            );
          }),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() {
              final selected =
                  controller.selectedContact.value ?? widget.contact;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.base16Medium.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    controller.isParticipantTyping.value
                        ? 'Typing...'
                        : selected.isParticipantActive
                        ? 'Active now'
                        : 'Offline',
                    style: AppTextStyles.xs12Regular.copyWith(
                      color:
                          selected.isParticipantActive ||
                              controller.isParticipantTyping.value
                          ? Colors.green
                          : AppColors.textTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.actionPrimary),
        );
      }

      if (controller.messagesError.value.isNotEmpty &&
          controller.messages.isEmpty) {
        return _ErrorState(
          message: controller.messagesError.value,
          onRetry: () =>
              controller.fetchMessages(widget.contact.id, showError: true),
        );
      }

      if (controller.messages.isEmpty) {
        return Center(
          child: Text(
            'No messages yet.',
            style: AppTextStyles.sm14Medium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        itemCount:
            controller.messages.length +
            (controller.isParticipantTyping.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.messages.length) {
            return _TypingIndicator(avatarUrl: widget.contact.avatarUrl);
          }

          final message = controller.messages[index];
          final showTimeDivider =
              index == 0 ||
              controller.messages[index].time !=
                  controller.messages[index - 1].time;

          return Column(
            children: [
              if (showTimeDivider) _buildTimeDivider(message.time),
              _buildMessageBubble(message),
            ],
          );
        },
      );
    });
  }

  Widget _buildTimeDivider(String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.borderPrimary)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              time,
              style: AppTextStyles.xs12Regular.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.borderPrimary)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            _buildAvatar(widget.contact.avatarUrl, 30.w, false),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? Colors.black
                        : const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child:
                      message.messageType == 'IMAGE' &&
                          message.attachmentUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: _buildMessageImage(message.attachmentUrl!),
                        )
                      : Text(
                          message.text,
                          style: AppTextStyles.sm14Medium.copyWith(
                            color: message.isMe
                                ? Colors.white
                                : AppColors.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                ),
                if (message.isMe)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, right: 4.w),
                    child: Text(
                      message.isFailed
                          ? 'Failed'
                          : message.isPending
                          ? 'Sending...'
                          : message.seenAt != null
                          ? 'Seen'
                          : 'Sent',
                      style: AppTextStyles.xxs9Regular.copyWith(
                        color: message.isFailed
                            ? AppColors.statusError
                            : AppColors.textTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        top: 14.h,
        bottom: MediaQuery.of(context).padding.bottom + 14.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final enabled = controller.canPickImage;
              return CustomTextField(
                controller: controller.messageController,
                hintText: 'Type a message...',
                filColor: Colors.white,
                borderColor: const Color(0xFFEBEBEB),
                borderRadius: 20.r,
                maxLines: 1,
                onSubmitted: (_) => controller.sendMessage(),
                suffixIcon: GestureDetector(
                  onTap: enabled ? _showImageSourceSheet : null,
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    child: controller.isSendingImage.value
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              color: AppColors.actionPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textTertiary,
                            size: 24.sp,
                          ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final enabled = controller.canSend;
            return GestureDetector(
              onTap: enabled ? () => controller.sendMessage() : null,
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: controller.isSending.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Transform.rotate(
                          angle: -0.5,
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageImage(String imageUrl) {
    final isRemote =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    if (!isRemote) {
      return Image.file(File(imageUrl), width: 190.w, fit: BoxFit.cover);
    }

    return Image.network(imageUrl, width: 190.w, fit: BoxFit.cover);
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          18.h,
          20.w,
          MediaQuery.of(context).padding.bottom + 18.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ImageSourceButton(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: () {
                  Get.back();
                  controller.pickAndSendImage(ImageSource.camera);
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ImageSourceButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () {
                  Get.back();
                  controller.pickAndSendImage(ImageSource.gallery);
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildAvatar(String? avatarUrl, double size, bool isActive) {
    final avatar = avatarUrl != null && avatarUrl.isNotEmpty
        ? ClipOval(
            child: Image.network(
              avatarUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarFallback(size),
            ),
          )
        : _avatarFallback(size);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.grey[600], size: 20.sp),
    );
  }

  void _scrollToBottomIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final distanceFromBottom = position.maxScrollExtent - position.pixels;
      if (distanceFromBottom > 180 && controller.messages.length > 1) return;

      _scrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderSecondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.sm14Medium.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String? avatarUrl;

  const _TypingIndicator({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.grey[600], size: 20.sp),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              'Typing...',
              style: AppTextStyles.sm14Medium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.sm14Medium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
