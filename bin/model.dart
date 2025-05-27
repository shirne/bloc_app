import 'dart:convert';
import 'dart:io';

import '_common.dart';
import '_model.dart';

const _modelPath = 'lib/src/models/';
final modalMap = <String, String>{};

void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln("Please specify the json file");
    return;
  }
  final path = args[0];
  final file = File(path);
  if (!file.existsSync()) {
    stdout.writeln("File $path not exists.");
    return;
  }
  final name = Uri.parse(path).pathSegments.last.split('.')[0];
  final className = pascalCase(name);

  try {
    final jsonStr = File(path).readAsStringSync();
    final json = as<Json>(jsonDecode(jsonStr));
    if (json == null) {
      stdout.writeln("json parse error.");
      return;
    }
    final entries = <ModelEntry>[];

    if (json.containsKey('type') &&
        json.containsKey('properties') &&
        json['properties'] is Json) {
      final entry = ModelEntry.fromJson(
        json,
        className,
        getTypeName,
        (m) => entries.add(m),
      );
      entries.add(entry);
    } else {
      final entry = ModelEntry.fromExample(
        json,
        className,
        getTypeName,
        (m) => entries.add(m),
      );
      entries.add(entry);
    }

    final models = createModel(entries);

    File('$_modelPath$name.dart').writeAsStringSync(models);

    stdout.writeln("Generated $name.");
  } catch (e) {
    stdout.writeln("Err: $e");
    if (e is Error) {
      stdout.writeln(e.stackTrace);
    } else {
      stdout.writeln(StackTrace.current);
    }
  }
}

String? getTypeName(String? name) {
  if (name == null) return null;

  if (modalMap.containsKey(name)) return modalMap[name];

  String newName = TypeModel.parseType(name)!;

  if (!isBaseType(newName) && !newName.endsWith('Model')) {
    newName = '${name}Model';
  }

  modalMap.putIfAbsent(name, () => newName);
  return newName;
}

String createModel(List<ModelEntry> entries) {
  final content = StringBuffer();
  content.writeln('import \'../utils/core.dart\';');
  content.writeln('import \'base.dart\';');
  for (var i in entries) {
    content.writeln(createModelClass(i, getTypeName(i.name)));
  }

  return content.toString();
}
