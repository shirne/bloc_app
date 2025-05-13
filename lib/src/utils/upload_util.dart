import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';

import '../globals/api.dart';
import '../models/base.dart';
import '../models/system.dart';
import 'utils.dart';

enum UploadState {
  init,
  error,
  uploading,
  uploaded;
}

class UploadEvent {
  UploadEvent({
    required this.status,
    required this.progress,
    this.file,
    this.message,
  });
  UploadEvent.init()
      : this(
          status: UploadState.init,
          progress: 0,
        );
  UploadEvent.progress(double progress)
      : this(
          status: UploadState.uploading,
          progress: progress,
        );
  UploadEvent.uploaded(FileModel file)
      : this(
          status: UploadState.uploaded,
          progress: 1,
          file: file,
        );
  UploadEvent.error(String message)
      : this(
          status: UploadState.error,
          progress: 0,
          message: message,
        );

  final UploadState status;
  final double progress;
  final String? message;
  final FileModel? file;
}

typedef UploadHalder = Function(UploadEvent);

class UploadUtil {
  static final _instance = UploadUtil._();

  UploadUtil._();

  factory UploadUtil() => _instance;

  final queue = <(dynamic, Json?, UploadHalder)>[];
  final dio = Dio();

  (dynamic, Json?, UploadHalder)? current;

  void addEntity(AssetEntity entity, UploadHalder handler, [Json? args]) {
    queue.add(((entity, args, handler)));
    startUpload();
  }

  void addEntities(List<AssetEntity> entities, UploadHalder handler,
      [Json? args]) {
    for (var entity in entities) {
      queue.add(((entity, args, handler)));
    }
    startUpload();
  }

  // void addFile(XFile file, UploadHalder handler, [Json? args]) {
  //   queue.add(((file, args, handler)));
  //   startUpload();
  // }

  // void addFiles(List<XFile> files, UploadHalder handler, [Json? args]) {
  //   for (var file in files) {
  //     queue.add(((file, args, handler)));
  //   }
  //   startUpload();
  // }

  void startUpload() {
    if (queue.isEmpty) return;
    if (current == null) {
      current = queue.removeAt(0);
      doUpload();
    }
  }

  Future<void> doUpload() async {
    if (current == null) return;
    var entity = current!.$1;
    var args = current!.$2;
    var handler = current!.$3;
    var progress = 0.0;
    try {
      try {
        handler.call(UploadEvent.init());
      } catch (e) {
        logger.warning(e);
      }
      var filePath = '';
      if (entity is AssetEntity) {
        var file = (await entity.file)!;
        filePath = file.path;
        // } else if (entity is XFile) {
        //   filePath = entity.path;
      } else {
        throw Exception('unsupport type ${entity.runtimeType}');
      }

      final result = await Api.ucenter.upload(
        filePath,
        onSendProgress: (count, total) {
          if (progress < 1) {
            progress = total <= 0 ? 0 : count / total;
            try {
              handler.call(UploadEvent.progress(progress));
            } catch (e) {
              logger.warning(e);
            }
          }
        },
      );

      if (result.success) {
        progress = 1;
        try {
          handler.call(
            UploadEvent.uploaded(result.data!),
          );
        } catch (e) {
          logger.warning(e);
        }
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      try {
        handler.call(UploadEvent.error('$e'));
      } catch (e) {
        logger.warning(e);
      }
    } finally {
      current = null;
      startUpload();
    }
  }
}
