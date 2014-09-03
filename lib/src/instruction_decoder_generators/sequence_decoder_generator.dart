part of peg.instruction_decoder_generators;

class SequenceDecoderGenerator extends InstructionDecoderGenerator {
  static const String _DATA = MethodParseGenerator.VARIABLE_DATA;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _LOCAL_COUNT = "count";

  static const String _LOCAL_INDEX = "index";

  static const String _LOCAL_INSTRUCTIONS = "instructions";

  static const String _LOCAL_SEQ = "seq";

  static const int _OFFSET_COUNT = SequenceInstruction.OFFSET_INSTRUCTION_COUNT;

  static const int _OFFSET_INSTRUCTIONS = SequenceInstruction.OFFSET_INSTRUCTIONS;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
var offset = {{OFFSET}};
{{COUNT}} = $_DATA[offset + $_OFFSET_COUNT];
{{INDEX}} = 0;
{{INSTRUCTIONS}} = offset + $_OFFSET_INSTRUCTIONS;
{{#INSTRUCTION1}}
###STATE###
if (!$_SUCCESS) {
  $_RESULT = null;  
  {{#LEAVE}}
} else {
  {{SEQ}} = [$_RESULT];
  if (++{{INDEX}} < {{COUNT}}) {
    {{#INSTRUCTION2}}
  } else {
    $_RESULT = {{SEQ}};
    {{#LEAVE}}
  }    
}
###STATE###
if (!$_SUCCESS) {
  $_RESULT = null;  
  {{#LEAVE}}
} else {
  {{SEQ}}.add($_RESULT);
  if (++{{INDEX}} < {{COUNT}}) {
    {{#INSTRUCTION2}}
  } else {
    $_RESULT = {{SEQ}};
    {{#LEAVE}}
  }    
}''';

  SequenceDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.SEQUENCE;

  List<String> get localVariables => const <String>[_LOCAL_COUNT, _LOCAL_INDEX, _LOCAL_INSTRUCTIONS, _LOCAL_SEQ];

  int get stateCount => 3;

  String get stateSeparator => "###STATE###";

  bool get withLeave => false;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var stackHelper = new StackHelper(this);
    var index = getLocalVariableName(_LOCAL_INDEX);
    var instructions = getLocalVariableName(_LOCAL_INSTRUCTIONS);
    var instruction = "$_DATA[$instructions + $index]";
    block.assign("COUNT", getLocalVariableName(_LOCAL_COUNT));
    block.assign("INDEX", index);
    block.assign("INSTRUCTIONS", instructions);
    block.assign("OFFSET", dataFromCode());
    block.assign("SEQ", getLocalVariableName(_LOCAL_SEQ));
    block.assign("#INSTRUCTION1", stackHelper.switchState(instruction, getStateId(1)));
    block.assign("#INSTRUCTION2", stackHelper.switchState(instruction, getStateId(2)));
    block.assign("#LEAVE", stackHelper.leave());
    return block.process();
  }
}
