library peg.example.json;

import "json_parser.dart";
import "package:parser_error/parser_error.dart";

void main() {
  var result = parse(json);
  print(result);
}

dynamic parse(String string) {
  var parser = new JsonParser(string);
  var result = parser.parse_jsonText();
  if (!parser.success) {
    var messages = [];
    for (var error in parser.errors()) {
      messages.add(new ParserErrorMessage(error.message, error.start, error.position));
    }

    var strings = ParserErrorFormatter.format(parser.text, messages);
    print(strings.join("\n"));
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