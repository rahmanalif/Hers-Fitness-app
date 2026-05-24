class NotificationPreferencesModel {
  final bool newBooking;
  final bool classReminder;
  final bool paymentReceived;
  final bool classCheckIn;
  final bool systemAnnouncements;
  final bool emailNotifications;
  final bool pushNotifications;

  const NotificationPreferencesModel({
    this.newBooking = true,
    this.classReminder = true,
    this.paymentReceived = true,
    this.classCheckIn = true,
    this.systemAnnouncements = false,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return NotificationPreferencesModel(
      newBooking: _bool(data['newBooking'], defaultValue: true),
      classReminder: _bool(data['classReminder'], defaultValue: true),
      paymentReceived: _bool(data['paymentReceived'], defaultValue: true),
      classCheckIn: _bool(data['classCheckIn'], defaultValue: true),
      systemAnnouncements:
          _bool(data['systemAnnouncements'], defaultValue: false),
      emailNotifications:
          _bool(data['emailNotifications'], defaultValue: true),
      pushNotifications:
          _bool(data['pushNotifications'], defaultValue: true),
    );
  }

  /// Returns a copy with the named field overridden.
  NotificationPreferencesModel copyWith({
    bool? newBooking,
    bool? classReminder,
    bool? paymentReceived,
    bool? classCheckIn,
    bool? systemAnnouncements,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationPreferencesModel(
      newBooking: newBooking ?? this.newBooking,
      classReminder: classReminder ?? this.classReminder,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      classCheckIn: classCheckIn ?? this.classCheckIn,
      systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  Map<String, dynamic> toJson() => {
    'newBooking': newBooking,
    'classReminder': classReminder,
    'paymentReceived': paymentReceived,
    'classCheckIn': classCheckIn,
    'systemAnnouncements': systemAnnouncements,
    'emailNotifications': emailNotifications,
    'pushNotifications': pushNotifications,
  };

  static bool _bool(dynamic v, {bool defaultValue = false}) {
    if (v == null) return defaultValue;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return defaultValue;
  }
}
