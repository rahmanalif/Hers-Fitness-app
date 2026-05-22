class AppConstants {
  //-------------- base url set here ---------------------//

  static const String BASE_URL =
      "https://hide-blackjack-celebration-brands.trycloudflare.com";

  static const String APP_NAME = 'DefaultAppName';
  static const String Publishable_key = '';
  static const String Secret_key = '';

  // share preference Key
  static String THEME = "theme";

  static const String LANGUAGE_CODE = 'language_code';
  static const String COUNTRY_CODE = 'country_code';

  static const String fcmToken = '';

  static RegExp emailValidator = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static RegExp passwordValidator = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
  );
}
