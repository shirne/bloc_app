import '../utils/core.dart';
import 'base.dart';

class MemberUpdateDTO implements Base {
  MemberUpdateDTO({
    this.nickname,
    this.realname,
    this.lang,
    this.avatar,
    this.gender,
    this.birth,
    this.address,
    this.country,
    this.province,
    this.city,
    this.county,
    this.postcode,
    this.qq,
    this.wechat,
    this.alipay,
  });
  MemberUpdateDTO.fromJson(Json json)
    : this(
        nickname: as<String>(json['nickname']),
        realname: as<String>(json['realname']),
        lang: as<String>(json['lang']),
        avatar: as<String>(json['avatar']),
        gender: as<int>(json['gender']),
        birth: as<int>(json['birth']),
        address: as<String>(json['address']),
        country: as<String>(json['country']),
        province: as<String>(json['province']),
        city: as<String>(json['city']),
        county: as<String>(json['county']),
        postcode: as<String>(json['postcode']),
        qq: as<String>(json['qq']),
        wechat: as<String>(json['wechat']),
        alipay: as<String>(json['alipay']),
      );
  static MemberUpdateDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return MemberUpdateDTO.fromJson(json);
  }

  /// 昵称
  final String? nickname;

  /// 真实姓名
  final String? realname;

  /// 默认语言
  final String? lang;

  /// 头像
  final String? avatar;

  /// 性别 1:男 2:女 0:保密
  final int? gender;

  /// 生日 日期的timestamp
  final int? birth;

  /// 地址
  final String? address;

  /// 国
  final String? country;

  /// 省
  final String? province;

  /// 市
  final String? city;

  /// 镇
  final String? county;

  /// 邮编
  final String? postcode;

  /// QQ
  final String? qq;

  /// Wechat
  final String? wechat;

  /// Alipay
  final String? alipay;

  @override
  MemberUpdateDTO clone({
    Optional<String>? nickname,
    Optional<String>? realname,
    Optional<String>? lang,
    Optional<String>? avatar,
    Optional<int>? gender,
    Optional<int>? birth,
    Optional<String>? address,
    Optional<String>? country,
    Optional<String>? province,
    Optional<String>? city,
    Optional<String>? county,
    Optional<String>? postcode,
    Optional<String>? qq,
    Optional<String>? wechat,
    Optional<String>? alipay,
  }) => MemberUpdateDTO(
    nickname: nickname.absent(this.nickname),
    realname: realname.absent(this.realname),
    lang: lang.absent(this.lang),
    avatar: avatar.absent(this.avatar),
    gender: gender.absent(this.gender),
    birth: birth.absent(this.birth),
    address: address.absent(this.address),
    country: country.absent(this.country),
    province: province.absent(this.province),
    city: city.absent(this.city),
    county: county.absent(this.county),
    postcode: postcode.absent(this.postcode),
    qq: qq.absent(this.qq),
    wechat: wechat.absent(this.wechat),
    alipay: alipay.absent(this.alipay),
  );

  @override
  Json toJson() => {
    'nickname': nickname,
    'realname': realname,
    'lang': lang,
    'avatar': avatar,
    'gender': gender,
    'birth': birth,
    'address': address,
    'country': country,
    'province': province,
    'city': city,
    'county': county,
    'postcode': postcode,
    'qq': qq,
    'wechat': wechat,
    'alipay': alipay,
  };
}

