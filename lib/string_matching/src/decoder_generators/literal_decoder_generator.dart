part of string_matching.decoder_generators;

class LiteralDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_literal";

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _DATA = GlobalNaming.DATA;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const int _OFFSET_RUNES = LiteralInstruction.STRUCT_LITERAL_RUNES;

  static const int _OFFSET_STRING = LiteralInstruction.STRUCT_LITERAL_STRING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};
  List<int> runes = $_DATA[offset + $_OFFSET_RUNES];
  var length = runes.length;
  $_RESULT = $_DATA[offset + $_OFFSET_STRING];
  $_SUCCESS = $_CURSOR + length <= $_INPUT_LEN;
  if ($_SUCCESS) {
    for (var i = 0; i < length; i++) {
      if (runes[i] != $_RUNES[$_CURSOR + i]) {
        $_SUCCESS = false;
        break;
      }
    }
    if ($_SUCCESS) {
      $_CURSOR += length;        
      {{#NEXT_CHAR}}
      return;
    }
  }
  // TODO: failure
  {{#FAILURE}}  
}
''';

  LiteralDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.LITERAL;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    block.assign("#FAILURE", expectedValue("$_RESULT"));
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
