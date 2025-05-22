import '_common.dart';

typedef TypeNameParser = String? Function(String?);

String createModelClass(ModelEntry data, String? className) {
  if (className == null || className.contains('<')) return '';
  final content = StringBuffer();

  final hasFields = data.properties.isNotEmpty;

  content.write('''
class $className implements Base {
  $className(${hasFields ? '{' : ''}
''');
  for (var f in data.properties) {
    content.writeln(
      '    ${f.isRequired ? 'required ' : ''}this.${f.fieldName}${f.isRequired || f.defaultValue == null ? '' : getDefault(f, '=')},',
    );
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
        '    ${f.fieldName}: as<${f.type.type}>(json[\'${f.name}\'])$transType${f.nullable ? '' : ' ?? []'},',
      );
    } else {
      if (f.type.isBase) {
        content.writeln(
          '    ${f.fieldName}: as<${f.type.typeName}>(json[\'${f.name}\']${getDefault(f)})${f.nullable ? '' : '!'},',
        );
      } else {
        if (f.nullable) {
          content.writeln(
            '    ${f.fieldName}: ${f.type.typeName}.tryFromJson(as<Json>(json[\'${f.name}\'])),',
          );
        } else {
          content.writeln(
            '    ${f.fieldName}: ${f.type.typeName}.fromJson(as<Json>(json[\'${f.name}\']) ?? emptyJson),',
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

  var cloneParams = StringBuffer();
  var cloneArgs = StringBuffer();

  if (hasFields) {
    cloneParams.writeln('{');

    for (var f in data.properties) {
      if (f.title != null) {
        content.writeln('  /// ${f.title}');
      }
      if (f.description != null) {
        content.writeln('  /// ${f.description}');
      }
      content.writeln(
        '  final ${f.type.typeName}${f.nullable ? '?' : ''} ${f.fieldName};',
      );
      if (f.nullable) {
        cloneParams
            .writeln('     Optional<${f.type.typeName}>? ${f.fieldName},');
        cloneArgs.writeln(
          '     ${f.fieldName}: ${f.fieldName}.absent(this.${f.fieldName}),',
        );
      } else {
        cloneParams.writeln('     ${f.type.typeName}? ${f.fieldName},');
        cloneArgs.writeln(
          '     ${f.fieldName}: ${f.fieldName} ?? this.${f.fieldName},',
        );
      }
    }

    cloneParams.write('}');
  }

  content.write('''

  @override
  $className clone(${cloneParams.toString()}) => $className(${cloneArgs.toString()});
''');

  content.writeln('''

  @override
  Json toJson() => {''');
  for (var f in data.properties) {
    if (isBaseType(f.type.typeName)) {
      content.writeln(
        '      \'${f.name}\': ${f.fieldName}${f.type.type == 'DateTime' ? '?.toString()' : ''},',
      );
    } else if (f.type.type == 'List') {
      if (isBaseType(f.type.item?.type)) {
        if (f.type.item?.type == 'DateTime') {
          content.writeln(
            '      \'${f.name}\': ${f.fieldName}${f.nullable ? '?' : ''}.map((e) => e.toString()).toList(),',
          );
        } else {
          content.writeln(
            '      \'${f.name}\': ${f.fieldName},',
          );
        }
      } else {
        content.writeln(
          '      \'${f.name}\': ${f.fieldName}${f.nullable ? '?' : ''}.map((e) => e.toJson()).toList(),',
        );
      }
    } else {
      content.writeln(
        '      \'${f.name}\': ${f.fieldName}${f.nullable ? '?' : ''}.toJson(),',
      );
    }
  }
  content.writeln('    };');

  content.writeln('}');

  return content.toString();
}

String getDefault(FieldModel f, [prefix = ',']) {
  if (f.defaultValue != null) {
    return '$prefix ${f.defaultValue}';
  }
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
  return '$prefix $typeValue';
}

class ModelEntry {
  ModelEntry({
    required this.name,
    required this.type,
    required this.title,
    required this.properties,
    required this.requires,
  });

  ModelEntry.fromJson(
    Json json,
    String name,
    TypeNameParser getTypeName, [
    Function(ModelEntry)? onSubModels,
  ]) : this(
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
                      getTypeName,
                      onSubModels,
                    ),
                  )
                  .toList() ??
              [],
          requires: as<List>(json['required'])?.cast<String>() ?? [],
        );

  factory ModelEntry.fromExample(
    Json json,
    String name,
    TypeNameParser getTypeName, [
    Function(ModelEntry)? onSubModels,
  ]) {
    final requires = <String>[];
    final properties = <FieldModel>[];
    for (var e in json.entries) {
      if (e.value != null) {
        // 默认有值就require
        requires.add(e.key);
        if (e.value is List) {
          if (e.value.isEmpty) {
            properties.add(FieldModel(
              name: e.key,
              isRequired: true,
              type: TypeModel(type: 'List'),
            ));
          } else {
            var subType = switch (e.value.first) {
              (int _) => 'int',
              (double _) => 'double',
              (bool _) => 'bool',
              (DateTime _) => 'DateTime',
              (String _) => 'String',
              _ => pascalCase('${e.key}ItemModel'),
            };
            if (!isBaseType(subType)) {
              onSubModels?.call(
                ModelEntry.fromExample(
                  e.value.first,
                  subType,
                  getTypeName,
                  onSubModels,
                ),
              );
            }
            properties.add(FieldModel(
              name: e.key,
              isRequired: true,
              type: TypeModel(type: 'List', item: TypeModel(type: subType)),
            ));
          }
        } else if (e.value is Map) {
          var subType = pascalCase('${e.key}Model');
          onSubModels?.call(
            ModelEntry.fromExample(e.value, subType, getTypeName, onSubModels),
          );
          properties.add(FieldModel(
            name: e.key,
            isRequired: true,
            type: TypeModel(type: subType),
          ));
        } else {
          properties.add(FieldModel(
            name: e.key,
            isRequired: true,
            type: TypeModel(
                type: switch (e.value) {
              (int _) => 'int',
              (double _) => 'double',
              (bool _) => 'bool',
              (DateTime _) => 'DateTime',
              _ => 'String',
            }),
          ));
        }
      } else {
        // 值为空则根据名称判断
        if (e.key.startsWith('is_')) {
          properties.add(FieldModel(
            name: e.key,
            type: TypeModel(type: 'bool'),
          ));
        } else if (e.key.endsWith('_time') || e.key.endsWith('_at')) {
          properties.add(FieldModel(
            name: e.key,
            type: TypeModel(type: 'DateTime'),
          ));
        } else if (e.key.endsWith('_id') || e.key == 'id') {
          properties.add(FieldModel(
            name: e.key,
            type: TypeModel(type: 'int'),
          ));
        } else {
          properties.add(FieldModel(
            name: e.key,
            type: TypeModel(type: 'String'),
          ));
        }
      }
    }
    return ModelEntry(
      name: name,
      type: 'object',
      title: name,
      properties: properties,
      requires: requires,
    );
  }

  final String name;
  final String type;
  final String title;
  final List<FieldModel> properties;
  final List<String> requires;
}

class FieldModel {
  FieldModel({
    required this.name,
    required this.type,
    this.title,
    this.description,
    this.defaultValue,
    this.isRequired = false,
  }) : fieldName = camelCase(name);

  factory FieldModel.fromJson(
    Json json,
    String name,
    List<String>? requires,
    TypeNameParser getTypeName, [
    Function(ModelEntry)? onSubModels,
  ]) {
    String? subModelName;
    if (onSubModels != null &&
        json['type'] == 'object' &&
        json['properties']?.isNotEmpty == true) {
      // 名字可能重复?
      subModelName = pascalCase('${name}_model');
      onSubModels(ModelEntry.fromJson(json, subModelName, getTypeName));
      json['type'] = subModelName;
      json['\$ref'] = subModelName; // 可能没用？
    }
    return FieldModel(
      name: name,
      type: TypeModel.fromJson(json, getTypeName),
      title: as<String>(json['title']),
      description: as<String>(json['description']),
      defaultValue: json['default'],
      isRequired: requires?.contains(json['name'] ?? name) ?? false,
    );
  }

  bool get nullable => !isRequired && defaultValue == null;

  final String fieldName;
  final String name;
  final String? title;
  final String? description;
  final dynamic defaultValue;
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

  TypeModel.fromJson(Json json, TypeNameParser getTypeName)
      : this(
          type: parseType(as<String>(json['type'])),
          ref: getTypeName(
            as<String>(json['\$ref'] ?? json['schema']?['\$ref'])
                ?.split('/')
                .last,
          ),
          format: as<String>(json['format']),
          item: TypeModel.tryFromJson(json['items'], getTypeName),
        );

  static TypeModel? tryFromJson(Json? json, TypeNameParser getTypeName) {
    if (json == null) return null;
    return TypeModel.fromJson(json, getTypeName);
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

  bool get isBase => isBaseType(type ?? ref);

  static String? parseType(String? type) {
    if (type != null) {
      var lowerType = type.toLowerCase();
      if (lowerType == 'integer') {
        return 'int';
      } else if (lowerType == 'float' ||
          lowerType == 'double' ||
          lowerType == 'number') {
        return 'double';
      } else if (lowerType == 'string') {
        return 'String';
      } else if (lowerType == 'boolean') {
        return 'bool';
      } else if (lowerType == 'array') {
        return 'List';
      } else if (lowerType == 'map' ||
          lowerType == 'dictionary' ||
          lowerType == 'object') {
        return 'Json';
      }
    }
    return type;
  }
}

bool isBaseType(String? type) {
  return type == null ||
      type == 'int' ||
      type == 'double' ||
      type == 'String' ||
      type == 'bool' ||
      type == 'Map' ||
      type == 'Json' ||
      type == 'DateTime';
}