class MemberDTO implements Base {
  MemberDTO({
    this.id,
    this.username,
    this.nickname,
    this.realname,
    this.level,
    this.lang,
    this.mobile,
    this.mobileBind,
    this.email,
    this.emailBind,
    this.avatar,
    this.gender,
    this.birth,
    this.address,
    this.province,
    this.city,
    this.county,
    this.postcode,
    this.qq,
    this.wechat,
    this.alipay,
    this.createTime,
    this.updateTime,
    this.loginIp,
    this.loginTime,
    this.status,
    this.type,
    this.credit,
    this.money,
    this.reward,
    this.frozeMoney,
    this.frozeCredit,
    this.frozeReward,
    this.totalCashin,
    this.totalRecharge,
    this.totalConsume,
    this.refererMember,
    this.isAgent,
    this.agentcode,
  });
  MemberDTO.fromJson(Json json)
    : this(
        id: as<int>(json['id']),
        username: as<String>(json['username']),
        nickname: as<String>(json['nickname']),
        realname: as<String>(json['realname']),
        level: MemberLevelDTO.tryFromJson(as<Json>(json['level'])),
        lang: as<String>(json['lang']),
        mobile: as<String>(json['mobile']),
        mobileBind: as<bool>(json['mobileBind']),
        email: as<String>(json['email']),
        emailBind: as<bool>(json['emailBind']),
        avatar: as<String>(json['avatar']),
        gender: as<int>(json['gender']),
        birth: as<int>(json['birth']),
        address: as<String>(json['address']),
        province: as<String>(json['province']),
        city: as<String>(json['city']),
        county: as<String>(json['county']),
        postcode: as<String>(json['postcode']),
        qq: as<String>(json['qq']),
        wechat: as<String>(json['wechat']),
        alipay: as<String>(json['alipay']),
        createTime: as<int>(json['createTime']),
        updateTime: as<int>(json['updateTime']),
        loginIp: as<String>(json['loginIp']),
        loginTime: as<int>(json['loginTime']),
        status: as<int>(json['status']),
        type: as<int>(json['type']),
        credit: as<int>(json['credit']),
        money: as<int>(json['money']),
        reward: as<int>(json['reward']),
        frozeMoney: as<int>(json['frozeMoney']),
        frozeCredit: as<int>(json['frozeCredit']),
        frozeReward: as<int>(json['frozeReward']),
        totalCashin: as<int>(json['totalCashin']),
        totalRecharge: as<int>(json['totalRecharge']),
        totalConsume: as<int>(json['totalConsume']),
        refererMember: MemberDTO.tryFromJson(as<Json>(json['refererMember'])),
        isAgent: as<int>(json['isAgent']),
        agentcode: as<String>(json['agentcode']),
      );
  static MemberDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return MemberDTO.fromJson(json);
  }

  /// 会员ID
  final int? id;

  /// 用户名
  final String? username;

  /// 昵称
  final String? nickname;

  /// 真实姓名
  final String? realname;
  final MemberLevelDTO? level;

  /// 默认语言
  final String? lang;

  /// 手机号码
  final String? mobile;

  /// 手机是否绑定,绑定才可以登录
  final bool? mobileBind;

  /// 登录邮箱
  final String? email;

  /// 邮箱是否绑定,绑定才可以登录
  final bool? emailBind;

  /// 头像
  final String? avatar;

  /// 性别 1:男 2:女 0:保密
  final int? gender;

  /// 生日 日期的timestamp
  final int? birth;

  /// 地址
  final String? address;

  /// 省
  final String? province;

  /// 市
  final String? city;

  /// 镇
  final String? county;

  /// 邮编
  final String? postcode;

  /// QQ
  final String? qq;

  /// Wechat
  final String? wechat;

  /// Alipay
  final String? alipay;

  /// 创建时间
  final int? createTime;

  /// 更新时间
  final int? updateTime;

  /// 上次登录IP
  final String? loginIp;

  /// 上次登录时间
  final int? loginTime;

  /// 会员状态 1: 正常
  final int? status;

  /// 会员类型 1: 普通
  final int? type;

  /// 会员积分
  final int? credit;

  /// 会员余额,单位：分
  final int? money;

  /// 会员奖金,单位：分
  final int? reward;

  /// 冻结余额,单位：分
  final int? frozeMoney;

  /// 冻结积分
  final int? frozeCredit;

  /// 冻结奖金,单位：分
  final int? frozeReward;
  final int? totalCashin;
  final int? totalRecharge;
  final int? totalConsume;
  final MemberDTO? refererMember;
  final int? isAgent;

  /// 分享码
  final String? agentcode;

  @override
  MemberDTO clone({
    Optional<int>? id,
    Optional<String>? username,
    Optional<String>? nickname,
    Optional<String>? realname,
    Optional<MemberLevelDTO>? level,
    Optional<String>? lang,
    Optional<String>? mobile,
    Optional<bool>? mobileBind,
    Optional<String>? email,
    Optional<bool>? emailBind,
    Optional<String>? avatar,
    Optional<int>? gender,
    Optional<int>? birth,
    Optional<String>? address,
    Optional<String>? province,
    Optional<String>? city,
    Optional<String>? county,
    Optional<String>? postcode,
    Optional<String>? qq,
    Optional<String>? wechat,
    Optional<String>? alipay,
    Optional<int>? createTime,
    Optional<int>? updateTime,
    Optional<String>? loginIp,
    Optional<int>? loginTime,
    Optional<int>? status,
    Optional<int>? type,
    Optional<int>? credit,
    Optional<int>? money,
    Optional<int>? reward,
    Optional<int>? frozeMoney,
    Optional<int>? frozeCredit,
    Optional<int>? frozeReward,
    Optional<int>? totalCashin,
    Optional<int>? totalRecharge,
    Optional<int>? totalConsume,
    Optional<MemberDTO>? refererMember,
    Optional<int>? isAgent,
    Optional<String>? agentcode,
  }) => MemberDTO(
    id: id.absent(this.id),
    username: username.absent(this.username),
    nickname: nickname.absent(this.nickname),
    realname: realname.absent(this.realname),
    level: level.absent(this.level),
    lang: lang.absent(this.lang),
    mobile: mobile.absent(this.mobile),
    mobileBind: mobileBind.absent(this.mobileBind),
    email: email.absent(this.email),
    emailBind: emailBind.absent(this.emailBind),
    avatar: avatar.absent(this.avatar),
    gender: gender.absent(this.gender),
    birth: birth.absent(this.birth),
    address: address.absent(this.address),
    province: province.absent(this.province),
    city: city.absent(this.city),
    county: county.absent(this.county),
    postcode: postcode.absent(this.postcode),
    qq: qq.absent(this.qq),
    wechat: wechat.absent(this.wechat),
    alipay: alipay.absent(this.alipay),
    createTime: createTime.absent(this.createTime),
    updateTime: updateTime.absent(this.updateTime),
    loginIp: loginIp.absent(this.loginIp),
    loginTime: loginTime.absent(this.loginTime),
    status: status.absent(this.status),
    type: type.absent(this.type),
    credit: credit.absent(this.credit),
    money: money.absent(this.money),
    reward: reward.absent(this.reward),
    frozeMoney: frozeMoney.absent(this.frozeMoney),
    frozeCredit: frozeCredit.absent(this.frozeCredit),
    frozeReward: frozeReward.absent(this.frozeReward),
    totalCashin: totalCashin.absent(this.totalCashin),
    totalRecharge: totalRecharge.absent(this.totalRecharge),
    totalConsume: totalConsume.absent(this.totalConsume),
    refererMember: refererMember.absent(this.refererMember),
    isAgent: isAgent.absent(this.isAgent),
    agentcode: agentcode.absent(this.agentcode),
  );

  @override
  Json toJson() => {
    'id': id,
    'username': username,
    'nickname': nickname,
    'realname': realname,
    'level': level?.toJson(),
    'lang': lang,
    'mobile': mobile,
    'mobileBind': mobileBind,
    'email': email,
    'emailBind': emailBind,
    'avatar': avatar,
    'gender': gender,
    'birth': birth,
    'address': address,
    'province': province,
    'city': city,
    'county': county,
    'postcode': postcode,
    'qq': qq,
    'wechat': wechat,
    'alipay': alipay,
    'createTime': createTime,
    'updateTime': updateTime,
    'loginIp': loginIp,
    'loginTime': loginTime,
    'status': status,
    'type': type,
    'credit': credit,
    'money': money,
    'reward': reward,
    'frozeMoney': frozeMoney,
    'frozeCredit': frozeCredit,
    'frozeReward': frozeReward,
    'totalCashin': totalCashin,
    'totalRecharge': totalRecharge,
    'totalConsume': totalConsume,
    'refererMember': refererMember?.toJson(),
    'isAgent': isAgent,
    'agentcode': agentcode,
  };
}

