part of peg.interpreter_parser.decoder_generators;

class SequenceWithOneElementDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_sequenceElement";

  static const String _ACTION = MethodActionGenerator.NAME;

  static const String _DATA = InterpreterClassGenerator.DATA;

  static const String _DECODE = MethodDecodeGenerator.NAME;

  static const String _RESULT = InterpreterClassGenerator.RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const int _FLAG_HAS_ACTION = SequenceWithOneElementInstruction.FLAG_HAS_ACTION;

  static const int _OFFSET_FLAG = SequenceWithOneElementInstruction.STRUCT_SEQUENCE_ELEMENT_FLAG;

  static const int _OFFSET_INSTRUCTION = SequenceWithOneElementInstruction.STRUCT_SEQUENCE_ELEMENT_INSTRUCTION;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {
  var offset = {{OFFSET}};
  cp = $_DATA[offset + $_OFFSET_INSTRUCTION];    
  $_DECODE(cp);
  if (!$_SUCCESS) {
    return;
  }
  if ($_DATA[offset + $_OFFSET_FLAG] & $_FLAG_HAS_ACTION != 0) {
    $_RESULT = $_ACTION(cp, $_RESULT); 
  }
}
''';

  SequenceWithOneElementDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.SEQUENCE_WITH_ONE_ELEMENT;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    return block.process();
  }
}
