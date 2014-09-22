part of peg.parser_generators.parser_error_class_generator;

class ParserErrorClassGenerator extends ClassGenerator {
  static const String MESSAGE = "message";

  static const String POSITION = "position";

  static const String START = "start";

  static const String TYPE = "type";

  static const String TYPE_EXPECTED = "EXPECTED";

  static const String TYPE_MALFORMED = "MALFORMED";

  static const String TYPE_MISSING = "MISSING";

  static const String TYPE_UNEXPECTED = "UNEXPECTED";

  static const String TYPE_UNTERMINATED = "UNTERMINATED";

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
''';

  static String getName(String name) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    return "${name}Error";
  }

  ParserErrorClassGenerator(String name) : super(name) {
    addConstant(new VariableGenerator(TYPE_EXPECTED, "static const int", value: "1"));
    addConstant(new VariableGenerator(TYPE_MALFORMED, "static const int", value: "2"));
    addConstant(new VariableGenerator(TYPE_MISSING, "static const int", value: "3"));
    addConstant(new VariableGenerator(TYPE_UNEXPECTED, "static const int", value: "4"));
    addConstant(new VariableGenerator(TYPE_UNTERMINATED, "static const int", value: "5"));
    addVariable(new VariableGenerator("hashCode", "final int", value: "0"));
    addVariable(new VariableGenerator(MESSAGE, "final String"));
    addVariable(new VariableGenerator(POSITION, "final int"));
    addVariable(new VariableGenerator(START, "final int"));
    addVariable(new VariableGenerator(TYPE, "final int"));
    addConstructor(new ClassContructorGenerator(name));
    addOperator(new OperatorEqualsGenerator(name));
  }

  List<String> generate() {
    return super.generate();
  }
}
