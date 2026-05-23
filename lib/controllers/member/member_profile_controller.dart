
import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/core/storage/local_storage.dart';
import 'package:fitness/models/member_activity_model.dart';
import 'package:fitness/models/user_profile_model.dart';
import 'package:fitness/services/member_assessment_service.dart';
import 'package:fitness/services/user_service.dart';
import 'package:get/get.dart';
import 'package:fitness/utils/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class MemberProfileController extends GetxController {
  MemberProfileController({
    UserService? userService,
    MemberAssessmentService? assessmentService,
  }) : _userService = userService ?? UserService(),
       _assessmentService = assessmentService ?? MemberAssessmentService();

  final UserService _userService;
  final MemberAssessmentService _assessmentService;
  final _localStorage = LocalStorage();

  final user = Rxn<UserProfileModel>();
  final assessment = Rxn<Map<String, dynamic>>();
  final weeklyActivity = Rxn<MemberWeeklyActivityModel>();
  final monthlyActivity = Rxn<MemberMonthlyActivityModel>();
  final isLoading = false.obs;
  final isLoadingActivity = false.obs;
  final coverPhotoUrl = RxString('');

  @override
  void onInit() {
    super.onInit();
    fetchProfile(showError: true);
    fetchActivity();
    loadCoverPhoto();
  }

  String get displayName => user.value?.displayName ?? 'Member';

  String get displayLocation =>
      user.value?.displayLocation ?? 'Location not added';

  String get profileImageUrl => user.value?.imageUrl?.trim() ?? '';

  String get age => assessment.value?['age']?.toString() ?? '--';
  String get weight => assessment.value?['weight']?.toString() ?? '--';
  String get dietPreference {
    final raw = assessment.value?['dietPreference']?.toString();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') return 'Not Set';
    
    // Format enum-like strings: "CARBO_DIET" -> "Carbo Diet"
    return raw.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  int get weeklyCompletedSessions =>
      weeklyActivity.value?.totalCompletedSessions ?? 0;

  int get yearlyCompletedSessions =>
      monthlyActivity.value?.totalCompletedSessions ?? 0;

  Future<void> loadCoverPhoto() async {
    final path = await _localStorage.getMemberCoverPhoto();
    if (path != null) {
      coverPhotoUrl.value = path;
    }
  }

  Future<void> pickCoverPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _localStorage.saveMemberCoverPhoto(image.path);
      coverPhotoUrl.value = image.path;
    }
  }

  Future<void> fetchAssessment({bool showError = false}) async {
    try {
      final response = await _assessmentService.getAssessment();
      if (response != null) {
        // Handle both wrapped and unwrapped responses
        final data = response['data'] ?? response;
        if (data is Map<String, dynamic>) {
          assessment.value = data;
        }
      }
    } on ApiException catch (error) {
      if (showError) {
        showAppSnackbar(
          'Assessment failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (showError) {
        showAppSnackbar(
          'Assessment failed',
          'Could not load assessment information.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> fetchProfile({bool showError = false}) async {
    try {
      isLoading.value = true;
      user.value = await _userService.getCurrentUser();
      await fetchAssessment(showError: showError);
    } on ApiException catch (error) {
      if (showError) {
        showAppSnackbar(
          'Profile failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (showError) {
        showAppSnackbar(
          'Profile failed',
          'Could not load profile information.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActivity({
    int? year,
    DateTime? weekDate,
    bool showError = false,
  }) async {
    final activityYear = year ?? DateTime.now().year;
    try {
      isLoadingActivity.value = true;
      final results = await Future.wait([
        _userService.getMemberWeeklyActivity(date: weekDate),
        _userService.getMemberMonthlyActivity(year: activityYear),
      ]);
      weeklyActivity.value = results[0] as MemberWeeklyActivityModel;
      monthlyActivity.value = results[1] as MemberMonthlyActivityModel;
    } on ApiException catch (error) {
      weeklyActivity.value ??= MemberWeeklyActivityModel.empty(weekDate);
      monthlyActivity.value ??= MemberMonthlyActivityModel.empty(activityYear);
      if (showError) {
        showAppSnackbar(
          'Activity failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      weeklyActivity.value ??= MemberWeeklyActivityModel.empty(weekDate);
      monthlyActivity.value ??= MemberMonthlyActivityModel.empty(activityYear);
      if (showError) {
        showAppSnackbar(
          'Activity failed',
          'Could not load activity data.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingActivity.value = false;
    }
  }

  Future<void> fetchMonthlyActivity(int year, {bool showError = false}) async {
    try {
      isLoadingActivity.value = true;
      monthlyActivity.value = await _userService.getMemberMonthlyActivity(
        year: year,
      );
    } on ApiException catch (error) {
      monthlyActivity.value ??= MemberMonthlyActivityModel.empty(year);
      if (showError) {
        showAppSnackbar(
          'Activity failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      monthlyActivity.value ??= MemberMonthlyActivityModel.empty(year);
      if (showError) {
        showAppSnackbar(
          'Activity failed',
          'Could not load activity data.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingActivity.value = false;
    }
  }
}
