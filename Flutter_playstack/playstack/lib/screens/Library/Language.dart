import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/common.dart';

class Language {
  String lang;
  Image flag;

  Language._constructor({this.lang, this.flag});

  static final Language _spanish = Language._constructor(
      lang: languageStrings['spanish'],
      flag: Image.asset('icons/flags/png/es.png', package: 'country_icons'));

  static final Language _english = Language._constructor(
      lang: languageStrings['english'],
      flag: Image.asset('icons/flags/png/gb.png', package: 'country_icons'));

  static final Language _french = Language._constructor(
      lang: languageStrings['french'],
      flag: Image.asset('icons/flags/png/fr.png', package: 'country_icons'));

  static final Language _italian = Language._constructor(
      lang: languageStrings['italian'],
      flag: Image.asset('icons/flags/png/it.png', package: 'country_icons'));

  static final Language _german = Language._constructor(
      lang: languageStrings['german'],
      flag: Image.asset('icons/flags/png/de.png', package: 'country_icons'));

  static final Language _chinese = Language._constructor(
      lang: languageStrings['chinese'],
      flag: Image.asset('icons/flags/png/cn.png', package: 'country_icons'));

  static final Language _japanese = Language._constructor(
      lang: languageStrings['japanese'],
      flag: Image.asset('icons/flags/png/jp.png', package: 'country_icons'));

  factory Language(String lang) {
    Language result;
    switch (lang) {
      case 'Español':
        result = _spanish;
        break;
      case 'English':
        result = _english;
        break;
      case 'de':
        result = _german;
        break;
      case 'fr':
        result = _french;
        break;
      case 'it':
        result = _italian;
        break;
      case 'cn':
        result = _chinese;
        break;
      case 'jp':
        result = _japanese;
        break;
    }
    return result;
  }

  Widget showPodcastLanguage(context) {
    double height = MediaQuery.of(context).size.height / 10;
    return Container(
        height: height * 0.2,
        width: height * 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 1, child: flag),
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(height / 12, 0, 0, 0),
                    child: Text(lang,
                        style: TextStyle(
                            fontSize: height / 6,
                            fontWeight: FontWeight.w500))))
          ],
        ));
  }
}
