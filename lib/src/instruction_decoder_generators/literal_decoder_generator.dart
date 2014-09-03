part of peg.instruction_decoder_generators;

class LiteralDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _DATA = MethodParseGenerator.VARIABLE_DATA;

  static const String _INPUT = MethodParseGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const int _OFFSET_STRING = LiteralInstruction.OFFSET_STRING;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
var string = $_DATA[{{OFFSET}} + $_OFFSET_STRING];
var length = string.length;
if ($_CURSOR + length < $_INPUT_LEN && $_INPUT.startsWith(string, $_CURSOR)) {
  $_RESULT = string;
  $_SUCCESS = true;
  {{#NEXT_CHAR}}
} else {
  $_SUCCESS = false;
  // TODO: failure
  {{#FAILURE}}
}''';

  LiteralDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.LITERAL;

  int get stateCount => 1;

  String get stateSeparator => "###STATE###";

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode());
    block.assign("#FAILURE", failure());
    block.assign("#NEXT_CHAR", nextChar());
    return block.process();
  }
}
