var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@ Echo10th " + this_year; //this shows in the splash screen
  static String app_name = "Echo10th"; //this shows in the splash screen

  static String purchase_code =
      "11eda666-a748-4e77-bb7b-732ee8826800"; //enter your purchase code for the app from codecanyon
  static String system_key =
      r"$2y$10$xLOYS1Qr46K70MUquE4ii.AvmzKftkhf3B.HUfDyVgqOTYYBNdo3W"; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language = "en";
  static String mobile_app_code = "en";
  static bool app_language_rtl = false;

  //configure this
  static const bool HTTPS = true;

  static const DOMAIN_PATH = "https://new.echo10th.com"; //localhost

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";

  @override
  String toString() {
    return super.toString();
  }
}
