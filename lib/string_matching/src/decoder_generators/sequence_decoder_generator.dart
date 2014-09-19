part of string_matching.decoder_generators;

class SequenceDecoderGenerator extends DecoderGenerator {
  static const String NAME = "_sequence";

  static const String _ACTION = GlobalNaming.ACTION;

  static const String _CH = GlobalNaming.CH;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _DATA = GlobalNaming.DATA;

  static const String _DECODE = GlobalNaming.DECODE;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _SUCCESS = GlobalNaming.SUCCESS;

  static const int _OFFSET_FLAG = SequenceInstruction.STRUCT_SEQUENCE_FLAG;

  static const int _OFFSET_INSTRUCTIONS = SequenceInstruction.STRUCT_SEQUENCE_INSTRUCTIONS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
void $NAME(int cp) {  
  var index = 0;  
  var ch = $_CH; 
  var cursor = $_CURSOR;
  var offset = {{OFFSET}};
  List<int> instructions = $_DATA[offset + $_OFFSET_INSTRUCTIONS];
  var count = instructions.length;
  cp = instructions[index++];    
  $_DECODE(cp);
  if (!$_SUCCESS) {
    return;
  }  
  var result = new List(count--);
  result[0] = $_RESULT;
  var flag = $_DATA[offset + $_OFFSET_FLAG];
  if (flag & 1 != 0) {
    if (count == 0) {
      result = $_ACTION(cp, result);  
    } else {
      result[0] = $_ACTION(cp, result); 
    }    
  }
  flag >>= 1;  
  for ( ; count-- > 0; flag >>= 1, index++) {
    cp = instructions[index];
    $_DECODE(cp);
    if (!$_SUCCESS) {
      $_CH = ch;
      $_CURSOR = cursor;
      return;
    }
    result[index] = $_RESULT;
    if (flag & 1 != 0) {
      if (count == 0) {
        result = $_ACTION(cp, result);
      } else {
        result[index] = $_ACTION(cp, result); 
      }
    }    
  }
  $_RESULT = result;    
}
''';

  SequenceDecoderGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.SEQUENCE;

  String get name => NAME;

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("OFFSET", dataFromCode("cp"));
    return block.process();
  }
}
