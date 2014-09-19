part of string_matching.decoder_generators;

class RuleDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_rule";

  static const String _DECODE = GlobalNaming.DECODE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  $_DECODE({{DATA}});  
}
''';

  RuleDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.RULE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode("cp"));
    return block.process();
  }
}
