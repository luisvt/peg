part of peg.instruction_decoder_generators;

class OrderedChoiceDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CODE = MethodParseGenerator.VARIABLE_CODE;

  static const String _DATA = MethodParseGenerator.VARIABLE_DATA;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _LOCAL_COUNT = "count";

  static const String _LOCAL_INTRUCTIONS = "instructions";

  static const int _OFFSET_TRANSITION_COUNT = OrderedChoiceInstruction.OFFSET_TRANSITION_COUNT;

  static const int _OFFSET_TRANSITIONS = OrderedChoiceInstruction.OFFSET_TRANSITIONS;

  static const int _STRUCT_INTRUCTION_COUNT = OrderedChoiceInstruction.STRUCT_INTRUCTION_COUNT;

  static const int _STRUCT_INTRUCTION_ELEMENTS = OrderedChoiceInstruction.STRUCT_INTRUCTION_ELEMENTS;

  static const int _STRUCT_TRANSITION_START = OrderedChoiceInstruction.STRUCT_TRANSITION_START;

  static const int _STRUCT_TRANSITION_END = OrderedChoiceInstruction.STRUCT_TRANSITION_END;

  static const int _STRUCT_TRANSITION_INTSRUCTIONS = OrderedChoiceInstruction.STRUCT_TRANSITION_INTSRUCTIONS;

  static const int _SIZE_OF_STRUCT_TRANSITION = OrderedChoiceInstruction.SIZE_OF_STRUCT_TRANSITION;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
var offset = {{OFFSET}};
var count = $_DATA[offset + $_OFFSET_TRANSITION_COUNT]; 
var transitions = offset + $_OFFSET_TRANSITIONS;
$_SUCCESS = false;
for (var i = 0; i < count; i++, transitions += $_SIZE_OF_STRUCT_TRANSITION) {
  if ($_CH <= $_DATA[transitions + $_STRUCT_TRANSITION_END]) {
    if ($_CH >= $_DATA[transitions + $_STRUCT_TRANSITION_START]) {
      $_SUCCESS = true;
      break;
    }
  } else {
    break;
  }
}
if ($_SUCCESS) {
  var instructions = $_DATA[transitions + $_STRUCT_TRANSITION_INTSRUCTIONS];
  {{COUNT}} = $_DATA[instructions + $_STRUCT_INTRUCTION_COUNT] - 1;
  {{INSTRUCTIONS}} = instructions + $_STRUCT_INTRUCTION_ELEMENTS;  
  {{#INSTRUCTION}}
} else {
  {{#LEAVE}}
}
###STATE###
if ($_SUCCESS) {   
  {{#LEAVE}}
} else {  
  if ({{COUNT}}-- > 0) {
    {{#INSTRUCTION}}
  } else {
    {{#LEAVE}}
  }    
}''';

  OrderedChoiceDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ORDERED_CHOICE;

  List<String> get localVariables => const <String>[_LOCAL_COUNT, _LOCAL_INTRUCTIONS];

  int get stateCount => 2;

  String get stateSeparator => "###STATE###";

  bool get withLeave => false;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var stackHelper = new StackHelper(this);
    var instructions = getLocalVariableName(_LOCAL_INTRUCTIONS);
    block.assign("COUNT", getLocalVariableName(_LOCAL_COUNT));
    block.assign("INSTRUCTIONS", instructions);
    block.assign("OFFSET", dataFromCode());
    block.assign("#INSTRUCTION", stackHelper.switchState("$_DATA[$instructions++]", getStateId(1)));
    block.assign("#LEAVE", stackHelper.leave());
    return block.process();
  }
}
