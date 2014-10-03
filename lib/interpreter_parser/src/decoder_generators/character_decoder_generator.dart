part of peg.interpreter_parser.decoder_generators;

class CharacterDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_character";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _DATA = InterpreterClassGenerator.DATA;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

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
    if ($_CURSOR < $_INPUT_LEN) {
      $_CH = $_INPUT[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }
  } else {
    $_SUCCESS = false; 
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
    return block.process();
  }
}
