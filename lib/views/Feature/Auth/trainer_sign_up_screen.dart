import '../../Base/ProfilePicPicker/profile_pic_picker.dart';
import 'package:fitness/Helpers/route.dart';
import 'package:fitness/controllers/auth/trainer_register_controller.dart';
import 'package:fitness/views/Base/AppButton/appButton.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/AppColor/app_colors.dart';
import '../../../utils/AppTextStyle/app_text_styles.dart';
import '../../Base/CustomTextfield/CustomTextfield.dart';

class TrainerSignUpScreen extends StatefulWidget {
  const TrainerSignUpScreen({super.key});

  @override
  State<TrainerSignUpScreen> createState() => _TrainerSignUpScreenState();
}

class _TrainerSignUpScreenState extends State<TrainerSignUpScreen> {
  late final TrainerRegisterController registerController;

  @override
  void initState() {
    super.initState();
    registerController = Get.isRegistered<TrainerRegisterController>()
        ? Get.find<TrainerRegisterController>()
        : Get.put(TrainerRegisterController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.0, -1.0),
                radius: 2.5,
                colors: [
                  const Color(0xFFFFA6B4).withValues(alpha: 0.5),
                  const Color(0xFFFFE0B9).withValues(alpha: 0.25),
                  Colors.white,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  Image.asset("assets/images/sigupImg.png"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  // Profile picture picker
                  ProfilePicPicker(
                    placeholderImage:
                        "assets/images/trainerImg.png", // Placeholder
                    onImagePicked: registerController.setProfileImage,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.actionPrimary,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 18.h),

                          _buildLabel("Enter your name"),
                          CustomTextField(
                            hintText: 'Enter your name',
                            controller: registerController.nameController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/personIcon.svg",
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Enter your email"),
                          CustomTextField(
                            hintText: 'Enter your E-mail',
                            controller: registerController.emailController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/emailIcon.svg",
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Phone number"),
                          CustomTextField(
                            hintText: '(229) 555-0109',
                            controller: registerController.phoneController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/phoneIcon.svg",
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Your state"),
                          CustomTextField(
                            hintText: 'Select your state',
                            controller: registerController.stateController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Your location"),
                          CustomTextField(
                            hintText: 'Syracuse, Connecticut',
                            controller: registerController.locationController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/locationIcon.svg",
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Personal Bio"),
                          _buildAreaFieldWithCounter(
                            'e.g. NASM CPT',
                            registerController.bioController,
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("What fitness classes do you teach?"),
                          Stack(
                            children: [
                              CustomTextField(
                                hintText: 'Strength Training|',
                                controller:
                                    registerController.classesTaughtController,
                                filColor: AppColors.bgPrimary,
                                borderColor: AppColors.actionPrimary,
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    left: 12.w,
                                    top: 10.h,
                                    bottom: 10.h,
                                    right: 8.w,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFDE8E8,
                                      ), // Very light pink
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: AppText(
                                      "Yoga",
                                      style: AppTextStyles.sm14Medium.copyWith(
                                        color: AppColors.actionPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 14.h,
                                right: 12.w,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 14,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    SizedBox(width: 4.w),
                                    AppText(
                                      "2/10",
                                      style: AppTextStyles.sm14Regular.copyWith(
                                        color: const Color(0xFF6B7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("How long have you been an instructor?"),
                          CustomTextField(
                            hintText: '2yr',
                            controller: registerController
                                .instructorExperienceController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/calendarIcon.svg",
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel(
                            "What certifications/qualifications do you have?",
                          ),
                          _buildAreaFieldWithCounter(
                            'e.g. NASM CPT',
                            registerController.certificationsController,
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel(
                            "Do you host classes online or in person?",
                          ),
                          CustomTextField(
                            hintText: 'e.g. Online, In person, or Both',
                            controller:
                                registerController.classDeliveryModeController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Password"),
                          CustomTextField(
                            hintText: '******',
                            controller: registerController.passwordController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/lock.svg",
                            isPassword: true,
                          ),
                          SizedBox(height: 16.h),

                          _buildLabel("Confirm Password"),
                          CustomTextField(
                            hintText: '******',
                            controller:
                                registerController.confirmPasswordController,
                            filColor: AppColors.bgPrimary,
                            borderColor: AppColors.actionPrimary,
                            prefixIcon: "assets/icons/lock.svg",
                            isPassword: true,
                          ),
                          SizedBox(height: 12.h),

                          // Password strength indicator
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7869A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          AppText(
                            "Weak password! Let's add more strength!",
                            style: AppTextStyles.sm14Regular.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.040,
                          ),

                          Obx(
                            () => AppButton(
                              text: "Sign up",
                              isLoading: registerController.isLoading.value,
                              onTap: registerController.isLoading.value
                                  ? () {}
                                  : registerController
                                        .continueToIdentityVerification,
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.040,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                "Don't have already an account? ",
                                style: AppTextStyles.sm14Regular.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.signInScreen);
                                },
                                child: AppText(
                                  "Login",
                                  style: AppTextStyles.sm14SemiBold.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.040,
                          ),
                        ],
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppText(
        text,
        style: AppTextStyles.base16Medium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAreaFieldWithCounter(
    String hint,
    TextEditingController controller,
  ) {
    return Stack(
      children: [
        CustomTextField(
          hintText: hint,
          controller: controller,
          filColor: AppColors.bgPrimary,
          borderColor: AppColors.actionPrimary,
          maxLines: 4,
        ),
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 14,
                color: const Color(0xFF6B7280),
              ),
              SizedBox(width: 4.w),
              AppText(
                "2/10",
                style: AppTextStyles.sm14Regular.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
