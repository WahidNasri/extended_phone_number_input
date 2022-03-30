class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flagPath;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagPath,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
        name: map['name'].toString(),
        code: map['code'].toString(),
        dialCode: map['dial_code'].toString(),
        flagPath:
            'packages/extended_phone_number_input/assets/flags/${map['code']?.toLowerCase()}.png');
  }
}
