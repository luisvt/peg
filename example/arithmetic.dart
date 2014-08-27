library peg.example.arithmetic;

import "package:strings/strings.dart";

part "arithmetic_parser.dart";

void main() {
  var result = parse("1 + 2 * (3 + 4) * 5");
  print(result);
}

num parse(String text) {
  var parser = new ArithmeticParser(text);
  var result = parser.parse_Expr();
  if (!parser.success) {
    var column = parser.column;
    var line = parser.line;
    var expected = parser.expected;
    var unexpected = toPrintable(parser.unexpected);
    if (!expected.isEmpty) {
      var str = expected.join('\', \'');
      throw
          'Parser error at ($line, $column): expected \'$str\' but found \'$unexpected\'';
    } else {
      if (!unexpected.isEmpty) {
        throw 'Parser error at ($line, $column): unexpected "$unexpected"';
      } else {
        throw 'Parser error at ($line, $column): unexpected end of file';
      }
    }
  }

  return result;
}
