import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:farmnets/l10n/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) {
      log("Selected locale doesn't exist");
      return;
    }

    _locale = locale;
    notifyListeners();
  }
}
