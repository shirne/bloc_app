import 'dart:convert';
import 'dart:io';

import '_common.dart';
import '_model.dart';

final paramReg = RegExp(r'\{([\w]+)\}');
const _apiPath = 'lib/src/globals/api/';
const _modelPath = 'lib/src/models/';

const baseClassName = 'BaseResponse';
const baseClassDataField = 'data';
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
    var json = jsonDecode(jsonStr);
    if (json['openapi'] != null) {
      final entry = OpenApiModel.fromJson(json);

      final models = createModel(entry.components);

      File('$_modelPath$name.dart').writeAsStringSync(models);

      final customModels = <ModelEntry>[];

      final apis = createApi(
        entry.paths,
        '',
        className,
        (m) => customModels.add(m),
      );

      if (customModels.isNotEmpty) {
        File('$_modelPath$name.dart').writeAsStringSync(
          createModel(customModels, false),
          mode: FileMode.append,
        );
      }

      File('$_apiPath$name.dart').writeAsStringSync(apis);
    } else {
      final entry = SwaggerModel.fromJson(json);

      final models = createModel(entry.definitions);

      File('$_modelPath$name.dart').writeAsStringSync(models);

      final customModels = <ModelEntry>[];

      final apis = createApi(
          entry.paths, entry.basePath, className, (m) => customModels.add(m));
      if (customModels.isNotEmpty) {
        File('$_modelPath$name.dart').writeAsStringSync(
          createModel(customModels, false),
          mode: FileMode.append,
        );
      }

      File('$_apiPath$name.dart').writeAsStringSync(apis);
    }
  } catch (e) {
    stdout.writeln("Err: $e");
    if (e is Error) {
      stdout.writeln(e.stackTrace);
    } else {
      stdout.writeln(StackTrace.current);
    }
  }
}

String createModel(List<ModelEntry> entries, [bool withInclude = true]) {
  final content = StringBuffer();
  if (withInclude) {
    content.writeln('import \'../utils/core.dart\';');
    content.writeln('import \'base.dart\';');
  } else {
    content.writeln('');
  }
  for (var i in entries) {
    content.writeln(createModelClass(i, getTypeName(i.name)));
  }

  return content.toString();
}

String createApi(
  Map<String, List<RequestEntry>> json,
  String basePath,
  String className,
  Function(ModelEntry) onCustomModel,
) {
  final content = StringBuffer();
  content.write('''
part of '../api.dart';

class Api$className extends ApiBase {
  @override
  String get basePath => '$basePath';

''');
  for (var i in json.entries) {
    final origPath = i.key.substring(1);
    final path = transPath(origPath);
    for (var method in i.value) {
      final methodName = method.operationId;
      final params = method.parameters;
      var response = method.responses['200']?.schema;
      final respType = getTypeName(response) ?? 'ApiResult';
      final innerType = respType.startsWith('ApiResult<')
          ? respType.substring(10, respType.length - 1)
          : respType;
      final custom = method.responses['200']?.custom;
      if (response == null && custom != null) {
        response = custom.name;
        onCustomModel.call(custom);
        if (method.responses['200']?.subModels != null) {
          for (var subm in method.responses['200']!.subModels!) {
            onCustomModel.call(subm);
          }
        }
      }
      stdout.writeln('$origPath $response $respType $innerType');
      content.write('''
  /// ${method.summary}
  Future<$respType> $methodName(${params.isEmpty ? '' : '{'}
''');
      for (var e in params) {
        content.write(
          '    ${e.isRequired ? 'required ' : ''}${e.type.typeName}${e.isRequired ? '' : '?'} ${e.paramName},',
        );
      }

      content.write('''
  ${params.isEmpty ? '' : '}'}) async {
    return await apiService.${method.method}(
      '\${basePath}$path',
''');
      if (params.where((e) => !e.isPath).isNotEmpty) {
        if (method.method == 'get') {
          content.writeln('      queryParameters: {');
        } else if (method.method == 'delete') {
          content.writeln('      data: {');
        } else {
          content.writeln('      {');
        }
        for (var e in params.where((e) => !e.isPath)) {
          content.writeln(
            '       ${e.isRequired ? '' : 'if(${e.paramName} != null) '}\'${e.name}\': ${e.paramName},',
          );
        }
        content.writeln('},');
      } else if (method.method == 'post') {
        content.writeln('{},');
      }
      if (response != null) {
        if (isBaseType(innerType) || innerType == 'Model') {
          content.writeln('      dataParser: (d)=> Model.fromJson(d),');
        } else if (innerType.startsWith('ModelList<')) {
          var sType = innerType.substring(10, innerType.length - 1);
          content.writeln(
            '      dataParser: (d)=> ModelList.fromJson(d, (m) => $sType.fromJson(m)),',
          );
        } else if (innerType.startsWith('ModelPage<')) {
          var sType = innerType.substring(10, innerType.length - 1);
          content.writeln(
            '      dataParser: (d)=> ModelPage.fromJson(d, (m) => $sType.fromJson(m)),',
          );
        } else {
          content.writeln('      dataParser: (d)=> $innerType.fromJson(d),');
        }
      }

      // TODO(shirne): skipLock: true,
      content.write('''
    );
  }
''');
    }
  }
  content.write('''
}
''');
  return content.toString();
}

