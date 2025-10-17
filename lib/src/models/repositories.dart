import 'package:isar_community/isar.dart';

part 'repositories.g.dart';

enum UserStatus {
  none,
  logged,
  verified;
}

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, replace: true)
  int uid = 0;

  String nickname = '';

  int roleLevel = 0;

  @enumerated
  UserStatus status = UserStatus.none;
}

@collection
class UserAvatar {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, replace: true)
  int uid = 0;

  String avatar = '';

  String origin = '';
  String size80 = '';
  String size40 = '';
  String size20 = '';

  int timestamp = 0;

  String size(int? size) {
    if (size != null) {
      if (size <= 20) {
        return size20;
      } else if (size <= 40) {
        return size40;
      }
      if (size <= 80) {
        return size80;
      }
    }
    return origin;
  }
}
