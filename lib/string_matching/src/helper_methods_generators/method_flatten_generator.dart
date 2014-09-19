part of string_matching.helper_methods_generators;

class MethodFlattenGenerator extends MethodGenerator {
  static const String NAME = "_flatten";

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List $NAME(dynamic value) {
  if (value is List) {
    var result = [];
    var length = value.length;
    for (var i = 0; i < length; i++) {
      var element = value[i];
      if (element is Iterable) {
        result.addAll(_flatten(element));
      } else {
        result.add(element);
      }
    }
    return result;
  } else if (value is Iterable) {
    var result = [];
    for (var element in value) {
      if (element is! List) {
        result.add(element);
      } else {
        result.addAll(_flatten(element));
      }
    }
  }
  return [value];
}
''';

  MethodFlattenGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