String transPath(String path) {
  final newPath = path.replaceAllMapped(
    paramReg,
    (match) => '\$${camelCase(match.group(1)!)}',
  );

  return newPath;
}

String? getTypeName(String? name) {
  if (name == null) return null;
  if (name.startsWith(baseClassName)) {
    var innerType = getTypeName(name.substring(baseClassName.length))!;
    if (isBaseType(innerType)) {
      innerType = 'Model';
    } else if (innerType.startsWith('List<')) {
      innerType = 'Model$innerType';
    }
    return 'ApiResult<$innerType>';
  }

  if (modalMap.containsKey(name)) return modalMap[name];
  String newName;

  if (name.startsWith('Page')) {
    newName = "ModelPage<${getTypeName(name.substring(4))}>";
  } else if (name.startsWith('MapString')) {
    newName = "Json";
  } else if (name.startsWith('Map') || name == "Object") {
    newName = "Map";
  } else if (name.startsWith('List')) {
    newName = "List<${getTypeName(name.substring(4))}>";
  } else {
    newName = TypeModel.parseType(name)!;
    if (newName == name &&
        !isBaseType(newName) &&
        !newName.contains('<') &&
        !name.endsWith('DTO') &&
        !name.endsWith('Model') &&
        !name.endsWith('Resp') &&
        !name.endsWith('Req')) {
      newName = '${name}Model';
    }
  }
  modalMap.putIfAbsent(name, () => newName);
  return newName;
}

class OpenApiModel {
  OpenApiModel({
    required this.openapi,
    required this.info,
    required this.servers,
    required this.paths,
    required this.components,
  });
  OpenApiModel.fromJson(Json json)
      : this(
          openapi: as<String>(json['openapi']) ?? '',
          info: InfoModel.fromJson(as<Json>(json['info'], emptyJson)!),
          servers: as<List>(json['servers'])
                  ?.map<ServerModel>((d) => ServerModel.fromJson(d))
                  .toList() ??
              [],
          paths: as<Json>(json['paths'])?.map<String, List<RequestEntry>>(
                (k, v) => MapEntry(
                  k,
                  v.entries
                      .map<RequestEntry>(
                        (e) => RequestEntry.fromJson(e.value, k, e.key),
                      )
                      .toList(),
                ),
              ) ??
              {},
          components: as<Json>(json['components']?['schemas'])
                  ?.entries
                  .map<ModelEntry>(
                    (e) => ModelEntry.fromJson(
                      e.value,
                      e.key,
                      getTypeName,
                    ),
                  )
                  .toList() ??
              [],
        );

  String get host => servers.firstOrNull?.url ?? '';

  final String openapi;
  final InfoModel info;
  final List<ServerModel> servers;

  final Map<String, List<RequestEntry>> paths;
  final List<ModelEntry> components;
}

class SwaggerModel {
  SwaggerModel({
    required this.swagger,
    required this.info,
    required this.host,
    required this.basePath,
    required this.schemes,
    required this.consumes,
    required this.produces,
    required this.paths,
    required this.definitions,
    required this.securityDefinitions,
  });

  SwaggerModel.fromJson(Json json)
      : this(
          swagger: as<String>(json['swagger'], '')!,
          info: InfoModel.fromJson(as<Json>(json['info'], emptyJson)!),
          host: as<String>(json['host'], '')!,
          basePath: as<String>(json['basePath'], '')!,
          schemes: as<List>(json['schemes'])?.cast<String>() ?? [],
          consumes: as<List>(json['consumes'])?.cast<String>() ?? [],
          produces: as<List>(json['produces'])?.cast<String>() ?? [],
          paths: as<Json>(json['paths'])?.map<String, List<RequestEntry>>(
                (k, v) => MapEntry(
                  k,
                  v.entries
                      .map<RequestEntry>(
                        (e) => RequestEntry.fromJson(e.value, k, e.key),
                      )
                      .toList(),
                ),
              ) ??
              {},
          definitions: as<Json>(json['definitions'])
                  ?.entries
                  .map<ModelEntry>(
                    (e) => ModelEntry.fromJson(e.value, e.key, getTypeName),
                  )
                  .toList() ??
              [],
          securityDefinitions: as<Json>(json['securityDefinitions'])
                  ?.entries
                  .map<SecurityDefinition>(
                    (e) => SecurityDefinition.fromJson(e.value, e.key),
                  )
                  .toList() ??
              [],
        );

