part of peg.parser_generators.parser_class_generator;

class MethodErrorsGenerator extends DeclarationGenerator {
  static const String NAME = "errors";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _ERRORS = ParserClassGenerator.ERRORS;

  static const String _EXPECTED = ParserClassGenerator.EXPECTED;

  static const String _FAILURE_POS = ParserClassGenerator.FAILURE_POS;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _POSITION = ParserErrorClassGenerator.POSITION;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TYPE_EXPECTED = ParserErrorClassGenerator.TYPE_EXPECTED;

  static const String _TYPE_UNEXPECTED = ParserErrorClassGenerator.TYPE_UNEXPECTED;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
List<{{ERROR_CLASS}}> $NAME() {
  if ($_SUCCESS) {
    return <{{ERROR_CLASS}}>[];
  }

  String escape(int c) {
    switch (c) {
      case 10:
        return r"\\n";
      case 13:
        return r"\\r";
      case 09:
        return r"\\t";
      case -1:
        return "";
    }
    return new String.fromCharCode(c);
  } 
  
  String getc(int position) {  
    if (position < $_INPUT_LEN) {
      return "'\${escape($_INPUT[position])}'";      
    }       
    return "end of file";
  }

  var errors = <{{ERROR_CLASS}}>[];
  if ($_FAILURE_POS >= $_CURSOR) {
    var set = new Set<{{ERROR_CLASS}}>();
    set.addAll($_ERRORS);
    for (var error in set) {
      if (error.$_POSITION >= $_FAILURE_POS) {
        errors.add(error);
      }
    }
    var names = new Set<String>();  
    names.addAll($_EXPECTED);
    if (names.contains(null)) {
      var string = getc($_FAILURE_POS);
      var message = "Unexpected \$string";
      var error = new {{ERROR_CLASS}}({{ERROR_CLASS}}.$_TYPE_UNEXPECTED, $_FAILURE_POS, $_FAILURE_POS, message);
      errors.add(error);
    } else {      
      var found = getc($_FAILURE_POS);      
      var list = names.toList();
      list.sort();
      var message = "Expected \${list.join(", ")} but found \$found";
      var error = new {{ERROR_CLASS}}({{ERROR_CLASS}}.$_TYPE_EXPECTED, $_FAILURE_POS, $_FAILURE_POS, message);
      errors.add(error);
    }        
  }
  errors.sort((a, b) => a.$_POSITION.compareTo(b.$_POSITION));
  return errors;  
}
''';

  final ParserClassGenerator parserClassGenerator;

  MethodErrorsGenerator(this.parserClassGenerator) {
    if (parserClassGenerator == null) {
      throw new ArgumentError("parserClassGenerator: $parserClassGenerator");
    }

    addTemplate(_TEMPLATE, _template);
  }

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var parserName = parserClassGenerator.name;
    var errorClass = ParserErrorClassGenerator.getName(parserName);
    block.assign("ERROR_CLASS", errorClass);
    return block.process();
  }
}
