part of peg.interpreter_parser.decoder_generators;

class OrderedChoiceDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_orderedChoice";

  static const String _CH = ParserClassGenerator.CH;

  static const String _DATA = InterpreterClassGenerator.DATA;

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _EOF = ParserClassGenerator.EOF;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const int _FLAG_IS_OPTIONAL = OrderedChoiceInstruction.FLAG_IS_OPTIONAL;

  static const int _OFFSET_EMPTY = OrderedChoiceInstruction.STRUCT_ORDERED_CHOICE_EMPTY;

  static const int _OFFSET_FLAG = OrderedChoiceInstruction.STRUCT_ORDERED_CHOICE_FLAG;

  static const int _OFFSET_INSTRUCTIONS = OrderedChoiceInstruction.STRUCT_ORDERED_CHOICE_INSTRUCTIONS;

  static const int _OFFSET_TRANSITIONS = OrderedChoiceInstruction.STRUCT_ORDERED_CHOICE_SYMBOLS;

  static const int _STRUCT_TRANSITION_START = OrderedChoiceInstruction.STRUCT_TRANSITION_START;

  static const int _STRUCT_TRANSITION_END = OrderedChoiceInstruction.STRUCT_TRANSITION_END;

  static const int _STRUCT_TRANSITION_INSTRUCTIONS = OrderedChoiceInstruction.STRUCT_TRANSITION_INTSRUCTIONS;

  static const int _SIZE_OF_STRUCT_TRANSITION = OrderedChoiceInstruction.SIZE_OF_STRUCT_TRANSITION;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};   
  List transitions = $_DATA[offset + $_OFFSET_TRANSITIONS];  
  List<int> instructions;  
  for (var i = 0; i < transitions.length; i++) {
    List transition = transitions[i];
    if ($_CH >= transition[$_STRUCT_TRANSITION_START]) {
      if ($_CH <= transition[$_STRUCT_TRANSITION_END]) {      
        instructions = transition[$_STRUCT_TRANSITION_INSTRUCTIONS];         
        break;
      }
    } else {
      break;
    }
  }  
  if (instructions == null) {
    if($_CH == $_EOF) {      
      instructions = $_DATA[offset + $_OFFSET_INSTRUCTIONS];
    } else if ($_DATA[offset + $_OFFSET_EMPTY].length != 0) {
      instructions = $_DATA[offset + $_OFFSET_EMPTY];
    } else {      
      $_RESULT = null;
      $_SUCCESS = $_DATA[offset + $_OFFSET_FLAG] & $_FLAG_IS_OPTIONAL != 0;    
      return;
    }
  }
  var index = 0;
  var count = instructions.length - 1;
  while (true) {
    $_DECODE(instructions[index++]);
    if ($_SUCCESS) {
      break;
    } else if (count-- == 0) {
      $_RESULT = null;
      $_SUCCESS = false;   
      break;       
    }  
  }
}
''';

  OrderedChoiceDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.ORDERED_CHOICE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    return block.process();
  }
}
