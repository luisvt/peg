
abstract class AbstractParser {
  bool success;
  final String text;
  List<AbstractParserError> errors() {
    throw 'you should be using the transformer';
  }
  dynamic parse_Start() {
    throw 'you should be using the transformer';
  }

  AbstractParser(this.text);

}

class AbstractParserError {
  static const int EXPECTED = 1;

  static const int MALFORMED = 2;

  static const int MISSING = 3;

  static const int UNEXPECTED = 4;

  static const int UNTERMINATED = 5;

  final int hashCode = 0;

  final String message;

  final int position;

  final int start;

  final int type;

  AbstractParserError(this.type, this.position, this.start, this.message);

  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is AbstractParserError) {
      return type == other.type && position == other.position &&
      start == other.start && message == other.message;
    }
    return false;
  }

}