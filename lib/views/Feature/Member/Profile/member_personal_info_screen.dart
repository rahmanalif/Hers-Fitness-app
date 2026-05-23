import 'package:fitness/controllers/member/member_profile_controller.dart';
import 'package:fitness/models/user_profile_model.dart';
import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../Base/AppButton/appButton.dart';
import '../../../Base/CustomTextfield/CustomTextfield.dart';
import 'package:fitness/utils/app_snackbar.dart';

class MemberPersonalInfoScreen extends StatefulWidget {
  const MemberPersonalInfoScreen({super.key});

  @override
  State<MemberPersonalInfoScreen> createState() =>
      _MemberPersonalInfoScreenState();
}

class _MemberPersonalInfoScreenState extends State<MemberPersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late final MemberProfileController _profileController;
  Worker? _profileWorker;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<MemberProfileController>()
        ? Get.find<MemberProfileController>()
        : Get.put(MemberProfileController());
    _profileWorker = ever<UserProfileModel?>(
      _profileController.user,
      _populateProfile,
    );
    _populateProfile(_profileController.user.value);
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  void _populateProfile(UserProfileModel? user) {
    if (user == null) return;

    _nameController.text = user.displayName;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _stateController.text = user.state ?? '';
    _locationController.text = user.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Full Name"),
                  CustomTextField(
                    prefixIcon: "assets/icons/personIcon.svg",
                    hintText: "Enter your name",
                    controller: _nameController,
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel("Email Address"),
                  CustomTextField(
                    hintText: "Enter your E-mail",
                    controller: _emailController,
                    prefixIcon: "assets/icons/emailIcon.svg",
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel("Phone number"),
                  CustomTextField(
                    prefixIcon: Icon(Icons.phone_outlined, size: 20.w),
                    hintText: "(229) 555-0109",
                    controller: _phoneController,
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel("Your state"),
                  CustomTextField(
                    hintText: "Enter your state",
                    controller: _stateController,
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel("Location"),
                  CustomTextField(
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20.w),
                    hintText: "Syracuse, Connecticut",
                    controller: _locationController,
                  ),
                  SizedBox(height: 32.h),

                  AppButton(onTap: () {}, text: "Save Settings"),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 230.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Pink Background
          Container(
            height: 160.h,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.of(context).padding.top + 10.h,
              20.w,
              0,
            ),
            decoration: BoxDecoration(
              color: AppColors.actionPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Center(
                      child: AppText(
                        "Personal Info",
                        style: AppTextStyles.base16SemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 44.w),
              ],
            ),
          ),
          // 2. Profile Image
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() {
                final imageUrl = _profileController.profileImageUrl;

                return Container(
                  width: 87.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: AppColors.bgSecondary,
                    image: imageUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                  child: imageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 38.w,
                        )
                      : null,
                );
              }),
            ),
          ),
          // 3. Edit Icon
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showAppSnackbar(
                    "Edit Image",
                    "Image edit clicked!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(16),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/editIcon.svg",
                      color: Colors.white,
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                ),
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
        style: AppTextStyles.sm14Medium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
