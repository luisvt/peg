part of string_matching.decoder_generators;

class CharacterDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_character";

  static const String _CH = GlobalNaming.CH;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _DATA = GlobalNaming.DATA;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const int _OFFSET_RUNE = CharacterInstruction.STRUCT_CHARACTER_RUNE;

  static const int _OFFSET_STRING = CharacterInstruction.STRUCT_CHARACTER_STRING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};
  $_RESULT = $_DATA[offset + $_OFFSET_STRING];
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS && $_CH == $_DATA[offset + $_OFFSET_RUNE]) {  
    $_CURSOR++;
    {{#NEXT_CHAR}}
  } else {
    $_SUCCESS = false;
    {{#FAILURE}}
  }
}
''';

  CharacterDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.CHARACTER;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    block.assign("#FAILURE", expectedValue("$_RESULT"));
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
