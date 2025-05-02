import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:archive/archive.dart';

final dirs = ['rank'];
const path = './lib/src/assets.dart';
final files = <String, List<String>>{};

/// 将多分辨率的单图压缩包解压
void main(List<String> args) {
  final dir = Directory('${Directory.current.absolute.path}/assets');

  loopDir(dir);
}

void loopDir(Directory dir, [int depts = 1]) {
  final entities = dir.listSync();

  for (var item in entities) {
    final name = item.uri.pathSegments.lastWhere((e) => e.isNotEmpty);

    if (item is Directory) {
      if (depts > 1 || dirs.contains(name)) {
        loopDir(item, depts + 1);
      }
    } else if (item is File) {
      if (item.uri.pathSegments.last.endsWith('.zip')) {
        var name = item.uri.pathSegments.last.split('.').first;
        final bytes = item.readAsBytesSync();

        final archive = ZipDecoder().decodeBytes(bytes);
        for (final entry in archive) {
          if (entry.isFile && entry.name.contains('@')) {
            var parts = entry.name.split('@');
            final fileBytes = entry.readBytes()!;
            File(
              parts[1].startsWith('1x')
                  ? '${dir.path}/$name${parts[1].substring(2)}'
                  : '${dir.path}/$name@${parts[1]}',
            )
              ..createSync(recursive: true)
              ..writeAsBytesSync(fileBytes);
          }
        }
      }
    }
  }
}
