import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'exts',
      abbr: 's',
      help: 'File extensions split by `,`. default is `dart`',
      defaultsTo: 'dart',
    )
    ..addOption(
      'dir',
      abbr: 'd',
      help: 'The root directory. default is `lib`',
      defaultsTo: 'lib',
    );
  final argument = parser.parse(args);

  final result = Result();
  final String rootPath = argument['dir'];
  final extReg = RegExp('\\.(${argument['exts'].replaceAll(',', '|')})\$');
  final dir = Directory(
    RegExp(r'(/|[a-z]:/|file://)').hasMatch(rootPath)
        ? rootPath
        : '${Directory.current.path}/$rootPath',
  );

  walkDir(dir, result, extReg);

  stdout.writeln('总文件数: ${result.files}');
  stdout.writeln('　总行数: ${result.total}');
  stdout.writeln('代码行数: ${result.code}');
  stdout.writeln('注释行数: ${result.comment}');
  stdout.writeln('　空行数: ${result.blank}');
}

void walkDir(Directory dir, Result result, RegExp exts) {
  final files = dir.listSync();
  for (FileSystemEntity file in files) {
    if (file is File) {
      if (exts.hasMatch(file.path)) {
        result.files++;
        readFile(file, result);
      }
    } else if (file is Directory) {
      walkDir(file, result, exts);
    }
  }
}

void readFile(File file, Result result) {
  bool isInComment = false;
  for (String line in file.readAsLinesSync()) {
    result.total++;
    line = line.trimLeft();
    if (line.isEmpty) {
      result.blank++;
    } else if (line.startsWith('//')) {
      result.comment++;
    } else {
      if (isInComment) {
        result.comment++;
        if (line.endsWith('*/')) {
          isInComment = false;
        } else if (line.contains('*/')) {
          isInComment = false;
          result.code++;
        }
      } else {
        if (line.startsWith('/*')) {
          isInComment = true;
          result.comment++;
        } else {
          result.code++;
        }
      }
    }
  }
}

class Result {
  int total;
  int code;
  int comment;
  int blank;
  int files;
  Result({
    this.total = 0,
    this.code = 0,
    this.comment = 0,
    this.blank = 0,
    this.files = 0,
  });

  Map<String, int> toJson() => {
        'files': files,
        'total': total,
        'code': code,
        'comment': comment,
        'blank': blank,
      };

  @override
  String toString() => jsonEncode(toJson());
}
