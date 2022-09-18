import 'dart:convert';

import '../utils/utils.dart';

typedef DataParser<T> = T Function(dynamic);

typedef Json = Map<String, dynamic>;

T? as<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  if (value is String) {
    if (T == int) {
      return int.tryParse(value) as T?;
    } else if (T == double) {
      return double.tryParse(value) as T?;
    } else if (T == DateTime) {
      // DateTime.parse不支持 /
      if (value.contains('/')) {
        value = value.replaceAll('/', '-');
      }
      return DateTime.tryParse(value) as T?;
    }
  }
  if (value != null) {
    if (T == String) {
      return '$value' as T;
    }
    log.e('Type $T cast error: $value (${value.runtimeType})');
  }
  return null;
}

abstract class Base {
  Json toJson();

  @override
  String toString() => jsonEncode(toJson());
}

/// 通用的接口返回模型
class Model extends Base {
  Json data;
  Model(this.data);

  Model.fromJson(Json? json) : this(json ?? {});

  @override
  Json toJson() => data;

  dynamic operator [](String key) {
    return data[key];
  }

  void operator []=(String key, dynamic value) {
    data[key] = value;
  }
}

/// 列表数据的模型
class ModelList<T extends Base> extends Base {
  List<T>? lists;
  ModelList({this.lists});

  ModelList.fromJson(Json? json, [DataParser<T>? dataParser])
      : this(
          lists: (json?['list'] as List<dynamic>?)
              ?.map<T?>(dataParser ?? (item) => item as T?)
              .whereType<T>()
              .toList(),
        );

  @override
  Json toJson() => {
        'lists': lists?.map<Json>((item) => item.toJson()).toList(),
      };
}

/// 分页数据的模型，以下定义的字段可根据实际情况调整
class ModelPage<T extends Base> extends ModelList<T> {
  int total;
  int page;
  ModelPage({this.total = 0, this.page = 0, List<T>? lists})
      : super(lists: lists);

  ModelPage.fromJson(Json? json, [DataParser<T>? dataParser])
      : this(
          total: json?['total'] ?? 0,
          page: json?['page'] ?? 0,
          lists: (json?['lists'] as List<dynamic>?)
              ?.map<T?>(dataParser ?? (item) => item as T?)
              .whereType<T>()
              .toList(),
        );

  @override
  Json toJson() {
    Json json = super.toJson();
    json['total'] = total;
    json['page'] = page;
    return json;
  }
}