class MemberLevelDTO implements Base {
  MemberLevelDTO({
    this.levelId,
    this.levelName,
    this.shortName,
    this.style,
    this.isDefault,
    this.upgradeType,
    this.diyPrice,
    this.levelPrice,
    this.discount,
  });
  MemberLevelDTO.fromJson(Json json)
    : this(
        levelId: as<int>(json['levelId']),
        levelName: as<String>(json['levelName']),
        shortName: as<String>(json['shortName']),
        style: as<String>(json['style']),
        isDefault: as<bool>(json['isDefault']),
        upgradeType: as<int>(json['upgradeType']),
        diyPrice: as<int>(json['diyPrice']),
        levelPrice: as<double>(json['levelPrice']),
        discount: as<int>(json['discount']),
      );
  static MemberLevelDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return MemberLevelDTO.fromJson(json);
  }

  /// 等级ID
  final int? levelId;

  /// 等级名称
  final String? levelName;

  /// 简称
  final String? shortName;

  /// 样式
  final String? style;

  /// 是否默认会员
  final bool? isDefault;

  /// 升级方式
  final int? upgradeType;

  /// 等级费用
  final int? diyPrice;

  /// 升级费用
  final double? levelPrice;

  /// 会员折扣(百分比)
  final int? discount;

  @override
  MemberLevelDTO clone({
    Optional<int>? levelId,
    Optional<String>? levelName,
    Optional<String>? shortName,
    Optional<String>? style,
    Optional<bool>? isDefault,
    Optional<int>? upgradeType,
    Optional<int>? diyPrice,
    Optional<double>? levelPrice,
    Optional<int>? discount,
  }) => MemberLevelDTO(
    levelId: levelId.absent(this.levelId),
    levelName: levelName.absent(this.levelName),
    shortName: shortName.absent(this.shortName),
    style: style.absent(this.style),
    isDefault: isDefault.absent(this.isDefault),
    upgradeType: upgradeType.absent(this.upgradeType),
    diyPrice: diyPrice.absent(this.diyPrice),
    levelPrice: levelPrice.absent(this.levelPrice),
    discount: discount.absent(this.discount),
  );

  @override
  Json toJson() => {
    'levelId': levelId,
    'levelName': levelName,
    'shortName': shortName,
    'style': style,
    'isDefault': isDefault,
    'upgradeType': upgradeType,
    'diyPrice': diyPrice,
    'levelPrice': levelPrice,
    'discount': discount,
  };
}

class OAuthDTO implements Base {
  OAuthDTO({this.code, this.referer});
  OAuthDTO.fromJson(Json json)
    : this(code: as<String>(json['code']), referer: as<int>(json['referer']));
  static OAuthDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return OAuthDTO.fromJson(json);
  }

  /// 返回代码
  final String? code;

  /// 推荐人ID，仅注册时生效
  final int? referer;

  @override
  OAuthDTO clone({Optional<String>? code, Optional<int>? referer}) => OAuthDTO(
    code: code.absent(this.code),
    referer: referer.absent(this.referer),
  );

  @override
  Json toJson() => {'code': code, 'referer': referer};
}

class TokenDTO implements Base {
  TokenDTO({required this.token, this.refreshToken, this.expireIn = 0});
  TokenDTO.fromJson(Json json)
    : this(
        token: as<String>(json['token'], '')!,
        refreshToken: as<String>(json['refreshToken']),
        expireIn: as<int>(json['expireIn'], 0)!,
      );
  static TokenDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return TokenDTO.fromJson(json);
  }

  /// Token
  final String token;

  /// 刷新token，如为空则不支持刷新
  final String? refreshToken;

  /// 有效期 以秒计
  final int expireIn;

  @override
  TokenDTO clone({
    String? token,
    Optional<String>? refreshToken,
    int? expireIn,
  }) => TokenDTO(
    token: token ?? this.token,
    refreshToken: refreshToken.absent(this.refreshToken),
    expireIn: expireIn ?? this.expireIn,
  );

  @override
  Json toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'expireIn': expireIn,
  };
}

