// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("BlocApp"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "createAccount":
            MessageLookupByLibrary.simpleMessage("Create an account"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot password"),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Password"),
        "labelUsername": MessageLookupByLibrary.simpleMessage("Username"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginButtonText": MessageLookupByLibrary.simpleMessage("Login"),
        "loginDialogContent":
            MessageLookupByLibrary.simpleMessage("Login now ?"),
        "loginDialogTitle":
            MessageLookupByLibrary.simpleMessage("Login please"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeDesc": MessageLookupByLibrary.simpleMessage("Set app theme"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
        "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("System"),
        "userLogin": MessageLookupByLibrary.simpleMessage("Login"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
