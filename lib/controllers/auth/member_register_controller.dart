import 'dart:io';

import 'package:fitness/Helpers/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness/utils/app_snackbar.dart';

class MemberRegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final stateController = TextEditingController();
  final locationController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final imagePath = RxnString();

  void setProfileImage(File file) {
    imagePath.value = file.path;
  }

  void continueToIdentityVerification() {
    final validationMessage = _validate();
    if (validationMessage != null) {
      showAppSnackbar(
        'Registration incomplete',
        validationMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.verifyIdentityScreen,
      arguments: {'role': 'member', 'memberRegisterDraft': _draft},
    );
  }

  void continueToPasswordVerification() {
    continueToIdentityVerification();
  }

  Map<String, String>? get identityVerificationDraft {
    if (_validate() != null) return null;
    return _draft;
  }

  Map<String, String> get _draft {
    return {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'state': stateController.text.trim(),
      'location': locationController.text.trim(),
      'password': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
      'imagePath': imagePath.value!,
    };
  }

  String? _validate() {
    final requiredValues = {
      'name': nameController.text,
      'email': emailController.text,
      'phone number': phoneController.text,
      'state': stateController.text,
      'location': locationController.text,
      'password': passwordController.text,
      'confirm password': confirmPasswordController.text,
    };

    for (final entry in requiredValues.entries) {
      if (entry.value.trim().isEmpty) {
        return 'Please enter ${entry.key}.';
      }
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Password and confirm password do not match.';
    }

    if (imagePath.value == null) {
      return 'Please select a profile image.';
    }

    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    stateController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
