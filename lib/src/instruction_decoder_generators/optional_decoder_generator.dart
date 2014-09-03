part of peg.instruction_decoder_generators;

class OptionalDecoderGenerator extends InstructionDecoderGenerator {
  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
{{#INSTRUCTION}}
###STATE###
$_SUCCESS = true;''';

  OptionalDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.OPTIONAL;

  int get stateCount => 2;

  String get stateSeparator => "###STATE###";

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var stackHelper = new StackHelper(this);
    block.assign("#INSTRUCTION", stackHelper.switchState(dataFromCode(), getStateId(1)));
    return block.process();
  }
}
