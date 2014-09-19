part of string_matching.decoder_generators;

abstract class DecoderGenerator extends MethodGenerator {
  static const String VARIABLE_CP = "cp";

  static const String VARIABLE_EXPECTED = "expected";

  static const String _ASCII = GlobalNaming.ASCII;

  static const String _CH = GlobalNaming.CH;

  static const String _CODE = GlobalNaming.CODE;

  static const String _CURSOR = GlobalNaming.CURSOR;

  static const String _EOF = GlobalNaming.EOF;

  static const String _EXPECTED = GlobalNaming.EXPECTED;

  static const String _FAILURE_POS = GlobalNaming.FAILURE_POS;

  static const String _INPUT_LEN = GlobalNaming.INPUT_LEN;

  static const String _RESULT = GlobalNaming.RESULT;

  static const String _RUNES = GlobalNaming.RUNES;

  static const String _TESTING = GlobalNaming.TESTING;

  static const String _TEMPLATE_CH_TO_STRING = "\$\$_TEMPLATE_CH_TO_STRING";

  static const String _TEMPLATE_EXPECTED_VALUE = "\$\$_TEMPLATE_EXPECTED_VALUE";

  static const String _TEMPLATE_EXPECTED_VALUES = "\$\$_TEMPLATE_EXPECTED_VALUES";

  static const String _TEMPLATE_NEXT_CHAR = "\$\$_TEMPLATE_NEXT_CHAR";

  static const String _TEMPLATE_UNEXPECTED = "\$\$_TEMPLATE_UNEXPECTED";

  static final String _templateChToString = '''
if ($_CH < 128) {
  $_RESULT = $_ASCII[$_CH];
} else {
  $_RESULT = new String.fromCharCode($_CH);
}''';

  static final String _templateExpectedValue = '''
if ($_CURSOR > $_TESTING && $_CURSOR >= $_FAILURE_POS) {
  if ($_CURSOR > $_FAILURE_POS) {    
    $_EXPECTED = [];
    $_FAILURE_POS = $_CURSOR;
  }
  $_EXPECTED.add({{EXPECTED}});  
}''';

  static final String _templateExpectedValues = '''
if ($_CURSOR > $_TESTING && $_CURSOR >= $_FAILURE_POS) {
  if ($_CURSOR > $_FAILURE_POS) {    
    $_EXPECTED = [];
    $_FAILURE_POS = $_CURSOR;
  }
  $_EXPECTED.addAll({{EXPECTED}});  
}''';

  static final String _templateUnexpected = '''
if ($_CURSOR > $_TESTING && $_CURSOR > $_FAILURE_POS) {    
  $_EXPECTED = [];
  $_FAILURE_POS = $_CURSOR;
}''';

  static final String _templateNextChar = '''
if ($_CURSOR < $_INPUT_LEN) {
  $_CH = $_RUNES[$_CURSOR];
} else {
  $_CH = $_EOF;
}''';

  DecoderGenerator() {
    addTemplate(_TEMPLATE_CH_TO_STRING, _templateChToString);
    addTemplate(_TEMPLATE_EXPECTED_VALUE, _templateExpectedValue);
    addTemplate(_TEMPLATE_EXPECTED_VALUES, _templateExpectedValues);
    addTemplate(_TEMPLATE_NEXT_CHAR, _templateNextChar);
    addTemplate(_TEMPLATE_UNEXPECTED, _templateUnexpected);
  }

  InstructionTypes get instructionType;

  String dataFromCode(String cp) {
    return "$_CODE[$cp + ${Instruction.OFFSET_DATA}]";
  }

  List<String> chToString() {
    var block = getTemplateBlock(_TEMPLATE_CH_TO_STRING);
    return block.process();
  }

  List<String> expectedValue(String expected) {
    var block = getTemplateBlock(_TEMPLATE_EXPECTED_VALUE);
    block.assign("EXPECTED", expected);
    return block.process();
  }

  List<String> expectedValues(String expected) {
    var block = getTemplateBlock(_TEMPLATE_EXPECTED_VALUES);
    block.assign("EXPECTED", expected);
    return block.process();
  }

  List<String> nextChar() {
    var block = getTemplateBlock(_TEMPLATE_NEXT_CHAR);
    return block.process();
  }

  List<String> unexpected() {
    var block = getTemplateBlock(_TEMPLATE_UNEXPECTED);
    return block.process();
  }
}
