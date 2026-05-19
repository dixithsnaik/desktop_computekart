import 'package:flutter_dotenv/flutter_dotenv.dart';

/// All API endpoint constants, matching the React app's Api.js and apiServices.js.
class ApiConstants {
  ApiConstants._();

  // ─── Base URLs ──────────────────────────────────────────────────
  static String get mgServer => dotenv.env['MG_SERVER'] ?? 'https://backend.computekart.com';
  static String get monitoringServer => dotenv.env['MONITORING_SERVER'] ?? 'https://monitoring.computekart.com';
  static String get installMegaUrl => dotenv.env['INSTALL_MEGA_URL'] ?? 'https://fileshare.computekart.com/install_mega.sh';

  // ─── Auth ───────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';

  // ─── Profile ────────────────────────────────────────────────────
  static const String getUserDetails = '/ui/profile/getUserDetails';
  static const String updateUserDetails = '/ui/profile/updateUserDetails';

  // ─── Providers (Client-facing) ──────────────────────────────────
  static const String providersList = '/providers/lists';
  static const String providersQuery = '/providers/query';

  // ─── VMs ────────────────────────────────────────────────────────
  static const String allVms = '/vms/allVms';
  static const String launchVm = '/vms/launch';
  static const String startVm = '/vms/start';
  static const String stopVm = '/vms/stop';
  static const String removeVm = '/vms/remove';

  // ─── Manage Providers ───────────────────────────────────────────
  static const String userProviderDetails = '/ui/providers/userProviderDetails';
  static const String providerClientDetails = '/ui/providers/providerClientDetails';
  static const String updateProviderConfig = '/ui/providers/update_config';
  static const String getProviderVerificationToken = '/providerServer/getProviderVerificationToken';

  // ─── Manage CLIs ────────────────────────────────────────────────
  static const String getAllCliSessionDetails = '/ui/getAllCliSessionDetails';
  static const String getCliVerificationToken = '/ui/getCliVerificationToken';
  static const String deleteCliSession = '/ui/deleteCliSession';

  // ─── Tunnels ────────────────────────────────────────────────────
  static const String getUserClients = '/ui/getUserClients';
  static const String createTunnelClient = '/ui/createTunnelClient';
  static const String editTunnel = '/ui/editTunnel';
  static const String deleteTunnel = '/ui/deleteTunnel';

  // ─── HDFS / Buckets ─────────────────────────────────────────────
  static const String hdfsList = '/hdfs/list';
  static const String hdfsMkdir = '/hdfs/mkdir';
  static const String hdfsDelete = '/hdfs/delete';
  static const String hdfsRename = '/hdfs/rename';
  static const String hdfsUpload = '/hdfs/uploadFileFolder';
  static const String hdfsDownload = '/hdfs/download';

  // ─── Dashboard / Monitoring ─────────────────────────────────────
  static const String createDashboard = '/dashboard/createDashboard';
  static const String deleteDashboard = '/dashboard/deleteDashboard';
  static const String listDashboards = '/dashboard/listDashboards';
  static const String updateDashboard = '/dashboard/updateDashboard';
  static const String listGraphsForDashboard = '/dashboard/listGraphsForDashboard';
  static const String getGraphPoints = '/dashboard/getGraphPoints';
  static const String createGraphWithSeries = '/dashboard/createGraphWithSeries';
  static const String deleteGraph = '/dashboard/deleteGraph';
  static const String getServiceDetailsForUser = '/dashboard/getServiceDetailsForUser';
}
