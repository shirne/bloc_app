import 'dart:convert';

import '../utils/utils.dart';
import 'user.dart';

abstract class Base {
  static T? fromJson<T>(Map<String, dynamic>? json) {
    switch (T) {
      case User:
        return User.fromJson(json) as T?;
      // TODO: add more models
      case Model:
        return Model.fromJson(json) as T?;
      default:
        final tStr = T.toString();
        if (tStr.startsWith('Model')) {
          final isList = tStr.startsWith('ModelList');
          switch (tStr.substring(tStr.indexOf('<') + 1, tStr.indexOf('>'))) {
            case 'User':
              return (isList
                  ? ModelList<User>.fromJson(json)
                  : ModelPage<User>.fromJson(json)) as T?;
            // TODO: add more models
            default:
              return (isList
                  ? ModelList<Model>.fromJson(json)
                  : ModelPage<Model>.fromJson(json)) as T?;
          }
        }

        break;
    }
    log.e('unsupported model $T');
    return null;
  }

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// 通用的接口返回模型
class Model extends Base {
  Map<String, dynamic> data;
  Model(this.data);

  Model.fromJson(Map<String, dynamic>? json) : this(json ?? {});

  @override
  Map<String, dynamic> toJson() {
    return data;
  }

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

  ModelList.fromJson(Map<String, dynamic>? json)
      : this(
            lists: (json?['list'] as List<dynamic>?)
                ?.map<T?>((item) => Base.fromJson<T>(item))
                .whereType<T>()
                .toList());

  @override
  Map<String, dynamic> toJson() {
    return {
      'lists':
          lists?.map<Map<String, dynamic>>((item) => item.toJson()).toList(),
    };
  }
}

/// 分页数据的模型，以下定义的字段可根据实际情况调整
class ModelPage<T extends Base> extends ModelList<T> {
  int total;
  int page;
  ModelPage({this.total = 0, this.page = 0, List<T>? lists})
      : super(lists: lists);

  ModelPage.fromJson(Map<String, dynamic>? json)
      : this(
            total: json?['total'] ?? 0,
            page: json?['page'] ?? 0,
            lists: (json?['lists'] as List<dynamic>?)
                ?.map<T?>((item) => Base.fromJson<T>(item))
                .whereType<T>()
                .toList());

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['total'] = total;
    json['page'] = page;
    return json;
  }
}
