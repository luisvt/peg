part of peg.parser_generators.parser_class_generator;

class MethodToCodePointsGenerator extends DeclarationGenerator {
  static const String NAME = "_toCodePoints";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List<int> $NAME(String string) {
  if (string == null) {
    throw new ArgumentError("string: \$string");
  }

  var length = string.length;
  if (length == 0) {
    return const <int>[];
  }

  var codePoints = <int>[];
  codePoints.length = length;
  var i = 0;
  var pos = 0;
  for ( ; i < length; pos++) {
    var start = string.codeUnitAt(i);
    i++;
    if ((start & 0xFC00) == 0xD800 && i < length) {
      var end = string.codeUnitAt(i);
      if ((end & 0xFC00) == 0xDC00) {
        codePoints[pos] = (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
        i++;
      } else {
        codePoints[pos] = start;
      }
    } else {
      codePoints[pos] = start;
    }
  }

  codePoints.length = pos;
  return codePoints;
}
''';

  MethodToCodePointsGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
