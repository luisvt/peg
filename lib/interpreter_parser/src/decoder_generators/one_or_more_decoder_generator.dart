part of peg.interpreter_parser.decoder_generators;

class OneOrMoreDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_oneOrMore";

  static const String _CH = ParserClassGenerator.CH;

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _INPUT_LEN = ParserClassGenerator.INPUT_LEN;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TESTING = ParserClassGenerator.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  cp = {{DATA}};    
  $_DECODE(cp);
  if (!$_SUCCESS) {    
    return;  
  }  
  var elements = [$_RESULT];
  var testing = $_TESTING;  
  while(true) {
    $_TESTING = $_INPUT_LEN + 1;
    $_DECODE(cp);
    if (!$_SUCCESS) {
      break;
    }
    elements.add($_RESULT);     
  }
  $_TESTING = testing;
  $_RESULT = elements;
  $_SUCCESS = true;  
}
''';

  OneOrMoreDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ONE_OR_MORE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode("cp"));
    return block.process();
  }
}
