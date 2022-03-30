import 'dart:convert';

import 'package:extended_phone_number_input/models/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Country>> loadCountries(BuildContext context,
    {String? locale}) async {
  final supportedLocales = await _loadSupportedLocales(context);

  final actualLocale =
      locale != null && supportedLocales.contains(locale.toLowerCase())
          ? locale
          : 'en';

  final countries = await _getCountries(actualLocale);
  return countries.map((map) => Country.fromMap(map)).toList();
}

Future<List<Map<String, dynamic>>> _getCountries(String locale) async {
  try {
    final content = await rootBundle.loadString(
        'packages/extended_phone_number_input/assets/countries/countries.json');

    final list = json.decode(content) as List;
    final data = List<Map<String, dynamic>>.from(list);
    final names = await _getCountriesNames(locale);

    for (var c in data) {
      c['name'] = names[c['code']] ?? c['name'] ?? '';
    }
    return data;
  } catch (ex) {
    return List.empty();
  }
}

Future<Map<String, dynamic>> _getCountriesNames(String locale) async {
  final content = await rootBundle.loadString(
      'packages/extended_phone_number_input/assets/names/$locale.json');

  final list = json.decode(content) as Map<String, dynamic>;
  return list;
}

Future<List<String>> _loadSupportedLocales(BuildContext context) async {
  final manifestContent =
      await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final files = manifestMap.keys
      .where((String key) => key.contains('assets/names'))
      .map((file) {
        return file.split("/").last.replaceAll(".json", "");
      })
      .map((e) => e.toLowerCase())
      .toList();

  return files;
}
