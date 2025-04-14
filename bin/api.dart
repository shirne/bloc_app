import 'dart:convert';
import 'dart:io';

import '_common.dart';

typedef Json = Map<String, dynamic>;

final paramReg = RegExp(r'\{([\w]+)\}');
const _apiPath = 'lib/src/globals/api/';
const _modelPath = 'lib/src/models/';

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
      final entry = OpenApiModel.fromJson(jsonDecode(jsonStr));

      final models = createModel(entry.components);

      File('$_modelPath$name.dart').writeAsStringSync(models);

      final apis = createApi(entry.paths, '', className);

      File('$_apiPath$name.dart').writeAsStringSync(apis);
    } else {
      final entry = SwaggerModel.fromJson(jsonDecode(jsonStr));

      final models = createModel(entry.definitions);

      File('$_modelPath$name.dart').writeAsStringSync(models);

      final apis = createApi(entry.paths, entry.basePath, className);

      File('$_apiPath$name.dart').writeAsStringSync(apis);
    }
  } catch (e) {
    stdout.writeln("Err: $e");
    stdout.writeln(StackTrace.current);
  }
}

String createModel(List<ModelEntry> entries) {
  final content = StringBuffer();
  content.writeln('import \'base.dart\';');
  for (var i in entries) {
    content.writeln(createModelClass(i));
  }

  return content.toString();
}

String createModelClass(ModelEntry data) {
  final className = getTypeName(data.name);
  final content = StringBuffer();

  final hasFields = data.properties.isNotEmpty;

  content.write('''
class $className extends Base {
  $className(${hasFields ? '{' : ''}
''');
  for (var f in data.properties) {
    content
        .writeln('    ${f.isRequired ? 'required ' : ''}this.${f.fieldName},');
  }
  content.writeln('  ${hasFields ? '}' : ''});');
  content.write('''
  $className.fromJson(Json json):this(
''');
  for (var f in data.properties) {
    if (f.type.type == 'List') {
      final isBase = f.type.item?.isBase ?? true;
      final transType = f.type.item != null
          ? isBase
              ? '?.cast<${f.type.item?.type}>()'
              : '?.map<${f.type.item?.typeName}>((e)=>${f.type.item?.typeName}.fromJson(e)).toList()'
          : '';
      content.writeln(
        '    ${f.fieldName}: as<${f.type.type}>(json[\'${f.name}\'])$transType${f.isRequired ? ' ?? []' : ''},',
      );
    } else {
      if (f.type.isBase) {
        content.writeln(
          '    ${f.fieldName}: as<${f.type.typeName}>(json[\'${f.name}\']${getDefault(f)})${f.isRequired ? '!' : ''},',
        );
      } else {
        if (f.isRequired) {
          content.writeln(
            '    ${f.fieldName}: ${f.type.typeName}.fromJson(as<Json>(json[\'${f.name}\']) ?? emptyJson),',
          );
        } else {
          content.writeln(
            '    ${f.fieldName}: ${f.type.typeName}.tryFromJson(as<Json>(json[\'${f.name}\'])),',
          );
        }
      }
    }
  }
  content.writeln('  );');

  content.write('''
  static $className? tryFromJson(Json? json) {
    if (json == null) return null;
    return $className.fromJson(json);
  }
''');

  for (var f in data.properties) {
    if (f.description != null) {
      content.writeln('  /// ${f.description}');
    }
    content.writeln(
      '  final ${f.type.typeName}${f.isRequired ? '' : '?'} ${f.fieldName};',
    );
  }

  content.writeln('''

  @override
  Json toJson() => {''');
  for (var f in data.properties) {
    content.writeln(
      '      \'${f.name}\': ${f.fieldName}${f.type.type == 'DateTime' ? '.toString()' : ''},',
    );
  }
  content.writeln('    };');

  content.writeln('}');

  return content.toString();
}

String getDefault(FieldModel f) {
  if (!f.isRequired) {
    return '';
  }
  String typeValue = '';
  switch (f.type.type) {
    case 'int':
      typeValue = '0';
    case 'double':
      typeValue = '0';
    case 'DateTime':
      typeValue = 'DateTime.now()';

    case 'bool':
      typeValue = 'false';
    case 'String':
      typeValue = "''";
    case 'List':
      typeValue = '[]';
    case 'Json':
    case 'Map':
      typeValue = '{}';
  }
  return ', $typeValue';
}

