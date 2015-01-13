part of peg.interpreter_parser.decoder_generators;

class ProductionRuleDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_productionRule";

  static const String _BEGIN_TOKEN = MethodBeginTokenGenerator.NAME;

  static const String _DATA = InterpreterClassGenerator.DATA;

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _END_TOKEN = MethodEndTokenGenerator.NAME;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const int _OFFSET_ID = ProductionRuleInstruction.STRUCT_PRODUCTION_RULE_ID;

  static const int _OFFSET_INSTRUCTION = ProductionRuleInstruction.STRUCT_PRODUCTION_RULE_INSTRUCTION;

  static const int _OFFSET_TOKEN_ID = ProductionRuleInstruction.STRUCT_PRODUCTION_TOKEN_ID;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  // TODO: Memoization goes here
  // TODO: If memoized expectation errors goes here
  var offset = {{OFFSET}};
  var tokenId = $_DATA[offset + $_OFFSET_TOKEN_ID];
  if (tokenId != -1) {
    $_BEGIN_TOKEN(tokenId);
  }  
  $_DECODE($_DATA[offset + $_OFFSET_INSTRUCTION]);
  if (tokenId != -1) {
    $_END_TOKEN();
  }
  // TODO: Memoization goes here
}
''';

  ProductionRuleDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.PRODUCTION_RULE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    return block.process();
  }
}
