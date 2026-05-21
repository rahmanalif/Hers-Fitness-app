import 'package:fitness/utils/auth_role.dart';
import 'package:fitness/utils/image_url.dart';

class UserProfileModel {
  final String? id;
  final String? trainerUserId;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? role;
  final String? imageUrl;
  final String? state;
  final String? location;
  final String? bio;
  final String? accountStatus;

  const UserProfileModel({
    this.id,
    this.trainerUserId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.role,
    this.imageUrl,
    this.state,
    this.location,
    this.bio,
    this.accountStatus,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = _object(json['data']) ?? json;
    final source = _object(data['user']) ?? data;
    final profile =
        _object(data['profile']) ??
        _object(data['memberProfile']) ??
        _object(data['member_profile']) ??
        _object(data['trainerProfile']) ??
        _object(data['trainer_profile']) ??
        _object(source['profile']) ??
        _object(source['memberProfile']) ??
        _object(source['member_profile']) ??
        _object(source['trainerProfile']) ??
        _object(source['trainer_profile']) ??
        const <String, dynamic>{};

    final firstName = _readString(source, const ['firstName', 'first_name']);
    final lastName = _readString(source, const ['lastName', 'last_name']);
    final combinedName = [
      firstName,
      lastName,
    ].where((value) => value != null && value.trim().isNotEmpty).join(' ');

    return UserProfileModel(
      id: _readString(source, const ['id', 'userId', 'user_id']),
      trainerUserId:
          _readString(profile, const [
            'trainerUserId',
            'trainer_user_id',
            'userId',
            'user_id',
          ]) ??
          _readString(data, const ['trainerUserId', 'trainer_user_id']),
      firstName: firstName,
      lastName: lastName,
      fullName:
          _readString(source, const [
            'name',
            'displayName',
            'display_name',
            'fullName',
            'full_name',
          ]) ??
          (combinedName.isEmpty ? null : combinedName),
      email: _readString(source, const ['email']),
      phoneNumber: _readString(source, const [
        'phoneNumber',
        'phone_number',
        'phone',
      ]),
      gender: _readString(source, const ['gender']),
      role: normalizeUserRole(data) ?? normalizeUserRole(source),
      imageUrl: _readImageUrl(source, profile),
      state:
          _readString(source, const ['state']) ??
          _readString(profile, const ['state']),
      location:
          _readString(source, const ['location', 'address']) ??
          _readString(profile, const ['location', 'address']),
      bio:
          _readString(source, const ['bio', 'description']) ??
          _readString(profile, const ['bio', 'description']),
      accountStatus:
          _readString(source, const [
            'accountStatus',
            'account_status',
            'approvalStatus',
            'approval_status',
            'status',
          ]) ??
          _readString(profile, const [
            'accountStatus',
            'account_status',
            'approvalStatus',
            'approval_status',
            'status',
          ]),
    );
  }

  String get displayName {
    final value = fullName?.trim();
    if (value != null && value.isNotEmpty) return value;

    final combinedName = [
      firstName,
      lastName,
    ].where((value) => value != null && value.trim().isNotEmpty).join(' ');
    if (combinedName.isNotEmpty) return combinedName;

    final emailValue = email?.trim();
    if (emailValue != null && emailValue.isNotEmpty) {
      return emailValue.split('@').first;
    }

    final roleValue = role?.trim().toLowerCase();
    if (roleValue == 'member') return 'Member';
    if (roleValue == 'admin') return 'Admin';

    return 'Trainer';
  }

  String get displayLocation {
    final locationValue = location?.trim();
    if (locationValue != null && locationValue.isNotEmpty) {
      return locationValue;
    }

    final stateValue = state?.trim();
    if (stateValue != null && stateValue.isNotEmpty) {
      return stateValue;
    }

    return 'Location not added';
  }

  static Map<String, dynamic>? _object(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is Map || value is Iterable) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return null;
  }

  static const List<String> _imageKeys = [
    'image',
    'imageUrl',
    'image_url',
    'profileImage',
    'profileImageUrl',
    'profile_image',
    'profile_image_url',
    'profilePicture',
    'profilePictureUrl',
    'profile_picture',
    'profile_picture_url',
    'photo',
    'photoUrl',
    'photo_url',
    'avatar',
    'avatarUrl',
    'avatar_url',
    'url',
    'secureUrl',
    'secure_url',
    'path',
    'fileUrl',
    'file_url',
  ];

  static const List<String> _imageObjectKeys = [
    'image',
    'profileImage',
    'profileImageUrl',
    'profile_image',
    'profile_image_url',
    'profilePicture',
    'profilePictureUrl',
    'profile_picture',
    'profile_picture_url',
    'photo',
    'avatar',
  ];

  static String? _readImageUrl(
    Map<String, dynamic> source,
    Map<String, dynamic> profile,
  ) {
    final directValue =
        _readString(source, _imageKeys) ?? _readString(profile, _imageKeys);
    final nestedValue =
        _readNestedImageUrl(source) ?? _readNestedImageUrl(profile);

    return normalizeImageUrl(directValue ?? nestedValue);
  }

  static String? _readNestedImageUrl(Map<String, dynamic> json) {
    for (final key in _imageObjectKeys) {
      final image = _object(json[key]);
      if (image == null) continue;

      final value = _readString(image, _imageKeys);
      if (value != null) return value;
    }

    return null;
  }
}
