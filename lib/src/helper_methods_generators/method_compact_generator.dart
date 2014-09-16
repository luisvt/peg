part of peg.helper_methods_generators;

class MethodCompactGenerator extends TemplateGenerator {
  static const String NAME = "_compact";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
Iterable $NAME(Iterable iterable) {  
  if (iterable is List) {
    var hasNull = false;
    var length = iterable.length;
    for (var i = 0; i < length; i++) {
      if (iterable[i] == null) {
        hasNull = true;
        break;
      }
    }
    if (!hasNull) {
      return iterable;
    }
    var result = [];
    for (var i = 0; i < length; i++) {
      var element = iterable[i];
      if (element != null) {
        result.add(element);
      }
    }
    return result;
  }   
  var result = [];
  for (var element in iterable) {   
    if (element != null) {
      result.add(element);
    }
  }
  return result;  
}
''';

  MethodCompactGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
