import 'package:flutter/material.dart';

/// Кастомная локализация для TVC (TV Display App).
/// Поддерживает az (дефолт), ru, en.
class TvcLocalization {
  final Locale locale;

  TvcLocalization(this.locale);

  static const Map<String, Map<String, String>> _t = {
    'az': {
      'discounts': 'Endirimlər',
      'prices': 'Qiymətlər',
      'price_per_hour': '1 saat',
      'hour': 'saat',
      'minute': 'dəqiqə',
      'played': 'oynamısız',
      'remaining': 'qalıb',
      'discount_label': 'endirim',
      'time_not_finished': 'vaxt hələ bitməyib',
      'manat': 'manat',
      'qepik': 'qəpik',
      'change_language': 'Dili dəyiş',
      'language': 'Dil',
      'no_sales': 'Bu sessiyada\nalış-veriş yoxdur',
      'total': 'Cəmi',
      'no_discounts': 'Endirim yoxdur',
      'free': 'BOŞ',
      'free_subtitle': 'Oyunu başlatmaq üçün\nadministratora müraciət edin',
    },
    'ru': {
      'discounts': 'Скидки',
      'prices': 'Цены',
      'price_per_hour': '1 час',
      'hour': 'ч',
      'minute': 'мин',
      'played': 'сыграли',
      'remaining': 'осталось',
      'discount_label': 'скидка',
      'time_not_finished': 'время ещё не истекло',
      'manat': 'ман.',
      'qepik': 'коп.',
      'change_language': 'Сменить язык',
      'language': 'Язык',
      'no_sales': 'Нет покупок\nв этом сеансе',
      'total': 'Итого',
      'no_discounts': 'Скидок нет',
      'free': 'СВОБОДНО',
      'free_subtitle': 'Обратитесь к администратору\nдля начала игры',
    },
    'en': {
      'discounts': 'Discounts',
      'prices': 'Prices',
      'price_per_hour': '1 hour',
      'hour': 'h',
      'minute': 'min',
      'played': 'played',
      'remaining': 'remaining',
      'discount_label': 'discount',
      'time_not_finished': 'time not finished yet',
      'manat': 'AZN',
      'qepik': 'qəp.',
      'change_language': 'Change Language',
      'language': 'Language',
      'no_sales': 'No purchases\nin this session',
      'total': 'Total',
      'no_discounts': 'No discounts',
      'free': 'FREE',
      'free_subtitle': 'Contact the administrator\nto start a game',
    },
  };

  String get(String key) {
    return _t[locale.languageCode]?[key] ?? _t['az']![key] ?? key;
  }

  static TvcLocalization of(BuildContext context) {
    return Localizations.of<TvcLocalization>(context, TvcLocalization)!;
  }
}

class TvcLocalizationDelegate extends LocalizationsDelegate<TvcLocalization> {
  const TvcLocalizationDelegate();

  static const List<Locale> supportedLocales = [
    Locale('az'),
    Locale('ru'),
    Locale('en'),
  ];

  @override
  bool isSupported(Locale locale) =>
      ['az', 'ru', 'en'].contains(locale.languageCode);

  @override
  Future<TvcLocalization> load(Locale locale) async =>
      TvcLocalization(locale);

  @override
  bool shouldReload(TvcLocalizationDelegate old) => false;
}
