part of peg.instruction_decoder_generators;

class NotPredicateDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _LOCAL_CH = "ch";

  static const String _LOCAL_POS = "pos";

  static const String _LOCAL_TESTING = "testing";

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
{{CH}} = $_CH;
{{POS}} = $_CURSOR;
{{TESTING}} = $_TESTING;
$_TESTING = $_INPUT_LEN + 1;
{{#INSTRUCTION}}
###STATE###
$_CH = {{CH}};
$_CURSOR = {{POS}}; 
$_TESTING = {{TESTING}};
$_RESULT = null;
$_SUCCESS = !$_SUCCESS;
// TODO: failure
{{#FAILURE}}''';

  NotPredicateDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.NOT_PREDICATE;

  List<String> get localVariables => const <String>[_LOCAL_CH, _LOCAL_POS, _LOCAL_TESTING];

  int get stateCount => 2;

  String get stateSeparator => "###STATE###";

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var stackHelper = new StackHelper(this);
    block.assign("CH", getLocalVariableName(_LOCAL_CH));
    block.assign("POS", getLocalVariableName(_LOCAL_POS));
    block.assign("TESTING", getLocalVariableName(_LOCAL_TESTING));
    block.assign("#INSTRUCTION", stackHelper.switchState(dataFromCode(), getStateId(1)));
    block.assign("#FAILURE", failure());
    return block.process();
  }
}
