part of string_matching.decoder_generators;

class CharacterClassDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_characterClass";

  static const String _CH = GlobalNaming.CH;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _DATA = GlobalNaming.DATA;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const int _OFFSET_COUNT = CharacterClassInstruction.STRUCT_CHARACTER_CLASS_COUNT;

  static const int _OFFSET_RANGES = CharacterClassInstruction.STRUCT_CHARACTER_CLASS_RANGES;

  static const int _OFFSET_START = CharacterClassInstruction.STRUCT_RANGE_START;

  static const int _OFFSET_END = CharacterClassInstruction.STRUCT_RANGE_END;

  static const int _SIZE_OF_STRUCT_RANGE = CharacterClassInstruction.SIZE_OF_STRUCT_RANGE;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS) {    
    int length = $_DATA[offset + $_OFFSET_COUNT]; 
    int ranges = offset + $_OFFSET_RANGES;
    for (var i = 0; i < length; i++, ranges += $_SIZE_OF_STRUCT_RANGE) {
      if ($_CH >= $_DATA[ranges + $_OFFSET_START]) {
        if ($_CH <= $_DATA[ranges + $_OFFSET_END]) {        
          {{#CH_TO_STRING}}
          $_CURSOR++;
          {{#NEXT_CHAR}}
          return;
        }
      } else {    
        break;
      }
    }
    $_SUCCESS = false;
  }
  $_RESULT = null;
  {{#FAILURE}}  
}
''';

  CharacterClassDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.CHARACTER_CLASS;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    block.assign("#CH_TO_STRING", chToString());
    block.assign("#FAILURE", unexpected());
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
