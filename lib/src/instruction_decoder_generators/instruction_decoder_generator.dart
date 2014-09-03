part of peg.instruction_decoder_generators;

abstract class InstructionDecoderGenerator extends TemplateGenerator {
  static const String STATE_SEPARATOR = "##STATE##";

  static const String _CH = MethodParseGenerator.VARIABLE_CH;

  static const String _CODE = MethodParseGenerator.VARIABLE_CODE;

  static const String _CP = MethodParseGenerator.VARIABLE_CP;

  static const String _CURSOR = MethodParseGenerator.VARIABLE_CURSOR;

  static const String _EOF = MethodParseGenerator.CONST_EOF;

  static const String _INPUT = MethodParseGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = MethodParseGenerator.VARIABLE_INPUT_LEN;

  static const String _SUCCESS = MethodParseGenerator.VARIABLE_SUCCESS;

  static const String _STACK_SIZE = MethodParseGenerator.VARIABLE_STACK_SIZE;

  static const String _TESTING = MethodParseGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE_FAILURE = "\$\$_TEMPLATE_FAILURE";

  static const String _TEMPLATE_NEXT_CHAR = "\$\$_TEMPLATE_NEXT_CHAR";

  static final String _templateFailure = '''
if (!$_SUCCESS && $_CURSOR > $_TESTING) {
  // TODO: Implement failure
}''';

  static final String _templateNextChar = '''
if ($_CURSOR < $_INPUT_LEN) {
  $_CH = $_INPUT.codeUnitAt($_CURSOR);
} else {
  $_CH = $_EOF;
}''';

  final MethodParseGenerator methodParseGenerator;

  InterpreterClassGenerator _interpreterClassGenerator;

  Map<String, String> _localVariables;

  int _startInterrupt;

  InstructionDecoderGenerator(this.methodParseGenerator) {
    if (methodParseGenerator == null) {
      throw new ArgumentError("methodParseGenerator: $methodParseGenerator");
    }

    addTemplate(_TEMPLATE_FAILURE, _templateFailure);
    addTemplate(_TEMPLATE_NEXT_CHAR, _templateNextChar);
    _interpreterClassGenerator = methodParseGenerator.interpreterClassGenerator;
    if (stateCount > 1) {
      _startInterrupt = _interpreterClassGenerator.registerInterrupts(stateCount - 1);
    }

    _localVariables = <String, String>{};
    for (var name in localVariables) {
      _localVariables[name] = methodParseGenerator.registerLocalName(name);
    }
  }

  InstructionTypes get instructionType;

  List<String> get localVariables => const <String>[];

  int get startInterrupt => _startInterrupt;

  int get stateCount;

  String get stateSeparator;

  bool get withLeave => true;

  int getStateId(int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index > stateCount - 1) {
      throw new RangeError("index: $index");
    }

    if (index == 0) {
      return instructionType.id;
    } else {
      return startInterrupt - index + 1;
    }
  }

  String dataFromCode() {
    return "$_CODE[$_CP + ${Instruction.OFFSET_DATA}]";
  }

  List<String> failure() {
    var block = getTemplateBlock(_TEMPLATE_FAILURE);
    return block.process();
  }

  String getLocalVariableName(String key) {
    var result = _localVariables[key];
    if (result == null) {
      throw new ArgumentError("Local variable '$key' not found.");
    }

    return result;
  }

  List<String> nextChar() {
    var block = getTemplateBlock(_TEMPLATE_NEXT_CHAR);
    return block.process();
  }

  void _errorBadState(int state) {
    throw new StateError("Bad state index: $state");
  }
}
