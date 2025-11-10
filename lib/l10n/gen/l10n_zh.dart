// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BlocApp';

  @override
  String get login => '登录';

  @override
  String get loginDialogTitle => '请登录';

  @override
  String get loginDialogContent => '立即登录？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get agree => '同意';

  @override
  String get reject => '拒绝';

  @override
  String get policy => 'policy_zh';

  @override
  String get requestError => '网络错误';

  @override
  String get locationRequestFail => '定位失败';

  @override
  String get tabHome => '首页';

  @override
  String get tabProduct => '产品';

  @override
  String get tabMine => '我的';

  @override
  String get userLogin => '登录';

  @override
  String get labelUsername => '用户名';

  @override
  String get labelPassword => '密码';

  @override
  String get loginButtonText => '登录';

  @override
  String get forgotPassword => '忘记密码';

  @override
  String get createAccount => '注册新用户';

  @override
  String get settings => '系统设置';

  @override
  String get theme => '主题';

  @override
  String get themeDesc => '设置App主题';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '亮色';

  @override
  String get themeDark => '暗色';

  @override
  String date(Object a, Object b) {
    return '$a月$b号';
  }

  @override
  String get languages => '语言';

  @override
  String get languagesDesc => '设置显示语言';

  @override
  String get languagesSystem => '跟随系统';

  @override
  String get systemUIMode => '系统UI模式';

  @override
  String get systemUIModeDesc => '设置系统UI显示模式';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');
}
