part of peg.grammar_generator;

class MethodUnmapGenerator extends TemplateGenerator {
  static const String NAME = "_unmap";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
static List<bool> $NAME(List<int> mapping) {
  var length = mapping.length;
  var result = new List<bool>(length * 31);
  var offset = 0;
  for (var i = 0; i < length; i++) {
    var v = mapping[i];
    for (var j = 0; j < 31; j++) {
      result[offset++] = v & (1 << j) == 0 ? false : true;
    }
  }
  return result;
}
''';

  MethodUnmapGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
