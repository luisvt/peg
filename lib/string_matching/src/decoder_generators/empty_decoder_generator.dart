part of string_matching.decoder_generators;

class EmptyDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_empty";

  static const String _CH = GlobalNaming.CH;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  $_RESULT = "";
  $_SUCCESS = true;
}
''';

  EmptyDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.EMPTY;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
