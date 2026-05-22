import 'package:fitness/core/network/api_client.dart';
import 'package:fitness/core/network/api_endpoints.dart';
import 'package:fitness/models/member_activity_model.dart';
import 'package:fitness/models/user_profile_model.dart';

class UserService {
  UserService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<UserProfileModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.currentUser);
    return UserProfileModel.fromJson(_asMap(response));
  }

  Future<MemberMonthlyActivityModel> getMemberMonthlyActivity({
    required int year,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.memberMonthlyActivity,
      queryParameters: {'year': year},
    );
    return MemberMonthlyActivityModel.fromJson(_asMap(response));
  }

  Future<MemberWeeklyActivityModel> getMemberWeeklyActivity({
    DateTime? date,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.memberWeeklyActivity,
      queryParameters: date == null
          ? null
          : {
              'date':
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            },
    );
    return MemberWeeklyActivityModel.fromJson(_asMap(response));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await _apiClient.put(
      ApiEndpoints.users,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw const ApiException('Invalid server response');
  }
}
