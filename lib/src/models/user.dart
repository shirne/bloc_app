import 'base.dart';

class User extends Base {
  int userId;
  String username;
  String nickname;
  String token;
  int expire;
  DateTime? createAt;
  bool isAuthed;
  bool needAuth;
  bool get isValid => userId > 0;

  User({
    this.userId = 0,
    this.username = '',
    this.nickname = '',
    this.token = '',
    this.expire = 0,
    this.isAuthed = false,
    this.needAuth = false,
    this.createAt,
  });

  User.fromJson(Json? json)
      : this(
          userId: as<int>(json?['user_id'] ?? json?['id']) ?? 0,
          username: json?['username'] ?? '',
          nickname: json?['nickname'] ?? '',
          token: json?['token'] ?? '',
          expire: as<int>(json?['expire']) ?? 0,
          createAt: as<DateTime>(json?['create_at']),
        );

  @override
  Json toJson() => {
        'user_id': userId,
        'username': username,
        'nickname': nickname,
        'token': token,
        'expire': expire,
        'create_at': createAt,
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
