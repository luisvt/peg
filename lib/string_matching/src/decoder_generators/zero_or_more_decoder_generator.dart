part of string_matching.decoder_generators;

class ZeroOrMoreDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_zeroOrMore";

  static const String _DECODE = GlobalNaming.DECODE;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const String _TESTING = GlobalNaming.TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {    
  cp = {{DATA}};
  var testing = $_TESTING;
  $_TESTING = $_INPUT_LEN + 1;
  $_DECODE(cp);
  if (!$_SUCCESS) {
    $_RESULT = const [];
    $_TESTING = testing;
    $_SUCCESS = true;
    return;  
  }
  var elements = [$_RESULT];
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

  ZeroOrMoreDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ZERO_OR_MORE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode("cp"));
    return block.process();
  }
}