class MemberRegisterDTO implements Base {
  MemberRegisterDTO({
    this.username,
    this.password,
    this.repassword,
    this.verifyCode,
    this.email,
    this.emailCheck,
    this.realname,
    this.countryCode,
    this.mobile,
    this.mobileCheck,
    this.agentCode,
    this.inviteCode,
  });
  MemberRegisterDTO.fromJson(Json json)
    : this(
        username: as<String>(json['username']),
        password: as<String>(json['password']),
        repassword: as<String>(json['repassword']),
        verifyCode: as<String>(json['verifyCode']),
        email: as<String>(json['email']),
        emailCheck: as<String>(json['emailCheck']),
        realname: as<String>(json['realname']),
        countryCode: as<String>(json['countryCode']),
        mobile: as<String>(json['mobile']),
        mobileCheck: as<String>(json['mobileCheck']),
        agentCode: as<String>(json['agentCode']),
        inviteCode: as<String>(json['inviteCode']),
      );
  static MemberRegisterDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return MemberRegisterDTO.fromJson(json);
  }

  /// 登录名
  final String? username;

  /// 密码
  final String? password;

  /// 确认密码
  final String? repassword;

  /// 图形验证码
  final String? verifyCode;

  /// 登录邮箱
  final String? email;

  /// 邮箱验证码
  final String? emailCheck;

  /// 真实姓名
  final String? realname;

  /// 国家代码
  final String? countryCode;

  /// 手机号
  final String? mobile;

  /// 短信验证码
  final String? mobileCheck;

  /// 推荐码,每个推荐人固定
  final String? agentCode;

  /// 邀请码,只可使用一次
  final String? inviteCode;

  @override
  MemberRegisterDTO clone({
    Optional<String>? username,
    Optional<String>? password,
    Optional<String>? repassword,
    Optional<String>? verifyCode,
    Optional<String>? email,
    Optional<String>? emailCheck,
    Optional<String>? realname,
    Optional<String>? countryCode,
    Optional<String>? mobile,
    Optional<String>? mobileCheck,
    Optional<String>? agentCode,
    Optional<String>? inviteCode,
  }) => MemberRegisterDTO(
    username: username.absent(this.username),
    password: password.absent(this.password),
    repassword: repassword.absent(this.repassword),
    verifyCode: verifyCode.absent(this.verifyCode),
    email: email.absent(this.email),
    emailCheck: emailCheck.absent(this.emailCheck),
    realname: realname.absent(this.realname),
    countryCode: countryCode.absent(this.countryCode),
    mobile: mobile.absent(this.mobile),
    mobileCheck: mobileCheck.absent(this.mobileCheck),
    agentCode: agentCode.absent(this.agentCode),
    inviteCode: inviteCode.absent(this.inviteCode),
  );

  @override
  Json toJson() => {
    'username': username,
    'password': password,
    'repassword': repassword,
    'verifyCode': verifyCode,
    'email': email,
    'emailCheck': emailCheck,
    'realname': realname,
    'countryCode': countryCode,
    'mobile': mobile,
    'mobileCheck': mobileCheck,
    'agentCode': agentCode,
    'inviteCode': inviteCode,
  };
}

class MobileDTO implements Base {
  MobileDTO({
    this.mobile,
    this.agentCode,
    this.inviteCode,
    this.autoRegister,
    this.verifyCode,
  });
  MobileDTO.fromJson(Json json)
    : this(
        mobile: as<String>(json['mobile']),
        agentCode: as<String>(json['agentCode']),
        inviteCode: as<String>(json['inviteCode']),
        autoRegister: as<bool>(json['autoRegister']),
        verifyCode: as<String>(json['verifyCode']),
      );
  static MobileDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return MobileDTO.fromJson(json);
  }

  /// 手机号
  final String? mobile;

  /// 推荐人，仅注册用
  final String? agentCode;

  /// 推荐码，仅注册用
  final String? inviteCode;

  /// 自动注册
  final bool? autoRegister;

  /// 验证码
  final String? verifyCode;

  @override
  MobileDTO clone({
    Optional<String>? mobile,
    Optional<String>? agentCode,
    Optional<String>? inviteCode,
    Optional<bool>? autoRegister,
    Optional<String>? verifyCode,
  }) => MobileDTO(
    mobile: mobile.absent(this.mobile),
    agentCode: agentCode.absent(this.agentCode),
    inviteCode: inviteCode.absent(this.inviteCode),
    autoRegister: autoRegister.absent(this.autoRegister),
    verifyCode: verifyCode.absent(this.verifyCode),
  );

  @override
  Json toJson() => {
    'mobile': mobile,
    'agentCode': agentCode,
    'inviteCode': inviteCode,
    'autoRegister': autoRegister,
    'verifyCode': verifyCode,
  };
}

class UserPasswordDTO implements Base {
  UserPasswordDTO({this.username, this.password, this.verifyCode});
  UserPasswordDTO.fromJson(Json json)
    : this(
        username: as<String>(json['username']),
        password: as<String>(json['password']),
        verifyCode: as<String>(json['verifyCode']),
      );
  static UserPasswordDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return UserPasswordDTO.fromJson(json);
  }

  /// 用户名
  final String? username;

  /// 密码
  final String? password;

  /// 验证码
  final String? verifyCode;

  @override
  UserPasswordDTO clone({
    Optional<String>? username,
    Optional<String>? password,
    Optional<String>? verifyCode,
  }) => UserPasswordDTO(
    username: username.absent(this.username),
    password: password.absent(this.password),
    verifyCode: verifyCode.absent(this.verifyCode),
  );

  @override
  Json toJson() => {
    'username': username,
    'password': password,
    'verifyCode': verifyCode,
  };
}

