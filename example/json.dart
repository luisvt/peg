library peg.example.json;

import "package:text/text.dart";
import "json_parser.dart";

void main() {
  var result = parse('{"');
  print(result);
}

dynamic parse(String string) {
  var parser = new JsonParser(string);
  var result = parser.parse_jsonText();
  if (!parser.success) {
    var text = new Text(string);
    for (var error in parser.errors()) {
      var location = text.locationAt(error.position);
      var message = "Parser error at ${location.line}:${location.column}. ${error.message}";
      print(message);
    }

    throw new FormatException();
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