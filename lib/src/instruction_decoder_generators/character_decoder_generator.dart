part of peg.instruction_decoder_generators;

class CharacterDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _DATA = MethodParseGenerator.VARIABLE_DATA;

  static const String _INPUT = MethodParseGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
if ($_CURSOR < $_INPUT_LEN) {    
  var c = {{DATA}};
  if (c == $_CH) {
     $_RESULT = c;
     $_CURSOR++;
     {{#NEXT_CHAR}}
     $_SUCCESS = true;
  }  
}
// TODO: failure
{{#FAILURE}}''';

  CharacterDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.CHARACTER;

  int get stateCount => 1;

  String get stateSeparator => "###STATE###";

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("DATA", dataFromCode());
    block.assign("#FAILURE", failure());
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
