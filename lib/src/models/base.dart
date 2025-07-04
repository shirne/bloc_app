import 'dart:convert';

import '../utils/utils.dart';
import '../utils/core.dart';

typedef DataParser<T> = T Function(dynamic m);

T defaultParser<T>(data) => as<T>(data) ?? getDefault<T>();

typedef Json = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

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
      return result as T;
    }
  } else

  // String parse
  if (value is String) {
    if (value.isEmpty) {
      return defaultValue;
    }
    dynamic result;
    if (T == int) {
      result = int.tryParse(value) ?? double.tryParse(value)?.toInt();
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
    } else if (T == JsonList || T == Json) {
      try {
        return jsonDecode(value) as T;
      } catch (e) {
        logger.warning(
          'Json decode error: $e',
          StackTrace.current.cast(3),
        );
      }
    } else {
      logger.warning(
        'Unsupported type cast from $value (${value.runtimeType}) to $T.',
        StackTrace.current.cast(3),
      );
      return defaultValue;
    }
    if (result == null) {
      logger.fine(
        'Cast $value(${value.runtimeType}) to $T failed',
        StackTrace.current.cast(3),
      );
    }
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

List<T>? asList<T>(dynamic value) {
  return as<List>(value)?.map<T>((d) => as(d)).toList();
}

abstract class Base {
  const Base();

  Base.fromJson(Json json);

  Json toJson();

  Base clone();

  @override
  String toString() => jsonEncode(toJson());
}

/// 通用的接口返回模型
class Model implements Base {
  Json data;
  Model(this.data);

  Model.fromJson(Json? json) : this(json ?? {});

  @override
  Model clone({Json? data}) => Model(data ?? this.data);

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
class ModelList<T extends Base> implements Base {
  ModelList({this.items});

  ModelList.fromJson(Json? json, [DataParser<T>? dataParser])
      : this(
          items: as<List>(json?['items'] ?? json?['list'] ?? json?['data'])
              ?.map<T?>(dataParser ?? (item) => item as T?)
              .whereType<T>()
              .toList(),
        );

  List<T>? items;

  bool get isEmpty => items?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  @override
  ModelList clone({List<T>? items}) => ModelList(items: items ?? this.items);

  @override
  Json toJson() => {
        'items': items?.map<Json>((item) => item.toJson()).toList(),
      };
}

/// 分页数据的模型，以下定义的字段可根据实际情况调整
class ModelPage<T extends Base> extends ModelList<T> {
  ModelPage({
    this.total = 0,
    this.page = 0,
    this.pageSize = 10,
    this.totalPage = 0,
    super.items,
  });

  ModelPage.fromJson(Json? json, [DataParser<T>? dataParser])
      : this(
          total: as<int>(json?['total'], 0)!,
          page: as<int>(
            json?['page'] ?? json?['current'] ?? json?['currentPage'],
            0,
          )!,
          pageSize: as<int>(
            json?['page_size'] ?? json?['pageSize'] ?? json?['size'],
            8,
          )!,
          totalPage: as<int>(
            json?['pages'] ?? json?['total_page'] ?? json?['totalPage'],
            1,
          )!,
          items: as<List>(json?['items'] ?? json?['list'])
              ?.map<T?>(dataParser ?? (item) => item as T?)
              .whereType<T>()
              .toList(),
        );

  final int total;
  final int page;
  final int totalPage;
  final int pageSize;

  @override
  Json toJson() => super.toJson()
    ..addAll({
      'total': total,
      'page': page,
      'page_size': pageSize,
      'total_page': totalPage,
    });
}

class ActionResult implements Base {
  ActionResult(this.state);

  ActionResult.fromJson(Json json) : this(as<int>(json['state'], 0)!);

  final int state;

  bool get isSuccess => state == 1;

  @override
  ActionResult clone({int? state}) => ActionResult(state ?? this.state);

  @override
  Json toJson() => {
        'state': state,
      };
}

abstract class UserInfoModel {
  int get id;
  String get nickname;
  String get avator;
}
