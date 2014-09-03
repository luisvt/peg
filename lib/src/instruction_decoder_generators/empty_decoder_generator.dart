part of peg.instruction_decoder_generators;

class EmptyDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _INPUT = MethodParseGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
$_SUCCESS = true;''';

  EmptyDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.EMPTY;

  int get stateCount => 1;

  String get stateSeparator => "###STATE###";

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
