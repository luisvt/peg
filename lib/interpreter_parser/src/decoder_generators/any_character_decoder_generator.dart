part of peg.interpreter_parser.decoder_generators;

class AnyCharacterDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_anyCharacter";

  static const String _ASCII = ParserClassGenerator.ASCII;

  static const String _CH = ParserClassGenerator.CH;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _INPUT = ParserClassGenerator.INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  $_SUCCESS = $_CURSOR < $_INPUT_LEN;
  if ($_SUCCESS) {  
    if ($_CH < 128) {
      $_RESULT = $_ASCII[$_CH];
    } else {
      $_RESULT = new String.fromCharCode($_CH);
    }
    $_CURSOR++;
    if ($_CURSOR < $_INPUT_LEN) {
      $_CH = $_INPUT[$_CURSOR];
    } else {
      $_CH = $_EOF;
    }    
  } else {
    $_RESULT = null;    
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
    return block.process();
  }
}
