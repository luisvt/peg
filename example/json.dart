library peg.example.json;

import "package:strings/strings.dart";
import "json_parser.dart";

void main() {
  var result = parse(json);
  print(result);
}

dynamic parse(String text) {
  var parser = new JsonParser(text);
  var result = parser.parse_jsonText();
  if (!parser.success) {
    var column = parser.column;
    var line = parser.line;
    var expected = parser.expected;
    var unexpected = parser.unexpected;
    unexpected = unexpected.isEmpty ? "end of file" : "'${toPrintable(unexpected)}'";
    if (!expected.isEmpty) {
      var str = expected.join('\', \'');
      throw 'Parser error at ($line, $column): expected \'$str\' but found $unexpected';
    } else {
      throw 'Parser error at ($line, $column): unexpected $unexpected';
    }
  }

  return result;
}

String json = r'''
{
  "name": "Андрей",
  "list": [11.0, 22, 33],
  "newline" : "\n",
  "hex_0" : "\u0030"}
''';