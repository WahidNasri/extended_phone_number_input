import 'dart:io';

import 'package:extended_phone_number_input/models/country.dart';
import 'package:extended_phone_number_input/utils/number_converter.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as parserNumber;

import 'models/countries_list.dart';

class PhoneNumberInputController extends ChangeNotifier {
  final String? initialCountryCode;
  final String? initialPhoneNumber;
  final List<String>? includeCountries;
  final List<String>? excludeCountries;
  final BuildContext _context;
  final Function(String)? onUnsupportedCountrySelected;
  final String? locale;

  PhoneNumberInputController(this._context,
      {this.initialCountryCode,
      this.includeCountries,
      this.excludeCountries,
      this.initialPhoneNumber,
      this.onUnsupportedCountrySelected,
      this.locale}) {
    _init();
  }

  late List<Country> _countries;
  late List<Country> _visibleCountries;

  late Country _selectedCountry;
  String _phoneNumber = '';
  String _searchKey = '';
  bool _isValid = false;

  set innerPhoneNumber(String innerPhoneNumber) {
    _phoneNumber = innerPhoneNumber;
    notifyListeners();
  }

  Future _init() async {
    _countries = await loadCountries(_context, locale: locale);
    _visibleCountries = _countries;
    _selectedCountry = _countries.first;
    selectValues(
        initialCountryCode: initialCountryCode,
        excludeCountries: excludeCountries,
        includeCountries: includeCountries,
        initialPhoneNumber: initialPhoneNumber);
  }

  set selectedCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  set searchKey(String search) {
    _searchKey = search;
    notifyListeners();
  }

  set phoneNumber(String phone) {
    try {
      final phoneInfo = getPhoneNumberInfo(phone);
      _phoneNumber = phoneInfo.nsn;
      _selectedCountry = getCountryByDialCode(phoneInfo.countryCode);
    } catch (e) {
      _phoneNumber = phone;
    } finally {
      notifyListeners();
    }
  }

  Country get selectedCountry => _selectedCountry;
  String get phoneNumber => _phoneNumber;
  String get searchKey => _searchKey;
  String get fullPhoneNumber => '${_selectedCountry.dialCode}$_phoneNumber';
  bool get isValidNumber => _isValid;

  List<Country> get getCountries {
    if (_searchKey.isEmpty) {
      return _visibleCountries;
    }

    return _visibleCountries
        .where((element) =>
            element.dialCode.contains(_searchKey) ||
            element.code.contains(_searchKey.toUpperCase()) ||
            element.name.contains(_searchKey))
        .toList();
  }

  Country getCountryByDialCode(String dialCode) {
    return getCountries.firstWhere(
        (country) => country.dialCode.replaceFirst('+', '') == dialCode,
        orElse: () {
      if (onUnsupportedCountrySelected != null) {
        onUnsupportedCountrySelected!(dialCode);
      }
      return _selectedCountry;
    });
  }

  Country getCountryByCountryCode(String countryCode) {
    return getCountries.firstWhere((country) => country.code == countryCode,
        orElse: () {
      return _selectedCountry;
    });
  }

  String? validator(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _isValid = false;
      return 'الرجاء إدخال رقم الجوال';
    } else {
      try {
        final englishNumber = arabicNumberConverter(phoneNumber);
        final phoneInfo =
            getPhoneNumberInfo('${_selectedCountry.dialCode}$englishNumber');
        final isValid = phoneInfo.validate();
        _isValid = isValid;
        if (!isValid) {
          return "الرجاء ادخال رقم جوال صحيح";
        }
        return null;
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
    }
  }

  parserNumber.PhoneNumber getPhoneNumberInfo(String phoneNumber) {
    return parserNumber.PhoneNumber.fromRaw(phoneNumber);
  }

  void selectValues(
      {String? initialCountryCode,
      List<String>? excludeCountries,
      List<String>? includeCountries,
      String? initialPhoneNumber}) {
    try {
      if (initialCountryCode != null) {
        _selectedCountry = getCountries.firstWhere(
          (country) => country.code == initialCountryCode.toUpperCase(),
        );
      } else {
        _selectedCountry = getCountries.first;
      }
      if (initialPhoneNumber != null && initialPhoneNumber.isNotEmpty) {
        phoneNumber = initialPhoneNumber;
      }
      if (excludeCountries != null && includeCountries != null) {
        assert(false,
            'you can not use include & exclude at the same time.. choose one at most');
      }
      if (includeCountries != null) {
        _visibleCountries = [
          ..._countries
              .where((country) => includeCountries
                  .map((e) => e.toUpperCase())
                  .contains(country.code))
              .toList()
        ];
      } else if (excludeCountries != null) {
        _visibleCountries = [
          ..._countries
              .where((country) => !excludeCountries
                  .map((e) => e.toUpperCase())
                  .contains(country.code))
              .toList()
        ];
      }

      notifyListeners();
    } catch (e) {
      assert(false, 'initial country not included in countries');
    }
  }

  Future<void> pickFromContacts() async {
    try {
      if (!await FlutterContactPicker.hasPermission() && Platform.isAndroid) {
        await FlutterContactPicker.requestPermission();
      }
      final PhoneContact contact =
          await FlutterContactPicker.pickPhoneContact();
      final String? number = contact.phoneNumber?.number;
      if (number != null) {
        phoneNumber = number.replaceAll(' ', '');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void resetSearch() {
    _searchKey = '';
  }
}
