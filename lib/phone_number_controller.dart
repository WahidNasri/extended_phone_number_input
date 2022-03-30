import 'dart:io';

import 'package:extended_phone_number_input/models/country.dart';
import 'package:extended_phone_number_input/utils/number_converter.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as parserNumber;

import 'models/countries_list.dart';

class PhoneNumberInputController extends ChangeNotifier {
  final BuildContext _context;

  final String? locale;

  PhoneNumberInputController(
    this._context, {
    this.locale,
  });

  late List<Country> _countries;
  late List<Country> _visibleCountries;
  String? _errorText;
  String? _initialCountryCode;
  String? _initialPhoneNumber;
  List<String>? _includeCountries;
  List<String>? _excludeCountries;
  Function(String)? _onUnsupportedCountrySelected;

  late Country _selectedCountry;
  String _phoneNumber = '';
  String _searchKey = '';
  bool _isValid = false;

  set innerPhoneNumber(String innerPhoneNumber) {
    _phoneNumber = innerPhoneNumber;
    notifyListeners();
  }

  set errorText(String errorText) {
    _errorText = errorText;
  }

  Future init(
      {String? initialCountryCode,
      List<String>? excludeCountries,
      List<String>? includeCountries,
      String? initialPhoneNumber,
      String? errorText}) async {
    _countries = await loadCountries(_context, locale: locale);
    _visibleCountries = _countries;
    _selectedCountry = _countries.first;
    _errorText = errorText;
    _initialCountryCode = initialCountryCode;
    _excludeCountries = excludeCountries;
    _includeCountries = includeCountries;
    _initialPhoneNumber = initialPhoneNumber;
    _selectValues();
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
      if (_onUnsupportedCountrySelected != null) {
        _onUnsupportedCountrySelected!(dialCode);
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
      return _errorText ?? 'الرجاء إدخال رقم الجوال';
    } else {
      try {
        final englishNumber = arabicNumberConverter(phoneNumber);
        final phoneInfo =
            getPhoneNumberInfo('${_selectedCountry.dialCode}$englishNumber');
        final isValid = phoneInfo.validate();
        _isValid = isValid;
        if (!isValid) {
          return _errorText ?? "الرجاء ادخال رقم جوال صحيح";
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

  void _selectValues() {
    try {
      if (_initialCountryCode != null) {
        _selectedCountry = getCountries.firstWhere(
          (country) => country.code == _initialCountryCode?.toUpperCase(),
        );
      } else {
        _selectedCountry = getCountries.first;
      }
      if (_initialPhoneNumber != null && _initialPhoneNumber!.isNotEmpty) {
        phoneNumber = _initialPhoneNumber!;
      }
      if (_excludeCountries != null && _includeCountries != null) {
        assert(false,
            'you can not use include & exclude at the same time.. choose one at most');
      }
      if (_includeCountries != null) {
        _visibleCountries = [
          ..._countries
              .where((country) => _includeCountries!
                  .map((e) => e.toUpperCase())
                  .contains(country.code))
              .toList()
        ];
      } else if (_excludeCountries != null) {
        _visibleCountries = [
          ..._countries
              .where((country) => !_excludeCountries!
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
