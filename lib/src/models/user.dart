import 'base.dart';

class UserModel extends Base {
  const UserModel({
    this.id = 0,
    this.username = '',
    this.nickname = '',
    this.avatar = '',
    this.rate = 0,
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
          rate: as<double>(json?['rate']) ?? 0,
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
  final double rate;
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
        'rate': rate,
        'points': points,
        'level': level,
        'status': status,
        'create_time': createTime,
        'update_time': updateTime,
      };
}

class TokenModel extends Base {
  const TokenModel({
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
