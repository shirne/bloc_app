import 'dart:io';

final classNames = <String>[];
const loginDir = 'login';
const export = 'route.md';

void main(List<String> args) {
  final pagesPath = "${Directory.current.path}/lib/src/pages/";
  final path = "${Directory.current.path}/lib/src/globals/routes.dart";

  final exports = <String>[];
  final imports = <String>[];
  final routes = <String>[];
  final routeNames = <String>[];

  walkDir(pagesPath, imports, routes, routeNames, exports);

  final contents = File(path).readAsLinesSync();
  final newContents = <String>[];
  final importIndex = contents.indexOf('// ==== GENERATED IMPORT START ====');
  final importEnd = contents.indexOf('// ==== GENERATED END ====');
  if (importIndex < 0 || importEnd <= importIndex) {
    stdout.addError('Unfound // ==== GENERATED IMPORT START ====\n'
        'And // ==== GENERATED END ====');
    return;
  }

  final routeIndex =
      contents.indexOf('// ==== GENERATED ROUTES START ====', importEnd);
  final routeEnd = contents.indexOf('// ==== GENERATED END ====', routeIndex);
  if (routeIndex < 0 || routeEnd <= routeIndex) {
    stdout.addError('Unfound // ==== GENERATED ROUTES START ====\n'
        'And // ==== GENERATED END ====');
    return;
  }

  newContents.addAll(contents.take(importIndex + 1));
  newContents.addAll(imports);
  newContents.addAll(contents.sublist(importEnd, routeIndex + 1));
  newContents.addAll([
    "",
    ...routes,
    "",
    "  static final routes = {",
    "    for (RouteItem e in [",
    "      splash,",
    "      policy,",
    for (var n in routeNames) "      $n,",
    "    ])",
    "      e.name: e,",
    "  };",
  ]);
  newContents.addAll(contents.sublist(routeEnd));
  newContents.add("");

  File(path).writeAsStringSync(newContents.join("\n"));

  File(export).writeAsStringSync(exports.join("\n"));
  stdout.write('update routes ok');
}

void walkDir(
  String pagesPath,
  List<String> imports,
  List<String> routes,
  List<String> routeNames,
  List<String> exports,
) {
  for (var entity in Directory(pagesPath).listSync()) {
    if (entity is Directory) {
      final index = File('${entity.path}/page.dart');
      final path = entity.path.replaceAll('\\', '/');
      final pagePath = path.split("/src/pages/").last;
      if (index.existsSync()) {
        final (className, hasArgs, comment) = getClassName(index);
        if (className.isEmpty) {
          stdout.addError("Unfound class in ${index.path}");
        } else {
          exports.add('');
          if (comment.isNotEmpty) {
            exports.add('// $comment');
          }
          exports.add('/$pagePath${hasArgs ? '?' : ''}');
          bool useAlias = false;
          final libName = pagePath.replaceAll('/', '_');
          if (classNames.contains(className)) {
            useAlias = true;
          } else {
            classNames.add(className);
          }
          final routeName = pagePath.replaceAllMapped(
            RegExp(r'[/_](\w)'),
            (match) => match.group(1)!.toUpperCase(),
          );
          imports.add(
            "import '../pages/$pagePath/page.dart'${useAlias ? ' as $libName' : ''};",
          );
          routes.addAll([
            "  static final $routeName = RouteItem(",
            "    '/$pagePath',",
            if (pagePath == loginDir || pagePath.startsWith('$loginDir/'))
              "    isAuth: false,",
            hasArgs
                ? "    (arguments) => ${useAlias ? '$libName.' : ''}$className(Utils.parseQuery(arguments)),"
                : "    (arguments) => const ${useAlias ? '$libName.' : ''}$className(),",
            "  );",
          ]);
          routeNames.add(routeName);
        }
      }
      walkDir(entity.path, imports, routes, routeNames, exports);
    }
  }
}

(String, bool, String) getClassName(File index) {
  String className = '';
  bool hasArgs = false;
  String lastLine = '';
  String comment = '';
  for (var s in index.readAsLinesSync()) {
    if (className.isEmpty && s.startsWith('class ')) {
      className = s.substring(6, s.indexOf(' ', 7));
      if (lastLine.startsWith('///')) {
        comment = lastLine.substring(3).trim();
      }
    } else if (s.trim().startsWith('$className(Json')) {
      hasArgs = true;
      break;
    }
    lastLine = s;
  }
  return (className, hasArgs, comment);
}
