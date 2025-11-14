// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class GlobalMobileVerify {
  static final CN = MobileRegular(86, "中国", r"^(\+?0?86-?)?1[2-9]\d{9}$");
  static final TW = MobileRegular(886, "台湾", r"^(\+?886-?|0)?9\d{8}$");
  static final HK = MobileRegular(852, "香港", r"^(\+?852-?)?[569]\d{3}-?\d{4}$");
  static final MS = MobileRegular(
    60,
    "马来西亚",
    r"^(\+?6?01){1}(([145]{1}(-|\s)?\d{7,8})|([236789]{1}(\s|-)?\d{7}))$",
  );
  static final PH = MobileRegular(63, "菲律宾", r"^(\+?0?63-?)?\d{10}$");
  static final TH = MobileRegular(66, "泰国", r"^(\+?0?66-?)?0\d{9}$");
  static final SG = MobileRegular(65, "新加坡", r"^(\+?0?65-?)?\d{8}$");

  static final DZ = MobileRegular(213, "阿尔及利亚", r"^(\+?213|0)(5|6|7)\d{8}$");
  static final SY = MobileRegular(963, "叙利亚", r"^(!?(\+?963)|0)?9\d{8}$");
  static final SA = MobileRegular(966, "沙特阿拉伯", r"^(!?(\+?966)|0)?5\d{8}$");
  static final US = MobileRegular(
    1,
    "美国",
    r"^(\+?1)?[2-9]\d{2}[2-9](?!11)\d{6}$",
  );
  static final CZ = MobileRegular(
    420,
    "捷克共和国",
    r"^(\+?420)? ?[1-9][0-9]{2} ?[0-9]{3} ?[0-9]{3}$",
  );
  static final DE = MobileRegular(
    49,
    "德国",
    r"^(\+?49[ \.\-])?([\(]{1}[0-9]{1,6}[\)])?([0-9 \.\-\/]{3,20})((x|ext|extension)[ ]?[0-9]{1,4})?$",
  );
  static final DK = MobileRegular(45, "丹麦", r"^(\+?45)?(\d{8})$");
  static final GR = MobileRegular(30, "希腊", r"^(\+?30)?(69\d{8})$");
  static final AU = MobileRegular(61, "澳大利亚", r"^(\+?61|0)4\d{8}$");
  static final GB = MobileRegular(44, "英国", r"^(\+?44|0)7\d{9}$");
  static final CA = MobileRegular(
    1,
    "加拿大",
    r"^(\+?1)?[2-9]\d{2}[2-9](?!11)\d{6}$",
  );
  static final IN = MobileRegular(91, "印度", r"^(\+?91|0)?[789]\d{9}$");
  static final NZ = MobileRegular(64, "新西兰", r"^(\+?64|0)2\d{7,9}$");
  static final ZA = MobileRegular(27, "南非", r"^(\+?27|0)\d{9}$");
  static final ZM = MobileRegular(260, "赞比亚", r"^(\+?26)?09[567]\d{7}$");
  static final ES = MobileRegular(
    34,
    "西班牙",
    r"^(\+?34)?(6\d{1}|7[1234])\d{7}$",
  );
  static final FI = MobileRegular(
    358,
    "芬兰",
    r"^(\+?358|0)\s?(4(0|1|2|4|5)?|50)\s?(\d\s?){4,8}\d$",
  );
  static final FR = MobileRegular(33, "法国", r"^(\+?33|0)[67]\d{8}$");
  static final IL = MobileRegular(
    972,
    "以色列",
    r"^(\+972|0)([23489]|5[0248]|77)[1-9]\d{6}",
  );
  static final HU = MobileRegular(36, "匈牙利", r"^(\+?36)(20|30|70)\d{7}$");
  static final IT = MobileRegular(39, "意大利", r"^(\+?39)?\s?3\d{2} ?\d{6,7}$");
  static final JP = MobileRegular(
    81,
    "日本",
    r"^(\+?81|0)\d{1,4}[ \\-]?\d{1,4}[ \-]?\d{4}$",
  );
  static final NO = MobileRegular(47, "挪威", r"^(\+?47)?[49]\d{7}$");
  static final BE = MobileRegular(32, "比利时", r"^(\+?32|0)4?\d{8}$");
  static final PL = MobileRegular(
    48,
    "波兰",
    r"^(\+?48)? ?[5-8]\d ?\\d{3} ?\d{2} ?\d{2}$",
  );
  static final BR = MobileRegular(
    55,
    "巴西",
    r"^(\+?55|0)-?[1-9]{2}-?[2-9]{1}\d{3,4}\\-?\d{4}$",
  );
  static final PT = MobileRegular(351, "葡萄牙", r"^(\+?351)?9[1236]\d{7}$");
  static final RU = MobileRegular(7, "俄罗斯", r"^(\+?7|8)?9\d{9}$");
  static final RS = MobileRegular(381, "塞尔维亚", r"^(\+3816|06)[- \d]{5,9}$");
  static final R = MobileRegular(90, "土耳其", r"^(\+?90|0)?5\d{9}$");
  static final VN = MobileRegular(
    84,
    "越南",
    r"^(\+?84|0)?((1(2([0-9])|6([2-9])|88|99))|(9((?!5)[0-9])))([0-9]{7})$",
  );

  static final values = [
    CN,
    TW,
    HK,
    MS,
    PH,
    TH,
    SG,
    DZ,
    SY,
    SA,
    US,
    CZ,
    DE,
    DK,
    GR,
    AU,
    GB,
    CA,
    IN,
    NZ,
    ZA,
    ZM,
    ES,
    FI,
    FR,
    IL,
    HU,
    IT,
    JP,
    NO,
    BE,
    PL,
    BR,
    PT,
    RU,
    RS,
    R,
    VN,
  ];

  static bool verify(String mobile, {int? code}) {
    if (code == null) {
      for (MobileRegular item in values) {
        if (item.verify(mobile)) {
          return true;
        }
      }
    } else {
      return byCode(code)?.verify(mobile) ?? false;
    }

    return false;
  }

  static MobileRegular? byCode(int code) {
    for (MobileRegular item in values) {
      if (item.code == code) {
        return item;
      }
    }
    return null;
  }
}

class MobileRegular {
  /// 国际名称
  final String name;

  /// 正则表达式
  final RegExp regular;

  /// 国际代码
  final int code;

  MobileRegular(this.code, this.name, String regular)
    : regular = RegExp(regular);

  bool verify(String mobile) {
    return regular.hasMatch(mobile);
  }
}
