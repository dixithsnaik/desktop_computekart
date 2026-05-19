import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadStatus { pending, downloading, completed, failed, cancelled }

class DownloadTask {
  final String id;
  final String fileName;
  final String url;
  final String savePath;
  final RxDouble progress = 0.0.obs;
  final Rx<DownloadStatus> status = DownloadStatus.pending.obs;
  final RxString error = ''.obs;
  CancelToken? cancelToken;

  DownloadTask({
    required this.id,
    required this.fileName,
    required this.url,
    required this.savePath,
  });
}

class DownloadManagerService extends GetxService {
  final tasks = <DownloadTask>[].obs;
  final Dio _dio = Dio();
  final RxBool isPanelOpen = false.obs;

  void togglePanel() {
    isPanelOpen.value = !isPanelOpen.value;
  }

  Future<String> getDownloadsDirectoryPath() async {
    Directory? directory;
    if (Platform.isWindows) {
      directory = await getDownloadsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    final path = '${directory?.path ?? ''}/ComputeKart';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> downloadFile(String url, String fileName) async {
    final dirPath = await getDownloadsDirectoryPath();
    final savePath = '$dirPath/$fileName';
    
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      url: url,
      savePath: savePath,
    );
    
    task.cancelToken = CancelToken();
    tasks.insert(0, task);
    
    if (!isPanelOpen.value) {
      isPanelOpen.value = true;
    }

    try {
      task.status.value = DownloadStatus.downloading;
      
      await _dio.download(
        url,
        savePath,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            task.progress.value = received / total;
          }
        },
      );
      
      task.status.value = DownloadStatus.completed;
      task.progress.value = 1.0;
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
        task.status.value = DownloadStatus.cancelled;
      } else {
        task.status.value = DownloadStatus.failed;
        task.error.value = e.toString();
      }
    }
  }

  void cancelDownload(String taskId) {
    final task = tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task != null && task.status.value == DownloadStatus.downloading) {
      task.cancelToken?.cancel();
      task.status.value = DownloadStatus.cancelled;
    }
  }

  void removeTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
  }

  Future<void> saveTextToFile(String content, String fileName) async {
    final dirPath = await getDownloadsDirectoryPath();
    final file = File('$dirPath/$fileName');
    await file.writeAsString(content);
    
    // Create a dummy completed task for UI feedback
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      url: 'local',
      savePath: file.path,
    );
    task.status.value = DownloadStatus.completed;
    task.progress.value = 1.0;
    tasks.insert(0, task);
    
    if (!isPanelOpen.value) {
      isPanelOpen.value = true;
    }
  }
}
