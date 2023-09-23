import 'package:shirne_dialog/shirne_dialog.dart';

import '../../l10n/gen/l10n_zh.dart';
import '../utils/core.dart';
import 'routes.dart';

final globalL10n = navigatorKey.currentContext?.l10n ?? AppLocalizationsZhCn();

class ShirneDialogLocalizationsFr extends ShirneDialogLocalizations {
  @override
  String get buttonCancel => 'Annulation';

  @override
  String get buttonConfirm => 'Déterminer';

  @override
  String get closeSemantics => 'Fermé';
}
