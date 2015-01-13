import "package:strings/strings.dart";
import "test_parser.dart";

void main() {
  var result = _parse("a-");
  print(result);
}

dynamic _parse(String text) {
  var parser = new TestParser(text);
  var result = parser.parse_a();
  if (!parser.success) {
    var column = parser.column;
    var line = parser.line;
    var expected = parser.expected;
    var unexpected = toPrintable(parser.unexpected);
    if (!expected.isEmpty) {
      var str = expected.join('\', \'');
      print(
          'Parser error at ($line, $column): expected \'$str\' but found \'$unexpected\''
          );
    } else {
      if (!unexpected.isEmpty) {
        print('Parser error at ($line, $column): unexpected "$unexpected"');
      } else {
        print('Parser error at ($line, $column): unexpected end of file');
      }
    }
  }

  return result;
}