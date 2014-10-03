part of peg.interpreter_parser.decoder_generators;

class LiteralDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_literal";

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _DATA = InterpreterClassGenerator.DATA;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const int _OFFSET_CHARACTERS = LiteralInstruction.STRUCT_LITERAL_CHARACTERS;

  static const int _OFFSET_STRING = LiteralInstruction.STRUCT_LITERAL_STRING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};
  List<int> characters = $_DATA[offset + $_OFFSET_CHARACTERS];
  var length = characters.length;
  $_RESULT = $_DATA[offset + $_OFFSET_STRING];
  $_SUCCESS = $_CURSOR + length <= $_INPUT_LEN;
  if ($_SUCCESS) {
    for (var i = 0; i < length; i++) {
      if (characters[i] != $_INPUT[$_CURSOR + i]) {
        $_SUCCESS = false;
        break;
      }
    }
    if ($_SUCCESS) {
      $_CURSOR += length;        
      if ($_CURSOR < $_INPUT_LEN) {
        $_CH = $_INPUT[$_CURSOR];
      } else {
        $_CH = $_EOF;
      }
      return;
    }
  }  
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
    return block.process();
  }
}
