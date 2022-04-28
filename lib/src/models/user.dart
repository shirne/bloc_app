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

  User.fromJson(Map<String, dynamic>? json)
      : this(
          userId: json?['user_id'] ?? json?['id'] ?? 0,
          username: json?['username'] ?? '',
          nickname: json?['nickname'] ?? '',
          token: json?['token'] ?? '',
          expire: json?['expire'] ?? '',
          createAt: json?['create_at'] ?? '',
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'nickname': nickname,
      'token': token,
      'expire': expire,
      'create_at': createAt,
    };
  }
}