class BoothDTO implements Base {
  BoothDTO({this.title, this.flag, this.type, this.data});
  BoothDTO.fromJson(Json json)
    : this(
        title: as<String>(json['title']),
        flag: as<String>(json['flag']),
        type: as<String>(json['type']),
        data: BoothDataDTO.tryFromJson(as<Json>(json['data'])),
      );
  static BoothDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return BoothDTO.fromJson(json);
  }

  /// 标题
  final String? title;

  /// 标签
  final String? flag;

  /// 类型
  final String? type;
  final BoothDataDTO? data;

  @override
  BoothDTO clone({
    Optional<String>? title,
    Optional<String>? flag,
    Optional<String>? type,
    Optional<BoothDataDTO>? data,
  }) => BoothDTO(
    title: title.absent(this.title),
    flag: flag.absent(this.flag),
    type: type.absent(this.type),
    data: data.absent(this.data),
  );

  @override
  Json toJson() => {
    'title': title,
    'flag': flag,
    'type': type,
    'data': data?.toJson(),
  };
}

class BoothDataDTO implements Base {
  BoothDataDTO({this.type, this.count, this.parentId});
  BoothDataDTO.fromJson(Json json)
    : this(
        type: as<int>(json['type']),
        count: as<int>(json['count']),
        parentId: as<int>(json['parentId']),
      );
  static BoothDataDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return BoothDataDTO.fromJson(json);
  }

  final int? type;
  final int? count;
  final int? parentId;

  @override
  BoothDataDTO clone({
    Optional<int>? type,
    Optional<int>? count,
    Optional<int>? parentId,
  }) => BoothDataDTO(
    type: type.absent(this.type),
    count: count.absent(this.count),
    parentId: parentId.absent(this.parentId),
  );

  @override
  Json toJson() => {'type': type, 'count': count, 'parentId': parentId};
}

class BannerDTO implements Base {
  BannerDTO({
    required this.title,
    this.width,
    this.height,
    this.extSet,
    required this.status,
    required this.banners,
  });
  BannerDTO.fromJson(Json json)
    : this(
        title: as<String>(json['title'], '')!,
        width: as<int>(json['width']),
        height: as<int>(json['height']),
        extSet: as<Json>(json['extSet']),
        status: as<int>(json['status'], 0)!,
        banners:
            as<List>(
              json['banners'],
            )?.map<BannerItemDTO>((e) => BannerItemDTO.fromJson(e)).toList() ??
            [],
      );
  static BannerDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return BannerDTO.fromJson(json);
  }

  /// 标题
  final String title;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 设置
  final Json? extSet;

  /// 状态
  final int status;

  /// Banner图列表
  final List<BannerItemDTO> banners;

  @override
  BannerDTO clone({
    String? title,
    Optional<int>? width,
    Optional<int>? height,
    Optional<Json>? extSet,
    int? status,
    List<BannerItemDTO>? banners,
  }) => BannerDTO(
    title: title ?? this.title,
    width: width.absent(this.width),
    height: height.absent(this.height),
    extSet: extSet.absent(this.extSet),
    status: status ?? this.status,
    banners: banners ?? this.banners,
  );

  @override
  Json toJson() => {
    'title': title,
    'width': width,
    'height': height,
    'extSet': extSet,
    'status': status,
    'banners': banners,
  };
}

class BannerItemDTO implements Base {
  BannerItemDTO({
    required this.title,
    required this.image,
    required this.video,
    this.url,
    this.elements,
    this.extData,
  });
  BannerItemDTO.fromJson(Json json)
    : this(
        title: as<String>(json['title'], '')!,
        image: as<String>(json['image'], '')!,
        video: as<String>(json['video'], '')!,
        url: as<String>(json['url']),
        elements: as<List>(json['elements'])
            ?.map<BannerItemElementModel>(
              (e) => BannerItemElementModel.fromJson(e),
            )
            .toList(),
        extData: as<Json>(json['extData']),
      );
  static BannerItemDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return BannerItemDTO.fromJson(json);
  }

  /// 标题
  final String title;

  /// 图片
  final String image;

  /// 视频
  final String video;

  /// 跳转链接
  final String? url;

  /// 子顶
  final List<BannerItemElementModel>? elements;

  /// 扩展数据
  final Json? extData;

  @override
  BannerItemDTO clone({
    String? title,
    String? image,
    String? video,
    Optional<String>? url,
    Optional<List<BannerItemElementModel>>? elements,
    Optional<Json>? extData,
  }) => BannerItemDTO(
    title: title ?? this.title,
    image: image ?? this.image,
    video: video ?? this.video,
    url: url.absent(this.url),
    elements: elements.absent(this.elements),
    extData: extData.absent(this.extData),
  );

  @override
  Json toJson() => {
    'title': title,
    'image': image,
    'video': video,
    'url': url,
    'elements': elements,
    'extData': extData,
  };
}

class BannerItemElementModel implements Base {
  BannerItemElementModel({
    this.image,
    this.text,
    this.fontSize,
    this.color,
    this.type,
    this.style,
    this.effect,
    this.duration,
    this.delay,
  });
  BannerItemElementModel.fromJson(Json json)
    : this(
        image: as<String>(json['image']),
        text: as<String>(json['text']),
        fontSize: as<String>(json['fontSize']),
        color: as<String>(json['color']),
        type: as<String>(json['type']),
        style: as<String>(json['style']),
        effect: as<String>(json['effect']),
        duration: as<double>(json['duration']),
        delay: as<int>(json['delay']),
      );
  static BannerItemElementModel? tryFromJson(Json? json) {
    if (json == null) return null;
    return BannerItemElementModel.fromJson(json);
  }

