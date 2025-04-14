import 'dart:io';

final dirs = ['images', 'svgs'];
const path = './lib/src/assets.dart';
final files = <String, List<String>>{};

/// 将assets中的资源按路径生成实体
void main(List<String> args) {
  final dir = Directory('${Directory.current.absolute.path}/assets');

  final rootClass = ClassEntity('assets');
  loopDir(dir, rootClass);

  File(path).writeAsStringSync(rootClass.toClassCode());
}

final classUpperReg = RegExp('(^|_)([a-z])');
final varUpperReg = RegExp('[_-]([a-z])');
final xDirReg = RegExp(r'^\d\.\dx$');
final sufixReg = RegExp(r'\.[a-zA-Z0-9]+$');

class ClassEntity {
  ClassEntity(this.name, [this.path = ''])
      : properties = [],
        classes = [];

  final String name;
  final String path;
  final List<String> properties;
  final List<ClassEntity> classes;

  String get fullPath => '$path$name/';

  String? _className;
  String get className => _className ??=
      name.replaceAllMapped(classUpperReg, (m) => m[2]!.toUpperCase());

  String toClassCode() {
    StringBuffer sb = StringBuffer();

    // 根目录
    if (path.isEmpty) {
      sb.write('class $className {');
    } else {
      sb.write('class _\$$className {\n');
      sb.write('  const _\$$className();\n\n');
    }

    if (properties.isNotEmpty) {
      sb.write('  static const _base = \'$path$name\';\n\n');
    }

    final prefix = path.isEmpty ? '  static const ' : '  final ';
    for (var i in properties) {
      sb.write(
        '$prefix${i.replaceFirst(sufixReg, '').replaceAllMapped(varUpperReg, (m) => m[1]!.toUpperCase())} = \'\$_base/$i\';\n',
      );
    }
    if (classes.isNotEmpty) {
      sb.write('\n');

      for (var c in classes) {
        final classVar =
            c.className.replaceRange(0, 1, c.className[0].toLowerCase());
        final clsName = c.path.isEmpty ? c.className : '_\$${c.className}';
        sb.write(
          '$prefix$classVar = ${path.isEmpty ? '' : 'const '}$clsName();\n',
        );
      }
    }
    sb.write('}\n');

    for (var c in classes) {
      sb.write('\n');
      sb.write(c.toClassCode());
    }
    return sb.toString();
  }
}

void loopDir(Directory dir, ClassEntity parent, [int depts = 1]) {
  final entities = dir.listSync();

  for (var item in entities) {
    final name = item.uri.pathSegments.lastWhere((e) => e.isNotEmpty);

    if (item is Directory) {
      if (!xDirReg.hasMatch(name) && (depts > 1 || dirs.contains(name))) {
        final cls = ClassEntity(name, parent.fullPath);
        parent.classes.add(cls);
        loopDir(item, cls, depts + 1);
      }
    } else if (item is File) {
      if (item.uri.pathSegments.last.contains('@')) continue;
      parent.properties.add(name);
    }
  }
}
