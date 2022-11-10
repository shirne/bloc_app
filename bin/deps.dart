import 'dart:io';

import 'package:yaml/yaml.dart';

/// total deps count
void main(List<String> args) async {
  final path = '${Directory.current.path}/pubspec.yaml';
  final yamlStr = File(path).readAsStringSync();
  final yaml = loadYaml(yamlStr);

  final lib = Directory('${Directory.current.path}/lib');

  for (final kv in yaml['dependencies'].entries) {
    stdout.writeln('${kv.key}  => ${await findInFiles(kv.key, lib)}');
  }
}

Future<int> findInFiles(String name, Directory dir) async {
  final files = await dir.list().toSet();
  int count = 0;
  for (final file in files) {
    if (file is File) {
      for (String line in file.readAsLinesSync()) {
        if (line.replaceAll('"', "'").startsWith('import \'package:$name/')) {
          count++;
          break;
        }
      }
    } else if (file is Directory) {
      count += await findInFiles(name, file);
    }
  }

  return count;
}