  /// 图片
  final String? image;

  /// 文本
  final String? text;

  /// 文本尺寸
  final String? fontSize;

  /// 文本颜色
  final String? color;

  /// 类型 image, text
  final String? type;

  /// 位置及动画样式
  final String? style;

  /// 动画效果
  final String? effect;

  /// 动画时长 s
  final double? duration;

  /// 延迟时间 ms
  final int? delay;

  @override
  BannerItemElementModel clone({
    Optional<String>? image,
    Optional<String>? text,
    Optional<String>? fontSize,
    Optional<String>? color,
    Optional<String>? type,
    Optional<String>? style,
    Optional<String>? effect,
    Optional<double>? duration,
    Optional<int>? delay,
  }) => BannerItemElementModel(
    image: image.absent(this.image),
    text: text.absent(this.text),
    fontSize: fontSize.absent(this.fontSize),
    color: color.absent(this.color),
    type: type.absent(this.type),
    style: style.absent(this.style),
    effect: effect.absent(this.effect),
    duration: duration.absent(this.duration),
    delay: delay.absent(this.delay),
  );

  @override
  Json toJson() => {
    'image': image,
    'text': text,
    'fontSize': fontSize,
    'color': color,
    'type': type,
    'style': style,
    'effect': effect,
    'duration': duration,
    'delay': delay,
  };
}

class CategoryModel implements Base {
  CategoryModel({
    this.id,
    this.pid,
    this.title,
    this.shortTitle,
    this.name,
    this.icon,
    this.image,
    this.sort,
    this.props,
    this.fields,
    this.pagesize,
    this.useTemplate,
    this.templateDir,
    this.channelMode,
    this.status,
    this.isLock,
    this.isComment,
    this.isImages,
    this.isAttachments,
    this.keywords,
    this.description,
  });
  CategoryModel.fromJson(Json json)
    : this(
        id: as<int>(json['id']),
        pid: as<int>(json['pid']),
        title: as<String>(json['title']),
        shortTitle: as<String>(json['shortTitle']),
        name: as<String>(json['name']),
        icon: as<String>(json['icon']),
        image: as<String>(json['image']),
        sort: as<int>(json['sort']),
        props: as<String>(json['props']),
        fields: as<String>(json['fields']),
        pagesize: as<int>(json['pagesize']),
        useTemplate: as<bool>(json['useTemplate']),
        templateDir: as<String>(json['templateDir']),
        channelMode: as<int>(json['channelMode']),
        status: as<int>(json['status']),
        isLock: as<int>(json['isLock']),
        isComment: as<int>(json['isComment']),
        isImages: as<int>(json['isImages']),
        isAttachments: as<int>(json['isAttachments']),
        keywords: as<String>(json['keywords']),
        description: as<String>(json['description']),
      );
  static CategoryModel? tryFromJson(Json? json) {
    if (json == null) return null;
    return CategoryModel.fromJson(json);
  }

  final int? id;
  final int? pid;
  final String? title;
  final String? shortTitle;
  final String? name;
  final String? icon;
  final String? image;
  final int? sort;
  final String? props;
  final String? fields;
  final int? pagesize;
  final bool? useTemplate;
  final String? templateDir;
  final int? channelMode;
  final int? status;
  final int? isLock;
  final int? isComment;
  final int? isImages;
  final int? isAttachments;
  final String? keywords;
  final String? description;

  @override
  CategoryModel clone({
    Optional<int>? id,
    Optional<int>? pid,
    Optional<String>? title,
    Optional<String>? shortTitle,
    Optional<String>? name,
    Optional<String>? icon,
    Optional<String>? image,
    Optional<int>? sort,
    Optional<String>? props,
    Optional<String>? fields,
    Optional<int>? pagesize,
    Optional<bool>? useTemplate,
    Optional<String>? templateDir,
    Optional<int>? channelMode,
    Optional<int>? status,
    Optional<int>? isLock,
    Optional<int>? isComment,
    Optional<int>? isImages,
    Optional<int>? isAttachments,
    Optional<String>? keywords,
    Optional<String>? description,
  }) => CategoryModel(
    id: id.absent(this.id),
    pid: pid.absent(this.pid),
    title: title.absent(this.title),
    shortTitle: shortTitle.absent(this.shortTitle),
    name: name.absent(this.name),
    icon: icon.absent(this.icon),
    image: image.absent(this.image),
    sort: sort.absent(this.sort),
    props: props.absent(this.props),
    fields: fields.absent(this.fields),
    pagesize: pagesize.absent(this.pagesize),
    useTemplate: useTemplate.absent(this.useTemplate),
    templateDir: templateDir.absent(this.templateDir),
    channelMode: channelMode.absent(this.channelMode),
    status: status.absent(this.status),
    isLock: isLock.absent(this.isLock),
    isComment: isComment.absent(this.isComment),
    isImages: isImages.absent(this.isImages),
    isAttachments: isAttachments.absent(this.isAttachments),
    keywords: keywords.absent(this.keywords),
    description: description.absent(this.description),
  );

  @override
  Json toJson() => {
    'id': id,
    'pid': pid,
    'title': title,
    'shortTitle': shortTitle,
    'name': name,
    'icon': icon,
    'image': image,
    'sort': sort,
    'props': props,
    'fields': fields,
    'pagesize': pagesize,
    'useTemplate': useTemplate,
    'templateDir': templateDir,
    'channelMode': channelMode,
    'status': status,
    'isLock': isLock,
    'isComment': isComment,
    'isImages': isImages,
    'isAttachments': isAttachments,
    'keywords': keywords,
    'description': description,
  };
}

