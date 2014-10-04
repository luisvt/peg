library peg.example.arithmetic;

import "package:text/text.dart";
part "arithmetic_parser.dart";

void main() {
  var result2 = parse("1 + 2");
  var result = parse("1 + 2 * (3 + 4) * 5");
  print(result);
}

num parse(String string) {
  var parser = new ArithmeticParser(string);
  var result = parser.parse_Expr();
  if (!parser.success) {
    var text = new Text(parser.text);
    for (var error in parser.errors()) {
      var location = text.locationAt(error.position);
      var message = "Parser error at $location. ${error.message}";
      print(message);
    }

    throw new FormatException();
  }

  return result;
}
