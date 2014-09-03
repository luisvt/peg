part of peg.instruction_decoder_generators;

class ZeroOrMoreDecoderGenerator extends InstructionDecoderGenerator {
  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _LOCAL_INSTRUCTION = "instruction";

  static const String _LOCAL_REPS = "reps";

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
{{INSTRUCTION}} = {{DATA}};
{{#INSTRUCTION1}}
###STATE###
if (!$_SUCCESS) {
  $_RESULT = [];
  $_SUCCESS = true;
  {{#LEAVE}}
} else {
  {{REPS}} = [$_RESULT];
  {{#INSTRUCTION2}}  
}
###STATE###
if ($_SUCCESS) {
  {{REPS}}.add($_RESULT);
  {{#INSTRUCTION2}}   
} else {
  $_RESULT = {{REPS}};
  $_SUCCESS = true;
  {{#LEAVE}}  
}''';

  ZeroOrMoreDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ZERO_OR_MORE;

  List<String> get localVariables => const <String>[_LOCAL_INSTRUCTION, _LOCAL_REPS];

  int get stateCount => 3;

  String get stateSeparator => "###STATE###";

  bool get withLeave => false;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var stackHelper = new StackHelper(this);
    block.assign("DATA", dataFromCode());
    block.assign("INSTRUCTION", getLocalVariableName(_LOCAL_INSTRUCTION));
    block.assign("REPS", getLocalVariableName(_LOCAL_REPS));
    block.assign("#INSTRUCTION1", stackHelper.switchState(getLocalVariableName(_LOCAL_INSTRUCTION), getStateId(1)));
    block.assign("#INSTRUCTION2", stackHelper.switchState(getLocalVariableName(_LOCAL_INSTRUCTION), getStateId(2)));
    block.assign("#LEAVE", stackHelper.leave());
    return block.process();
  }
}
