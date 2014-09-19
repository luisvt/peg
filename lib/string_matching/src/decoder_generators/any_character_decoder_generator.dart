part of string_matching.decoder_generators;

class AnyCharacterDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_anyCharacter";

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS) {  
    {{#CH_TO_STRING}}
    $_CURSOR++;
    {{#NEXT_CHAR}}    
  } else {
    $_RESULT = null;        
    {{#FAILURE}}
  }
}
''';

  AnyCharacterDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ANY_CHARACTER;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("#CH_TO_STRING", chToString());
    block.assign("#FAILURE", unexpected());
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
