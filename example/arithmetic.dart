library peg.example.arithmetic;

import "package:parser_error/parser_error.dart";

part "arithmetic_parser.dart";

void main() {
  var result = parse("1 + 2 * (3 + 4) * 5");
  print(result);
}

num parse(String string) {
  var parser = new ArithmeticParser(string);
  var result = parser.parse_Expr();
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
