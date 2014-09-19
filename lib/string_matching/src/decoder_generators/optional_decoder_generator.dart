part of string_matching.decoder_generators;

class OptionalDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_optional";

  static const String _DECODE = GlobalNaming.DECODE;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  $_DECODE({{DATA}});
  $_SUCCESS = true;
}
''';

  OptionalDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.OPTIONAL;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode("cp"));
    return block.process();
  }
}