  final String swagger;
  final InfoModel info;
  final String host;
  final String basePath;
  final List<String> schemes;
  final List<String> consumes;
  final List<String> produces;
  final Map<String, List<RequestEntry>> paths;
  final List<ModelEntry> definitions;
  final List<SecurityDefinition> securityDefinitions;
}

class InfoModel {
  InfoModel({
    required this.title,
    required this.description,
    required this.version,
  });
  InfoModel.fromJson(Json json)
      : this(
          title: as<String>(json['title'], '')!,
          description: as<String>(json['description'], '')!,
          version: as<String>(json['version'], '')!,
        );

  final String title;
  final String description;
  final String version;
}

class ServerModel {
  ServerModel({
    required this.url,
    required this.description,
  });
  ServerModel.fromJson(Json json)
      : this(
          url: as<String>(json['url'], '')!,
          description: as<String>(json['description'], '')!,
        );

  final String url;
  final String description;
}

class RequestEntry {
  RequestEntry({
    required this.path,
    required this.method,
    required this.summary,
    required this.operationId,
    required this.responses,
    required this.parameters,
    required this.tags,
  });
  RequestEntry.fromJson(Json json, String path, String method)
      : this(
          path: path,
          method: method,
          summary: as<String>(json['summary'], '')!,
          operationId: as<String>(json['operationId'], '')!,
          responses: as<Json>(json['responses'])?.map<String, ResponseScheme>(
                (k, v) => MapEntry(k, ResponseScheme.fromJson(v, path)),
              ) ??
              {},
          parameters: as<List>(json['parameters'])
                  ?.map<ParamModel>((e) => ParamModel.fromJson(e))
                  .toList() ??
              [],
          tags:
              as<List>(json['produces'] ?? json['tags'])?.cast<String>() ?? [],
        );
  final String path;
  final String method;
  final String summary;
  final String operationId;
  final Map<String, ResponseScheme> responses;
  final List<ParamModel> parameters;
  final List<String> tags;
}

class ResponseScheme {
  ResponseScheme({
    required this.description,
    this.schema,
    this.custom,
    this.subModels,
  });

  factory ResponseScheme.fromJson(Json json, String path) {
    var schema = as<Json>(
      json['schema'] ??
          as<Json>(json['content'])?.values.firstOrNull?['schema'],
      emptyJson,
    )!;
    final subModels = <ModelEntry>[];

    return ResponseScheme(
      description: as<String>(json['description'], '')!,
      schema: getTypeName(
        schema['\$ref']?.split('/').last,
      ),
      custom: schema.containsKey('\$ref')
          ? null
          : ModelEntry.fromJson(
              schema,
              'Resp${pascalCase(path.split('/').last)}',
              getTypeName,
              (m) => subModels.add(m),
            ),
      subModels: subModels,
    );
  }

  final String description;
  final String? schema;
  final ModelEntry? custom;
  final List<ModelEntry>? subModels;
}

class ParamModel {
  ParamModel({
    required this.isRequired,
    required this.type,
    required this.inWhere,
    required this.name,
  }) : paramName = camelCase(name);

  ParamModel.fromJson(Json json)
      : this(
          isRequired: as<bool>(json['required'], false)!,
          type: TypeModel.fromJson(json, getTypeName),
          inWhere: as<String>(json['in'], '')!,
          name: as<String>(json['name'], '')!,
        );

  bool isRequired;
  TypeModel type;
  String inWhere;
  String name;
  String paramName;

  bool get isPath => inWhere == 'path';
}

class SecurityDefinition {
  SecurityDefinition({
    required this.key,
    required this.type,
    required this.description,
    required this.name,
    required this.inWhere,
  });

  SecurityDefinition.fromJson(Json json, String key)
      : this(
          key: key,
          type: as<String>(json['type'], '')!,
          description: as<String>(json['description'], '')!,
          name: as<String>(json['name'], '')!,
          inWhere: as<String>(json['inWhere'], '')!,
        );

  final String key;
  final String type;
  final String description;
  final String name;
  final String inWhere;
}
