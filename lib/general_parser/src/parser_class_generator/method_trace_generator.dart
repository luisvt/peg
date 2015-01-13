part of peg.general_parser.parser_class_generator;

class MethodTraceGenerator extends DeclarationGenerator {
  static const String NAME = "_trace";

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(String rule, String prefix) {
  var line = 1;
  var column = 1;
  void calculatePos(int pos) {
    if (pos == null || pos < 0 || pos > $_INPUT_LEN) {
      return;
    }
    line = 1;
    column = 1;
    for (var i = 0; i < $_INPUT_LEN && i < pos; i++) {
      var c = $_INPUT[i];
      if (c == 13) {
        line++;
        line = 1;
        if (i + 1 < $_INPUT_LEN && $_INPUT[i + 1] == 10) {
          i++;
        }
      } else if (c == 10) {
        line++;
        column = 1;
      } else {
        column++;
      }
    }
  }
  calculatePos($_CURSOR);
  var message = "\$line, \$column:\$prefix \$rule";
  if (message.length > {{LENGTH}}) {
    message = message.substring(0, {{LENGTH}});
  } else {
    message = message.padRight({{LENGTH}});
  }
  var position = " (\$$_CURSOR)";
  var rest = 80 - position.length + 2 - message.length;
  var source = <String>[];
  for (var i = $_CURSOR; i < $_INPUT_LEN; i++) {    
    var c = $_INPUT[i];
    var s = new String.fromCharCode(c);    
    switch (c) {
      case 9:
        s = "\\\\t";
        break;
      case 10:
        s = "\\\\n";
        break;
      case 13:
        s = "\\\\r";
        break;
    }
    var length = s.length;
    if (rest - length > 0) {
      rest -= length;
      source.add(s);
    } else {
      break;
    }
  }
  message += source.join();
  message.padRight(80 - position.length);
  message += position;
  print(message);    
}
''';

  int _length;

  MethodTraceGenerator(int length) {
    if (length == null || length < 0) {
      throw new ArgumentError("length: $length");
    }

    _length = length;
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var length = _length + 14;
    if (length > 60) {
      length = 60;
    }

    block.assign("LENGTH", length);
    return block.process();
  }
}
