import 'dart:io';
import 'dart:ui' show Size;
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../globals/api.dart';
import '../models/system.dart';
import 'utils.dart';

enum UploadType {
  user(0),
  avatar(1),
  icon(2),
  cover(3),
  origin(4),
  doc(5),
  video(6);

  const UploadType(this.type);

  final int type;
}

enum UploadState { init, error, uploading, uploaded }

class UploadEvent {
  UploadEvent({
    required this.status,
    required this.progress,
    this.file,
    this.message,
  });
  UploadEvent.init() : this(status: UploadState.init, progress: 0);
  UploadEvent.progress(double progress)
    : this(status: UploadState.uploading, progress: progress);
  UploadEvent.uploaded(FileModel file)
    : this(status: UploadState.uploaded, progress: 1, file: file);
  UploadEvent.error(String message)
    : this(status: UploadState.error, progress: 0, message: message);

  final UploadState status;
  final double progress;
  final String? message;
  final FileModel? file;
}

typedef UploadHalder = Function(UploadEvent);

abstract class UploadOption {
  UploadOption(this.type);
  final UploadType type;
}

class ImageOption extends UploadOption {
  static bool needCrop(UploadType type) => switch (type) {
    UploadType.icon || UploadType.avatar => true,
    _ => false,
  };
  static Size? limitSize(UploadType type) => switch (type) {
    UploadType.icon => Size(64, 64),
    UploadType.avatar => Size(400, 400),
    UploadType.origin || UploadType.doc || UploadType.video => null,
    _ => Size(1600, 1600),
  };

  ImageOption(super.type, [this.size, this.crop = false]);

  ImageOption.fromType(UploadType type)
    : this(type, limitSize(type), needCrop(type));

  final Size? size;
  final bool crop;
}

class FileOption extends UploadOption {
  FileOption(super.type);
}

class VideoOption extends UploadOption {
  VideoOption(super.type) : assert(type == UploadType.video);
}

class UploadUtil {
  static final _instance = UploadUtil._();

  UploadUtil._();

  factory UploadUtil() => _instance;

  final queue = <(File, UploadOption?, UploadHalder)>[];
  final dio = Dio();

  (File, UploadOption?, UploadHalder)? current;

  void addFile(File file, UploadHalder handler, [UploadOption? option]) {
    queue.add(((file, option, handler)));
    startUpload();
  }

  void addFiles(
    List<File> files,
    UploadHalder handler, [
    UploadOption? option,
  ]) {
    for (var file in files) {
      queue.add(((file, option, handler)));
    }
    startUpload();
  }

  void startUpload() {
    if (queue.isEmpty) return;
    if (current == null) {
      current = queue.removeAt(0);
      doUpload();
    }
  }

  static int cacheId = 1000;

  Future<String?> cropImage(String path, ImageOption option) async {
    try {
      var size = option.size;
      if (size == null) return path;

      // Directory.current; //
      var cachedir = await getApplicationCacheDirectory();

      var newpath = '${cachedir.path}/${cacheId++}.jpg';
      //print('newpath: $newpath');
      final cmd = img.Command()..decodeImageFile(path);

      var image = await cmd.getImage();
      if (image == null) {
        throw Exception('unseppert image format');
      }

      if (image.width > size.width || image.height > size.height) {
        if (option.crop) {
          var scale = math.max(
            size.width / image.width,
            size.height / image.height,
          );

          var scaleWidth = (image.width * scale).ceil();
          var scaleHeight = (image.height * scale).ceil();
          cmd
            ..copyResize(
              width: scaleWidth,
              height: scaleHeight,
              // maintainAspect: true,
            )
            ..copyCrop(
              x: ((scaleWidth - size.width) / 2).toInt(),
              y: ((scaleHeight - size.height) / 2).toInt(),
              width: size.width.toInt(),
              height: size.height.toInt(),
            );
        } else {
          var scale = math.min(
            size.width / image.width,
            size.height / image.height,
          );
          cmd.copyResize(
            width: (image.width * scale).ceil(),
            height: (image.height * scale).ceil(),
            // maintainAspect: true,
          );
        }
      }

      cmd
        ..encodeJpg(quality: 75)
        ..writeToFile(newpath);
      await cmd.executeThread();
      return newpath;
    } catch (err) {
      logger.warning(err);
    }
    return null;
  }

  Future<void> doUpload() async {
    if (current == null) return;
    var file = current!.$1;
    var option = current!.$2;
    var handler = current!.$3;
    var progress = 0.0;
    try {
      try {
        handler.call(UploadEvent.init());
      } catch (e) {
        logger.warning(e);
      }
      String? filePath = file.path;

      // 根据参数压缩图片
      if (option is ImageOption) {
        filePath = await cropImage(filePath, option);
        if (filePath == null) {
          throw Exception('图片压缩失败');
        }
      }

      // TODO 压缩视频

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
          handler.call(UploadEvent.uploaded(result.data!));
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