String createApi(
  Map<String, List<RequestEntry>> json,
  String basePath,
  String className,
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
      final response = method.responses['200']?.schema;
      final respType = response == null ? '' : '<$response>';
      content.write('''
  /// ${method.summary}
  Future<ApiResult$respType> $methodName(${params.isEmpty ? '' : '{'}
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
        content.writeln('      dataParser: (d)=> $response.fromJson(d),');
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
  if (name.endsWith('Resp') || name.endsWith('Req')) {
    return name;
  }
  return '${name}Model';
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
                  .map<ModelEntry>((e) => ModelEntry.fromJson(e.value, e.key))
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
                  .map<ModelEntry>((e) => ModelEntry.fromJson(e.value, e.key))
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
                (k, v) => MapEntry(k, ResponseScheme.fromJson(v)),
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
  });

  ResponseScheme.fromJson(Json json)
      : this(
          description: as<String>(json['description'], '')!,
          schema: getTypeName(
            as<Json>(
                    json['schema'] ??
                        as<Json>(json['content'])
                            ?.values
                            .firstOrNull?['schema'],
                    emptyJson)!['\$ref']
                ?.split('/')
                .last,
          ),
        );

  final String description;
  final String? schema;
}

class FieldModel {
  FieldModel({
    required this.name,
    required this.type,
    required this.description,
    required this.isRequired,
  }) : fieldName = camelCase(name);

  FieldModel.fromJson(Json json, String name, List<String>? requires)
      : this(
          name: name,
          type: TypeModel.fromJson(json),
          description: as<String>(json['description']),
          isRequired: requires?.contains(json['name']) ?? false,
        );

  final String fieldName;
  final String name;
  final String? description;
  final TypeModel type;
  final bool isRequired;
}

class TypeModel {
  TypeModel({
    this.type,
    this.ref,
    this.format,
    this.item,
  });

  TypeModel.fromJson(Json json)
      : this(
          type: parseType(as<String>(json['type'])),
          ref: getTypeName(
            as<String>(json['\$ref'] ?? json['schema']?['\$ref'])
                ?.split('/')
                .last,
          ),
          format: as<String>(json['format']),
          item: TypeModel.tryFromJson(json['items']),
        );

  static TypeModel? tryFromJson(Json? json) {
    if (json == null) return null;
    return TypeModel.fromJson(json);
  }

  final String? type;
  final String? ref;
  final String? format;
  final TypeModel? item;

  String get typeName {
    if (type != null) {
      if (type == 'List' && item != null) {
        return 'List<${item!.typeName}>';
      } else {
        return type!;
      }
    }
    return ref ?? 'String';
  }

  bool get isBase =>
      type == 'int' ||
      type == 'double' ||
      type == 'String' ||
      type == 'bool' ||
      type == 'Map' ||
      type == 'Json' ||
      type == 'DateTime';

  static String? parseType(String? type) {
    if (type == 'integer') {
      return 'int';
    } else if (type == 'float' || type == 'double' || type == 'number') {
      return 'double';
    } else if (type == 'string') {
      return 'String';
    } else if (type == 'boolean') {
      return 'bool';
    } else if (type == 'array') {
      return 'List';
    } else if (type == 'map' || type == 'dictionary' || type == 'object') {
      return 'Json';
    }
    return type;
  }
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
          type: TypeModel.fromJson(json),
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

class ModelEntry {
  ModelEntry({
    required this.name,
    required this.type,
    required this.title,
    required this.properties,
    required this.requires,
  });

  ModelEntry.fromJson(Json json, String name)
      : this(
          name: name,
          type: as<String>(json['type'], '')!,
          title: as<String>(json['title'] ?? json['description'], '')!,
          properties: as<Json>(json['properties'])
                  ?.entries
                  .map<FieldModel>(
                    (d) => FieldModel.fromJson(
                      as<Json>(d.value, emptyJson)!,
                      d.key,
                      json['required']?.cast<String>(),
                    ),
                  )
                  .toList() ??
              [],
          requires: as<List>(json['required'])?.cast<String>() ?? [],
        );

  final String name;
  final String type;
  final String title;
  final List<FieldModel> properties;
  final List<String> requires;
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
