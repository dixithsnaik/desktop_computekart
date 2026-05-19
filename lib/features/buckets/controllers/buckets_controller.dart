import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class BucketsController extends GetxController {
  final files = <Map<String, dynamic>>[].obs;
  final currentPath = '/'.obs;
  final pathParts = <String>[].obs;
  final isLoading = true.obs;
  final selectedFiles = <String>{}.obs;

  @override void onInit() { super.onInit(); fetchFiles(); }

  Future<void> fetchFiles() async {
    isLoading.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('GET', ApiConstants.hdfsList, queryParameters: {'path': currentPath.value});
      files.value = List<Map<String, dynamic>>.from(res['files'] ?? []);
    } catch (_) {}
    isLoading.value = false;
  }

  void navigateToDir(String dirName) {
    final newPath = currentPath.value.endsWith('/') ? '${currentPath.value}$dirName' : '${currentPath.value}/$dirName';
    currentPath.value = newPath;
    pathParts.value = newPath.split('/').where((p) => p.isNotEmpty).toList();
    selectedFiles.clear();
    fetchFiles();
  }

  void navigateBack() {
    if (pathParts.isEmpty) return;
    pathParts.removeLast();
    currentPath.value = '/${pathParts.join('/')}';
    selectedFiles.clear();
    fetchFiles();
  }

  void navigateToIndex(int index) {
    currentPath.value = '/${pathParts.sublist(0, index + 1).join('/')}';
    pathParts.value = pathParts.sublist(0, index + 1);
    selectedFiles.clear();
    fetchFiles();
  }

  void toggleSelect(String name) {
    if (selectedFiles.contains(name)) { selectedFiles.remove(name); } else { selectedFiles.add(name); }
  }

  Future<String?> createDirectory(String name) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.hdfsMkdir, data: {'path': '${currentPath.value}/$name'}); await fetchFiles(); return 'Directory created'; } catch (e) { return 'Error: $e'; }
  }

  Future<String?> deleteFiles() async {
    if (selectedFiles.isEmpty) return 'No files selected';
    try {
      final api = Get.find<ApiService>();
      for (final f in selectedFiles) { await api.call('POST', ApiConstants.hdfsDelete, data: {'path': '${currentPath.value}/$f'}); }
      selectedFiles.clear(); await fetchFiles(); return 'Deleted successfully';
    } catch (e) { return 'Error: $e'; }
  }

  Future<String?> renameFile(String oldName, String newName) async {
    try { final api = Get.find<ApiService>(); await api.call('POST', ApiConstants.hdfsRename, data: {'path': '${currentPath.value}/$oldName', 'newName': newName}); await fetchFiles(); return 'Renamed'; } catch (e) { return 'Error: $e'; }
  }

  Future<String?> uploadFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return null;
    try {
      final api = Get.find<ApiService>();
      for (final file in result.files) {
        if (file.path == null) continue;
        final formData = dio.FormData.fromMap({
          'path': currentPath.value,
          'file': await dio.MultipartFile.fromFile(file.path!, filename: file.name),
        });
        await api.upload(ApiConstants.hdfsUpload, formData: formData);
      }
      await fetchFiles();
      return '${result.files.length} file(s) uploaded';
    } catch (e) { return 'Error: $e'; }
  }
}
