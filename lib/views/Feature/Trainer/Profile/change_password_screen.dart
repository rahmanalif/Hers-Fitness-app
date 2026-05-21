import 'package:fitness/controllers/trainer/trainer_profile_controller.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:fitness/views/Base/AppButton/appButton.dart';
import 'package:fitness/views/Base/CustomTextfield/CustomTextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fitness/utils/app_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final TrainerProfileController _profileController;

  bool _currentObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<TrainerProfileController>()
        ? Get.find<TrainerProfileController>()
        : Get.put(TrainerProfileController());
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showAppSnackbar(
        'Missing information',
        'Please fill all password fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showAppSnackbar(
        'Password mismatch',
        'New password and confirm password do not match.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await _profileController.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmPassword,
    );

    if (!success) return;

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Current Password"),
                  CustomTextField(
                    controller: _currentPasswordController,
                    hintText: "******",
                    isPassword: _currentObscure,
                    prefixIcon: "assets/icons/lock.svg",
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _currentObscure = !_currentObscure),
                      child: Icon(
                        _currentObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.w,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildLabel("New Password"),
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: "******",
                    isPassword: _newObscure,
                    prefixIcon: "assets/icons/lock.svg",
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _newObscure = !_newObscure),
                      child: Icon(
                        _newObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.w,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildLabel("Confirm Password"),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: "******",
                    isPassword: _confirmObscure,
                    prefixIcon: "assets/icons/lock.svg",
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _confirmObscure = !_confirmObscure),
                      child: Icon(
                        _confirmObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.w,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildPasswordStrength(),
                  SizedBox(height: 12.h),
                  AppText(
                    "Weak password! Let’s add more strength!",
                    style: AppTextStyles.sm14Regular.copyWith(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 40.h),
                  Obx(
                    () => AppButton(
                      isLoading: _profileController.isChangingPassword.value,
                      onTap: _profileController.isChangingPassword.value
                          ? () {}
                          : _submitChangePassword,
                      text: 'Save Changes',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            onTap: () => Get.back(),
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
                "Change Password",
                style: AppTextStyles.base16SemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppText(
        text,
        style: AppTextStyles.base16SemiBold.copyWith(
          color: AppColors.textPrimary,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 8.w),
            decoration: BoxDecoration(
              color: index == 0
                  ? AppColors.actionPrimary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }),
    );
  }
}
