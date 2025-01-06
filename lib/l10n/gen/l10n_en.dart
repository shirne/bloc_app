import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BlocApp';

  @override
  String get login => 'Login';

  @override
  String get loginDialogTitle => 'Login please';

  @override
  String get loginDialogContent => 'Login now ?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get agree => 'Agree';

  @override
  String get reject => 'Reject';

  @override
  String get policy => 'policy';

  @override
  String get requestError => 'Network Error';

  @override
  String get locationRequestFail => 'Locate Fail';

  @override
  String get tabHome => 'Home';

  @override
  String get tabProduct => 'Products';

  @override
  String get tabMine => 'Mine';

  @override
  String get userLogin => 'Login';

  @override
  String get labelUsername => 'Username';

  @override
  String get labelPassword => 'Password';

  @override
  String get loginButtonText => 'Login';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get createAccount => 'Create an account';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeDesc => 'Set app theme';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String date(Object a, Object b) {
    return '${b}day${a}month';
  }

  @override
  String get languages => 'Language';

  @override
  String get languagesDesc => 'Set languages';

  @override
  String get languagesSystem => 'System';
}
