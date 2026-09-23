
import 'package:ies_mobile/config/app_config.dart';

class ApiEndPoints {
  static String get BaseUrl => AppConfig.baseUrl;

  static String login = "$BaseUrl/user-service/api/auth/login";
  static String forgotPass = "$BaseUrl/v1/User/forgot_password";
  static String verifyEmail = "$BaseUrl/v1/User/verify_email";
  static String changePass = "$BaseUrl/v1/User/change_password";
  static String getDashBoardData = "$BaseUrl/be-service/ies/dashboard";
  static String getUserDetails = "$BaseUrl/be-service/ies/users/";
  static String get webSocketUrl => AppConfig.webSocketBaseUrl;
  static String getReports =
      "$BaseUrl/be-service/sensors/reports?page=0&size=1000";

  static String getSensorsBySystemUid = "$BaseUrl/v1/Sensor/by/system";
  static String getAllSensors = "$BaseUrl/v1/Sensor/";
  static String getSensorData = "$BaseUrl/v1/Sensor/data";
  static String getSensorPreviousValue =
      "$BaseUrl/be-service/sensors/latestData?deviceId";

  static String getSensorsWithMaintenance =
      "$BaseUrl/be-service/sensors?page=0&size=1000";
  static String downloadReport = "$BaseUrl/be-service/sensors/reports/download";
  static String updateSite = "$BaseUrl/be-service/sites";

  static String customerSystems = "$BaseUrl/rest/v1/rpc/get_customer_systems";
  static String adminSystems = "$BaseUrl/rest/v1/rpc/get_systems";
  static String customerSensors = "$BaseUrl/rest/v1/rpc/get_sensors";
  static String userDashBoardData =
      "$BaseUrl/rest/v1/rpc/user_customer_dashboard";
  static String useadminDashBoardData = "$BaseUrl/rest/v1/rpc/admin_dashboard";
  static String addSystem = "$BaseUrl/rest/v1/rpc/add_systems";
  static String addSensors = "$BaseUrl/rest/v1/rpc/add_sensors";
  static String sendDeviceID =
      "$BaseUrl/rest/v1/rpc/insert_update_register_entry";
  static String getCustomerList = "$BaseUrl/rest/v1/rpc/get_customer_list";
  static String changeOtp = "$BaseUrl/rest/v1/rpc/reset_password";
  static String raiseComplaint = "$BaseUrl/rest/v1/rpc/raise_ticket";
  static String getComplaints = "$BaseUrl/rest/v1/rpc/get_tickets";
  static String getAdminComplaints =
      "$BaseUrl/rest/v1/rpc/get_tickets_by_customer_id";
  static String updateStatusOfTicket =
      "$BaseUrl/rest/v1/rpc/update_ticket_status_by_admin";
  static String getReportGenerated =
      "$BaseUrl/rest/v1/rpc/get_filtered_reports";
  static String getNotificationList =
      "$BaseUrl/rest/v1/rpc/get_recent_notifications";
  static String getNotificationFlag =
      "$BaseUrl/rest/v1/rpc/get_flag_status_for_operator";
  static String getPitStatus = "$BaseUrl/rest/v1/rpc/get_pits";
  static String getMqttRestApiData = "$BaseUrl/rest/v1/rpc/get_new_server_data";
}

final String reportFileExtension = ".xlsx";
