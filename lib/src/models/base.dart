import 'dart:convert';

import '../utils/utils.dart';
import '../utils/core.dart';

typedef DataParser<T> = T Function(dynamic);

T defaultParser<T>(data) => as<T>(data) ?? getDefault<T>();

typedef Json = Map<String, dynamic>;

const emptyJson = <String, dynamic>{};

T getDefault<T>() {
  if (null is T) {
    return null as T;
  } else if (T == int) {
    return 0 as T;
  } else if (T == double || T == num) {
    return 0.0 as T;
  } else if (T == BigInt) {
    return BigInt.zero as T;
  } else if (T == String) {
    return '' as T;
  } else if (T == bool) {
    return false as T;
  } else if (T == DateTime) {
    return DateTime.fromMillisecondsSinceEpoch(0) as T;
  } else if (T == List) {
    return [] as T;
  } else if (T == Json) {
    return emptyJson as T;
  } else if (T == Map) {
    return {} as T;
  }
  throw Exception('Failed to create default value for $T.');
}

T? as<T>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  if (value == null) {
    return defaultValue;
  }

  // num 强转
  if (value is num) {
    dynamic result;
    if (T == double) {
      result = value.toDouble();
    } else if (T == int) {
      result = value.toInt() as T;
    } else if (T == BigInt) {
      result = BigInt.from(value) as T;
    } else if (T == bool) {
      result = (value != 0) as T;
    } else if (T == DateTime) {
      if (value < 10000000000) {
        value *= 1000;
      }
      result = DateTime.fromMillisecondsSinceEpoch(value.toInt()) as T;
    }
    if (result != null) {
      logger.info(
        'Force cast $value(${value.runtimeType}) to $T ($result)',
        StackTrace.current.cast(3),
      );
      return result as T;
    }
  } else

  // String parse
  if (value is String) {
    dynamic result;
    if (T == int) {
      result = int.tryParse(value);
    } else if (T == double) {
      result = double.tryParse(value);
    } else if (T == BigInt) {
      result = BigInt.tryParse(value);
    } else if (T == DateTime) {
      // DateTime.parse不支持 /
      if (value.contains('/')) {
        value = value.replaceAll('/', '-');
      }
      result = DateTime.tryParse(value);
    } else if (T == bool) {
      return {'1', '-1', 'true', 'yes'}.contains(value.toLowerCase()) as T;
    } else {
      logger.warning(
        'Unsupported type cast from $value (${value.runtimeType}) to $T.',
        StackTrace.current.cast(3),
      );
      return defaultValue;
    }
    logger.fine(
      'Force cast $value(${value.runtimeType}) to $T ($result)',
      StackTrace.current.cast(3),
    );
    return result as T? ?? defaultValue;
  }

  // String 强转
  if (T == String) {
    logger.info(
      'Force cast $value(${value.runtimeType}) to $T',
      StackTrace.current.cast(3),
    );
    return '$value' as T;
  }
  logger.warning(
    'Type $T cast error: $value (${value.runtimeType})',
    StackTrace.current.cast(3),
  );

  return defaultValue;
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
  Json toJson() => super.toJson()
    ..addAll({
      'total': total,
      'page': page,
    });
}
