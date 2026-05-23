import 'package:fitness/utils/AppColor/app_colors.dart';
import 'package:fitness/utils/AppTextStyle/app_text_styles.dart';
import 'package:fitness/views/Base/AppText/appText.dart';
import 'package:fitness/views/Base/AppButton/appButton.dart';
import 'package:fitness/views/Base/CustomTextfield/CustomTextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int _selectedTab = 0; // 0 for FAQ, 1 for Ticket
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _faqItems = [
    {
      "question": "What is Hers Fitness?",
      "answer": "Hers Fitness is a personalized fitness app designed specifically for women, offering workout plans, diet guidance, and wellness tracking tailored to individual goals.",
      "isExpanded": true,
    },
    {
      "question": "How does Hers Fitness work?",
      "answer": "You can browse classes, book sessions with trainers, and track your progress all in one app.",
      "isExpanded": false,
    },
    {
      "question": "Is Hers Fitness only for women?",
      "answer": "Yes, our community and programs are specifically tailored for women's fitness needs.",
      "isExpanded": false,
    },
    {
      "question": "Is Hers Fitness free to use?",
      "answer": "We offer both free content and premium subscription plans.",
      "isExpanded": false,
    },
    {
      "question": "Is my data secure?",
      "answer": "Absolutely. We use industry-standard encryption to protect your personal information.",
      "isExpanded": false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _problemController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                _buildTabs(),
                Expanded(
                  child: _selectedTab == 0 ? _buildFAQView() : _buildTicketView(),
                ),
              ],
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
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                "Help Center",
                style: AppTextStyles.base16SemiBold.copyWith(color: Colors.white, fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 44.w)
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("FAQ", 0)),
          Expanded(child: _buildTabButton("Ticket", 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.actionPrimary.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: AppText(
            title,
            style: AppTextStyles.base16Medium.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQView() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      children: [
        CustomTextField(
          controller: _searchController,
          hintText: "Search our FAQ...",
          suffixIcon: const Icon(Icons.search, color: Colors.black),
          borderColor: AppColors.actionPrimary.withValues(alpha: 0.3),
        ),
        SizedBox(height: 24.h),
        ..._faqItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          return _buildFAQItem(item, idx);
        }),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> item, int index) {
    bool isExpanded = item["isExpanded"];
    return GestureDetector(
      onTap: () {
        setState(() {
          _faqItems[index]["isExpanded"] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            if (!isExpanded)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    item["question"],
                    style: AppTextStyles.sm14Medium.copyWith(
                      color: isExpanded ? Colors.white : Colors.black,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isExpanded ? AppColors.actionPrimary.withValues(alpha: 0.8) : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isExpanded ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? Colors.white : Colors.black,
                    size: 20.w,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 16.h),
              AppText(
                item["answer"],
                style: AppTextStyles.sm14Regular.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _problemController,
            hintText: "Tell us your problame...", // following typo in screenshot
            borderColor: AppColors.actionPrimary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: "e.g. My app is not workin...",
                    border: InputBorder.none,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.description_outlined, size: 16.w, color: Colors.grey),
                    SizedBox(width: 4.w),
                    AppText("2/10", style: AppTextStyles.xs12Regular.copyWith(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          AppButton(
            onTap: () {},
            text: 'Send',
          ),
        ],
      ),
    );
  }
}
