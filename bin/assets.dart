import 'dart:io';

final pdir = RegExp(r'^\d\.\dx$');
final pfile = RegExp(r'@(\d)x\.(png|jpe?g)$');

/// 将assets中的图片按像素比整理
void main(List<String> args) {
  final dir = Directory('${Directory.current.absolute.path}/assets');

  loopDir(dir);
}

void loopDir(Directory dir) {
  final entities = dir.listSync();
  final dirs = <String, Directory?>{};
  for (var item in entities) {
    final name = item.uri.pathSegments.last;
    if (item is Directory) {
      if (!pdir.hasMatch(name)) {
        loopDir(item);
      }
    } else if (item is File) {
      final match = pfile.firstMatch(name);
      if (match != null) {
        final ndir = dirs.putIfAbsent(
            match.group(1)!, () => getXDir(match.group(1)!, dir));
        if (ndir != null) {
          item.renameSync(
              '${ndir.path}/${name.split('@').first}.${match.group(2)}');
        }
      }
    }
  }
}

Directory? getXDir(String num, Directory currentDir) {
  final i = int.tryParse(num);
  if (i == 0) {
    return null;
  }
  final dir = Directory('${currentDir.path}/$i.0x');
  if (!dir.existsSync()) {
    dir.createSync();
  }
  return dir;
}
