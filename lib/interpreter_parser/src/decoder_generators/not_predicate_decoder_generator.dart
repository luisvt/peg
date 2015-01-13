part of peg.interpreter_parser.decoder_generators;

class NotPredicateDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_notPredicate";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var ch = $_CH;
  var cursor = $_CURSOR;
  var testing = $_TESTING;
  $_TESTING = $_INPUT_LEN + 1;
  $_DECODE({{DATA}});
  $_RESULT = null;
  $_TESTING = testing;
  $_CURSOR = cursor;
  $_CH = ch;
  $_SUCCESS = !$_SUCCESS;   
}
''';

  NotPredicateDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.NOT_PREDICATE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode("cp"));
    return block.process();
  }
}
