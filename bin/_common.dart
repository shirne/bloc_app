import 'dart:convert';
import 'dart:developer';

import 'package:logging/logging.dart';

final pascalCaseReg = RegExp('(^|_)([a-z])');
final camelCaseReg = RegExp('_([a-z])');

final snakeCaseFirstReg = RegExp('^[A-Z]');
final snakeCaseReg = RegExp('[A-Z]+');

typedef DataParser<T> = T Function(dynamic);

T defaultParser<T>(data) => as<T>(data) ?? getDefault<T>();

typedef Json = Map<String, dynamic>;

const emptyJson = <String, dynamic>{};

final logger = Logger.root
  ..level = Level.ALL
  ..onRecord.listen((record) {
    log(
      record.message,
      time: record.time,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
      sequenceNumber: record.sequenceNumber,
    );
  });

StackTrace? castStackTrace(StackTrace? trace, [int lines = 3]) {
  if (trace != null) {
    return StackTrace.fromString(
      trace.toString().split('\n').sublist(0, lines).join('\n'),
    );
  }
  return null;
}

extension StackTraceExt on StackTrace {
  StackTrace cast(int lines) {
    return castStackTrace(this, lines)!;
  }
}

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

String snakeCase(String name) {
  return name
      .replaceFirstMapped(
        snakeCaseFirstReg,
        (item) => item.group(0)!.toLowerCase(),
      )
      .replaceAllMapped(
        snakeCaseReg,
        (match) => '_${match.group(0)!.toLowerCase()}',
      );
}

String camelCase(String name) {
  return name.replaceAllMapped(
    camelCaseReg,
    (match) => match.group(1)!.toUpperCase(),
  );
}

String pascalCase(String name) {
  return name.replaceAllMapped(
    pascalCaseReg,
    (match) => match.group(2)!.toUpperCase(),
  );
}
