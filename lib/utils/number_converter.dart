const arabic = [
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];

const english = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];
String arabicNumberConverter(String input) {
  final output = StringBuffer();

  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    if (english.contains(char) || char == '.') {
      output.write(char);
      continue;
    }
    final newNumber = arabic.indexOf(char);
    output.write(newNumber.toString());
  }
  return output.toString();
}
