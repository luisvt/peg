part of peg.instruction_decoder_generators;

class CharacterClassDecoderGenerator extends InstructionDecoderGenerator {
  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _DATA = MethodParseGenerator.VARIABLE_DATA;

  static const String _INPUT = MethodParseGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _RESULT = MethodParseGenerator.VARIABLE_RESULT;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const int _OFFSET_RANGE_COUNT = CharacterClassInstruction.OFFSET_RANGE_COUNT;

  static const int _OFFSET_RANGES = CharacterClassInstruction.OFFSET_RANGES;

  static const int _SIZE_OF_STRUCT_RANGE = CharacterClassInstruction.SIZE_OF_STRUCT_RANGE;

  static const String _TEMPLATE = "_TEMPLATE";

  static final String _template = '''
if ($_CURSOR < $_INPUT_LEN) {  
  var c = $_CH;
  var offset = {{OFFSET}};
  var count = $_DATA[offset + $_OFFSET_RANGE_COUNT];
  var ranges = offset + $_OFFSET_RANGES;
  $_SUCCESS = false;
  for(var i = 0; i < count; i++, ranges += $_SIZE_OF_STRUCT_RANGE) {
    if (c >= $_DATA[ranges + 0]) {
      if (c <= $_DATA[ranges + 1]) {
        $_RESULT = $_INPUT[$_CURSOR++];
        {{#NEXT_CHAR}}
        $_SUCCESS = true;
        break;
      }
    } else {      
      break;
    }
  }  
}
// TODO: failure
{{#FAILURE}}''';

  CharacterClassDecoderGenerator(MethodParseGenerator methodParseGenerator) : super(methodParseGenerator) {
    addTemplate(_TEMPLATE, _template);
  }

  InstructionTypes get instructionType => InstructionTypes.CHARACTER_CLASS;

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
