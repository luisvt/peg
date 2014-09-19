part of string_matching.decoder_generators;

class ProductionRuleDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_productionRule";

  static const String _DATA = GlobalNaming.DATA;

  static const String _DECODE = GlobalNaming.DECODE;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const int _OFFSET_ID = ProductionRuleInstruction.STRUCT_PRODUCTION_RULE_ID;

  static const int _OFFSET_INSTRUCTION = ProductionRuleInstruction.STRUCT_PRODUCTION_RULE_INSTRUCTION;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  // TODO: Memoization goes here
  // TODO: If memoized expectation errors goes here
  var offset = {{OFFSET}};  
  $_DECODE($_DATA[offset + $_OFFSET_INSTRUCTION]);  
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