class ArticleDTO implements Base {
  ArticleDTO({
    required this.id,
    required this.lang,
    this.mainId = 0,
    this.userId,
    this.copyrightId,
    required this.name,
    required this.title,
    required this.viceTitle,
    required this.cover,
    this.keywords,
    this.description,
    this.source,
    this.propData,
    required this.content,
    required this.createTime,
    required this.updateTime,
    required this.cateId,
    this.category,
    required this.digg,
    required this.closeComment,
    required this.comment,
    required this.views,
    required this.type,
    this.template,
    required this.status,
    this.vdigg,
    this.vviews,
  });
  ArticleDTO.fromJson(Json json)
    : this(
        id: as<int>(json['id'], 0)!,
        lang: as<String>(json['lang'], '')!,
        mainId: as<int>(json['mainId'], 0)!,
        userId: as<int>(json['userId']),
        copyrightId: as<int>(json['copyrightId']),
        name: as<String>(json['name'], '')!,
        title: as<String>(json['title'], '')!,
        viceTitle: as<String>(json['viceTitle'], '')!,
        cover: as<String>(json['cover'], '')!,
        keywords: as<String>(json['keywords']),
        description: as<String>(json['description']),
        source: as<String>(json['source']),
        propData: as<Json>(json['propData']),
        content: as<String>(json['content'], '')!,
        createTime: as<int>(json['createTime'], 0)!,
        updateTime: as<int>(json['updateTime'], 0)!,
        cateId: as<int>(json['cateId'], 0)!,
        category: CategoryDTO.tryFromJson(as<Json>(json['category'])),
        digg: as<int>(json['digg'], 0)!,
        closeComment: as<bool>(json['closeComment'], false)!,
        comment: as<int>(json['comment'], 0)!,
        views: as<int>(json['views'], 0)!,
        type: as<int>(json['type'], 0)!,
        template: as<String>(json['template']),
        status: as<int>(json['status'], 0)!,
        vdigg: as<int>(json['vdigg']),
        vviews: as<int>(json['vviews']),
      );
  static ArticleDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return ArticleDTO.fromJson(json);
  }

  /// 文章ID
  final int id;

  /// 语言
  final String lang;

  /// 主文章ID，用于多语言
  final int mainId;

  /// 用户ID
  final int? userId;

  /// 版权ID
  final int? copyrightId;

  /// URL名
  /// 文章URL名
  final String name;

  /// 标题
  /// 文章标题
  final String title;

  /// 副标题
  final String viceTitle;

  /// 封面图
  final String cover;

  /// 页面关键字
  final String? keywords;

  /// 页面摘要
  final String? description;

  /// 文章来源
  final String? source;

  /// 属性数据
  final Json? propData;

  /// 文章内容
  final String content;

  /// 创建时间
  final int createTime;

  /// 更新时间
  final int updateTime;

  /// 所属分类ID
  final int cateId;
  final CategoryDTO? category;

  /// 点赞数据
  final int digg;

  /// 是否关闭评论
  final bool closeComment;

  /// 评论数
  final int comment;

  /// 浏览数
  final int views;

  /// 类型
  /// 1:普通,2:置顶,4:热门,8:推荐
  final int type;

  /// 模板文件名
  final String? template;

  /// 状态
  /// 1:发布
  final int status;
  final int? vdigg;
  final int? vviews;

  @override
  ArticleDTO clone({
    int? id,
    String? lang,
    int? mainId,
    Optional<int>? userId,
    Optional<int>? copyrightId,
    String? name,
    String? title,
    String? viceTitle,
    String? cover,
    Optional<String>? keywords,
    Optional<String>? description,
    Optional<String>? source,
    Optional<Json>? propData,
    String? content,
    int? createTime,
    int? updateTime,
    int? cateId,
    Optional<CategoryDTO>? category,
    int? digg,
    bool? closeComment,
    int? comment,
    int? views,
    int? type,
    Optional<String>? template,
    int? status,
    Optional<int>? vdigg,
    Optional<int>? vviews,
  }) => ArticleDTO(
    id: id ?? this.id,
    lang: lang ?? this.lang,
    mainId: mainId ?? this.mainId,
    userId: userId.absent(this.userId),
    copyrightId: copyrightId.absent(this.copyrightId),
    name: name ?? this.name,
    title: title ?? this.title,
    viceTitle: viceTitle ?? this.viceTitle,
    cover: cover ?? this.cover,
    keywords: keywords.absent(this.keywords),
    description: description.absent(this.description),
    source: source.absent(this.source),
    propData: propData.absent(this.propData),
    content: content ?? this.content,
    createTime: createTime ?? this.createTime,
    updateTime: updateTime ?? this.updateTime,
    cateId: cateId ?? this.cateId,
    category: category.absent(this.category),
    digg: digg ?? this.digg,
    closeComment: closeComment ?? this.closeComment,
    comment: comment ?? this.comment,
    views: views ?? this.views,
    type: type ?? this.type,
    template: template.absent(this.template),
    status: status ?? this.status,
    vdigg: vdigg.absent(this.vdigg),
    vviews: vviews.absent(this.vviews),
  );

  @override
  Json toJson() => {
    'id': id,
    'lang': lang,
    'mainId': mainId,
    'userId': userId,
    'copyrightId': copyrightId,
    'name': name,
    'title': title,
    'viceTitle': viceTitle,
    'cover': cover,
    'keywords': keywords,
    'description': description,
    'source': source,
    'propData': propData,
    'content': content,
    'createTime': createTime,
    'updateTime': updateTime,
    'cateId': cateId,
    'category': category?.toJson(),
    'digg': digg,
    'closeComment': closeComment,
    'comment': comment,
    'views': views,
    'type': type,
    'template': template,
    'status': status,
    'vdigg': vdigg,
    'vviews': vviews,
  };
}

