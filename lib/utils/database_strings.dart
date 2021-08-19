class DatabaseStrings {
  static const TENDER_EXTERNAL = "TenderExternal";
  static const TENDER_PART = "TenderPart";
  static const PICKUP_EXTERNAL = "PickUpExternal";
  static const PICKUP_PART = "PickUpPart";
  static const ARRIVE = "Arrive";
  static const DEPART = "Depart";
  static const DISCIPLINE_CONFIG = "DISCIPLINE_CONFIG";
  static const ID_AUTO_INCREMENT = "id INTEGER PRIMARY KEY AUTOINCREMENT,";
  static const ID = "id";
  static const PICKUP_SITE = "pick_up_site";
  static const PRIORITY = "priority";
  static const QUANTITY = "quantity";
  static const LOCATION = "location";
  static const DEST_LOCATION = "dest_location";
  static const PICK_UP_SITE = "pick_up_site";
  static const DELIVERY_SITE = "delivery_site";
  static const ORDER_NUMBER = "order_number";
  static const REF_NUMBER = "ref_number";
  static const PART_NUMBER = "part_number";
  static const TRACKING_NUMBER = "tracking_number";
  static const TOOL_NUMBER = "tool_number";
  static const KEEP_SCANNED_VALUES = "keep_scanned_values";
  static const SCAN_TIME = "scan_time";
  static const PACKAGING_COUNT = "packaging_count";
  static const IS_SYNCED = "is_synced";
  static const IS_SCANNED = "is_scanned";
  static const IS_DELIVERED = "is_delivered";
  static const IS_PART = "is_part";
  static const KEY_NAME = "key_name";
  static const DISPLAY_NAME = "display_name";
  static const IS_VISIBLE = "is_visible";

  static const TEXT = "TEXT,";
  static const INTEGER = "INTEGER,";
  static const BOOLEAN = "BOOLEAN,";

  //Location
  static const GPS_POLL_INTERVAL = "gps_poll_interval";
  static const GPS_POST_INTERVAL = "gps_post_interval";
  static const GPS_URL = "gps_url";

  //user
  static const String USER = "user";
  static const String USER_NAME = "user_name";
  static const String TOKEN = "token";
  static const String REMEMBER_ME = "remember_me";
  static const String LOGOUT = "logout";

  //settings
  static const String SETTINGS = "settings";
  static const String TENDER_MODE = "tender_mode";
  static const String USE_TOOL_NUMBER = "use_tool_number";
  static const String PICK_ON_TENDER = "pick_on_tender";
  static const String DRIVER_MODE = "driver_mode";
  static const String TABS = "tabs";
  static const String TAB_NAMES = "tab_names";
  static const String TENDER = "tender";
  static const String PICKUP = "pickup";
  static const String DELIVERY = "delivery";
  static const String SUB_DISCIPLINE_NAMES = "sub_discipline_names";
  static const String TENDER_EXTERNAL_SETTINGS = "tender_external";
  static const String TENDER_PRODUCTION_PART_SETTINGS =
      "tender_production_part";
  static const String PICKUP_EXTERNAL_SETTINGS = "pickup_external";
  static const String PICKUP_PRODUCTION_PART_SETTINGS = "pickup_productin_part";
  static const String DEPART_SETTINGS = "depart";
  static const String ARRIVE_SETTINGS = "arrive";

  //priority response table
  static const String PRIORITY_RESPONSE = "priority_response";
  static const String CODE = "code";
  static const String DESCRIPTION = "description";

  //location response table
  static const String LOCATION_RESPONSE = "location_response";
  static const String LOC = "loc";

  //server config response table
  static const String SERVER_CONFIG_RESPONSE = "server_config_response";
  static const String BASE_URL = "base_url";
  static const String USERNAME = "user_name";
  static const String PASSWORD = "password";
}
