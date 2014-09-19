part of string_matching.helper_methods_generators;

class MethodToRunesGenerator extends MethodGenerator {
  static const String NAME = "_toRunes";

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

  var runes = <int>[];
  runes.length = length;
  var i = 0;
  var pos = 0;
  for ( ; i < length; pos++) {
    var start = string.codeUnitAt(i);
    i++;
    if ((start & 0xFC00) == 0xD800 && i < length) {
      var end = string.codeUnitAt(i);
      if ((end & 0xFC00) == 0xDC00) {
        runes[pos] = (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
        i++;
      } else {
        runes[pos] = start;
      }
    } else {
      runes[pos] = start;
    }
  }

  runes.length = pos;
  return runes;
}
''';

  MethodToRunesGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
