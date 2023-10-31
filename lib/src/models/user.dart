import 'dart:convert';

import '../utils/core.dart';
import 'base.dart';

class UserModel extends Base {
  static const empty = UserModel();

  const UserModel({
    this.id = 0,
    this.username = '',
    this.nickname = '',
    this.avatar = '',
    this.password = '',
    this.followCount = 0,
    this.fansCount = 0,
    this.score = 0,
    this.expire = 0,
    this.points = 0,
    this.level = 0,
    this.status = 0,
    this.createTime,
    this.updateTime,
  });

  UserModel.fromJson(Json? json)
      : this(
          id: as<int>(json?['id']) ?? 0,
          username: json?['username'] ?? '',
          nickname: json?['nickname'] ?? '',
          avatar: json?['avatar'] ?? '',
          password: json?['password'] ?? '',
          followCount: as<int>(json?['follow_num']) ?? 0,
          fansCount: as<int>(json?['fans_num']) ?? 0,
          score: as<double>(json?['score']) ?? 0,
          points: as<int>(json?['points']) ?? 0,
          level: as<int>(json?['level']) ?? 0,
          status: as<int>(json?['status']) ?? 0,
          createTime: as<DateTime>(json?['create_time']),
          updateTime: as<DateTime>(json?['update_time']),
        );

  final int id;
  final String username;
  final String nickname;
  final String avatar;
  final String password;
  final int followCount;
  final int fansCount;
  final double score;
  final int expire;
  final int points;
  final int level;
  final int status;
  final DateTime? createTime;
  final DateTime? updateTime;

  bool get isValid => id > 0;

  @override
  Json toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'avatar': avatar,
        'password': password,
        'follow_num': followCount,
        'fans_num': fansCount,
        'score': score,
        'points': points,
        'level': level,
        'status': status,
        'create_time': createTime,
        'update_time': updateTime,
      };
}

class JwtToken extends Base {
  JwtToken(this.token) : data = parseData(token);

  final String token;
  final Json data;

  int get uid => as<int>(data['uid'], 0)!;
  int get status => as<int>(data['status'], 0)!;
  int get expire => as<int>(data['exp'], 0)!;

  bool get isExpire => expire <= DateTime.now().secondsSinceEpoch + 10;
  bool get isValid => token.isNotEmpty;

  static Json parseData(String token) {
    if (token.isEmpty) return emptyJson;
    final part = token.split('.');
    if (part.length != 3) return emptyJson;
    if (part[1].length % 4 != 0) {
      part[1] += '=' * (4 - part[1].length % 4);
    }
    final json = utf8.decode(base64Decode(part[1]));

    return jsonDecode(json);
  }

  @override
  Json toJson() => {
        'value': token,
      };

  @override
  String toString() => token;
}

class TokenModel extends Base {
  static final empty = TokenModel();

  TokenModel({
    this.accessToken = '',
    this.refreshToken = '',
    this.expireIn = 0,
    this.createTime,
  });

  TokenModel.fromJson(Json json)
      : this(
          accessToken: as<String>(json['access_token'], '')!,
          refreshToken: as<String>(json['refresh_token'], '')!,
          expireIn: as<int>(json['expire_in'], 0)!,
          createTime: as<DateTime>(json['update_time'] ?? json['create_time']),
        );

  final String accessToken;
  final int expireIn;
  final String refreshToken;
  final DateTime? createTime;

  bool get isValid => accessToken.isNotEmpty;

  bool get isExpire =>
      createTime == null ||
      DateTime.now().difference(createTime!).inSeconds > expireIn;

  @override
  Json toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expire_in': expireIn,
        'create_time': createTime?.toString(),
      };
}

class UserInfo extends Base {
  @override
  Json toJson() => {};
}

class UserLevel extends Base {
  @override
  Json toJson() => {};
}

class UserAgentLevel extends Base {
  @override
  Json toJson() => {};
}