class CategoryDTO implements Base {
  CategoryDTO({
    required this.id,
    this.pid = 0,
    this.title,
    this.shortTitle,
    this.name,
    this.icon,
    this.image,
    this.sort,
    this.props,
    this.channelMode,
    this.status,
    this.isComment,
    this.isImages,
    this.isAttachments,
    this.keywords,
    this.description,
    this.children,
  });
  CategoryDTO.fromJson(Json json)
    : this(
        id: as<int>(json['id'], 0)!,
        pid: as<int>(json['pid'], 0)!,
        title: as<String>(json['title']),
        shortTitle: as<String>(json['shortTitle']),
        name: as<String>(json['name']),
        icon: as<String>(json['icon']),
        image: as<String>(json['image']),
        sort: as<int>(json['sort']),
        props: as<Json>(json['props']),
        channelMode: as<int>(json['channelMode']),
        status: as<int>(json['status']),
        isComment: as<int>(json['isComment']),
        isImages: as<int>(json['isImages']),
        isAttachments: as<int>(json['isAttachments']),
        keywords: as<String>(json['keywords']),
        description: as<String>(json['description']),
        children: as<List>(
          json['children'],
        )?.map<CategoryDTO>((e) => CategoryDTO.fromJson(e)).toList(),
      );
  static CategoryDTO? tryFromJson(Json? json) {
    if (json == null) return null;
    return CategoryDTO.fromJson(json);
  }

  /// 分类ID
  final int id;

  /// 父分类ID
  final int pid;

  /// 分类名称
  final String? title;

  /// 分类简称
  final String? shortTitle;

  /// 分类别名
  final String? name;

  /// 图标
  final String? icon;

  /// 大图
  final String? image;

  /// 排序
  final int? sort;

  /// 默认属性
  final Json? props;

  /// 频道模式
  final int? channelMode;

  /// 状态 1为正常 0为关闭
  final int? status;

  /// 是否开启评论
  final int? isComment;

  /// 是否有图集
  final int? isImages;

  /// 是否有附件
  final int? isAttachments;

  /// 分类关键词
  final String? keywords;

  /// 分类描述
  final String? description;

  /// 子分类列表
  final List<CategoryDTO>? children;

  @override
  CategoryDTO clone({
    int? id,
    int? pid,
    Optional<String>? title,
    Optional<String>? shortTitle,
    Optional<String>? name,
    Optional<String>? icon,
    Optional<String>? image,
    Optional<int>? sort,
    Optional<Json>? props,
    Optional<int>? channelMode,
    Optional<int>? status,
    Optional<int>? isComment,
    Optional<int>? isImages,
    Optional<int>? isAttachments,
    Optional<String>? keywords,
    Optional<String>? description,
    Optional<List<CategoryDTO>>? children,
  }) => CategoryDTO(
    id: id ?? this.id,
    pid: pid ?? this.pid,
    title: title.absent(this.title),
    shortTitle: shortTitle.absent(this.shortTitle),
    name: name.absent(this.name),
    icon: icon.absent(this.icon),
    image: image.absent(this.image),
    sort: sort.absent(this.sort),
    props: props.absent(this.props),
    channelMode: channelMode.absent(this.channelMode),
    status: status.absent(this.status),
    isComment: isComment.absent(this.isComment),
    isImages: isImages.absent(this.isImages),
    isAttachments: isAttachments.absent(this.isAttachments),
    keywords: keywords.absent(this.keywords),
    description: description.absent(this.description),
    children: children.absent(this.children),
  );

  @override
  Json toJson() => {
    'id': id,
    'pid': pid,
    'title': title,
    'shortTitle': shortTitle,
    'name': name,
    'icon': icon,
    'image': image,
    'sort': sort,
    'props': props,
    'channelMode': channelMode,
    'status': status,
    'isComment': isComment,
    'isImages': isImages,
    'isAttachments': isAttachments,
    'keywords': keywords,
    'description': description,
    'children': children,
  };
}

class OrderItemModel implements Base {
  OrderItemModel({this.column, this.asc});
  OrderItemModel.fromJson(Json json)
    : this(column: as<String>(json['column']), asc: as<bool>(json['asc']));
  static OrderItemModel? tryFromJson(Json? json) {
    if (json == null) return null;
    return OrderItemModel.fromJson(json);
  }

  final String? column;
  final bool? asc;

  @override
  OrderItemModel clone({Optional<String>? column, Optional<bool>? asc}) =>
      OrderItemModel(
        column: column.absent(this.column),
        asc: asc.absent(this.asc),
      );

  @override
  Json toJson() => {'column': column, 'asc': asc};
}

class VerifyImageResp implements Base {
  VerifyImageResp();
  VerifyImageResp.fromJson(Json json) : this();
  static VerifyImageResp? tryFromJson(Json? json) {
    if (json == null) return null;
    return VerifyImageResp.fromJson(json);
  }

  @override
  VerifyImageResp clone() => VerifyImageResp();

  @override
  Json toJson() => {};
}
