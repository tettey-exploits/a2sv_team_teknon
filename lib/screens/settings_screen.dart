import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmnets/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool valNotify1 = true;
  bool valNotify2 = false;
  int _langIndex = 0;
  String? currentLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeProvider = Provider.of<LocaleProvider>(context);
    currentLanguage = localeProvider.locale.toString();
    log("Current language: $currentLanguage");
    getCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black12,
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.mode,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          buildModeOption(AppLocalizations.of(context)!.speech, valNotify1, onChangeFunction1),
          const Divider(
            height: 20,
            thickness: 1,
            color: Colors.black12,
          ),
          buildModeOption(AppLocalizations.of(context)!.text, valNotify2, onChangeFunction2),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black12,
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.languages,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              buildLanguageRow(AppLocalizations.of(context)!.english, 1),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black12,
              ),
              buildLanguageRow(AppLocalizations.of(context)!.twi, 2),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black12,
              ),
              buildLanguageRow(AppLocalizations.of(context)!.ewe, 3),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black12,
              ),
              buildLanguageRow(AppLocalizations.of(context)!.yoruba, 4),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black12,
              ),
              /* buildLanguageRow("Ga", 5),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.black12,
              ), */
            ],
          ),
        ],
      ),
    );
  }

  Padding buildModeOption(String title, bool value, Function onChangeMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              activeColor: Theme.of(context).colorScheme.secondary,
              trackColor: Colors.grey,
              value: value,
              onChanged: (bool newValue) {
                onChangeMethod(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  void onChangeFunction1(bool newValue1) {
    setState(() {
      valNotify1 = newValue1;
    });
  }

  void onChangeFunction2(bool newValue2) {
    setState(() {
      valNotify2 = newValue2;
    });
  }

  Widget buildLanguageRow(String language, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Radio(
            value: value,
            groupValue: _langIndex,
            onChanged: (newValue) {
              setState(() {
                _langIndex = newValue as int; // Cast newValue to int
                final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
              localeProvider.setLocale(getLocaleFromValue(value)); // New line
              });
            },
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  void getCurrentLanguage() {
    int currentIndex = 1;

    if (currentLanguage == 'en') {
      currentIndex = 1;
    } else if (currentLanguage == 'tw') {
      currentIndex = 2;
    } else if (currentLanguage == 'ee') {
      currentIndex = 3;
    } else if (currentLanguage == 'yo') {
      currentIndex = 4;
    }

    setState(() {
      _langIndex = currentIndex;
    });
  }

  Locale getLocaleFromValue(int value) {
  switch (value) {
    case 1:
      return const Locale('en');
    case 2:
      return const Locale('tw');
    case 3:
      return const Locale('ee');
    case 4:
      return const Locale('yo'); // Yoruba language code
    default:
      return const Locale('en'); // Default to English
  }
}
}
