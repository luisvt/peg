part of peg.interpreter_class_generator;

class MethodParseGenerator extends TemplateGenerator {
  static const String NAME = "_parse";

  static const String CONST_EOF = "-1";

  static const String VARIABLE_BP = "bp";

  static const String VARIABLE_CH = "ch";

  static const String VARIABLE_CP = "cp";

  static const String VARIABLE_CODE = "code";

  static const String VARIABLE_CURSOR = "cursor";

  static const String VARIABLE_DATA = "data";

  static const String VARIABLE_INPUT = "input";

  static const String VARIABLE_INPUT_LEN = "inputLen";

  static const String VARIABLE_OP = "op";

  static const String VARIABLE_RESULT = "\$\$";

  static const String VARIABLE_SP = "sp";

  static const String VARIABLE_STACK = "stack";

  static const String VARIABLE_STACK_LIMIT = "stackLimit";

  static const String VARIABLE_STACK_SIZE = "stackSize";

  static const String VARIABLE_SUCCESS = "success";

  static const String VARIABLE_TESTING = "testing";

  static const String _INPUT = InterpreterClassGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = InterpreterClassGenerator.VARIABLE_INPUT_LEN;

  static const String _TEMPLATE = "TEMPLATE";

  static const String _TEMPLATE_CHECK_STACK = "TEMPLATE_CHECK_STACK";

  static final String _template = '''
dynamic $NAME(List<int> $VARIABLE_CODE, List $VARIABLE_DATA, int $VARIABLE_CURSOR) {
  var $VARIABLE_BP = 0;
  var $VARIABLE_CH = $CONST_EOF;
  var $VARIABLE_CP = 0;    
  var $VARIABLE_INPUT = $_INPUT;
  var $VARIABLE_INPUT_LEN = $_INPUT_LEN;
  var $VARIABLE_OP = 0; 
  var $VARIABLE_RESULT = null;
  // TODO: Test stack limit  
  var $VARIABLE_STACK_SIZE = 10000;
  var $VARIABLE_STACK_LIMIT = $VARIABLE_STACK_SIZE - 100;
  var $VARIABLE_STACK = new List($VARIABLE_STACK_SIZE);  
  var $VARIABLE_SP = 0;
  var $VARIABLE_SUCCESS = true;
  var $VARIABLE_TESTING = -1;
  if($VARIABLE_CURSOR < $VARIABLE_INPUT_LEN) {    
    $VARIABLE_CH = $VARIABLE_INPUT.codeUnitAt($VARIABLE_CURSOR);    
  }  
  $VARIABLE_STACK[$VARIABLE_SP++] = 0;
  {{#LOCAL_VARIABLES}}
  while(true) {
    if($VARIABLE_SP == 0) {
      break;
    }
    $VARIABLE_OP = $VARIABLE_STACK[--$VARIABLE_SP];
    if($VARIABLE_OP >= 0) {
      $VARIABLE_CP = $VARIABLE_OP;
      $VARIABLE_OP = $VARIABLE_CODE[$VARIABLE_CP];
    }
    if($VARIABLE_SP >= $VARIABLE_STACK_LIMIT) {
      var list = $VARIABLE_STACK;
      var length = $VARIABLE_STACK_SIZE;
      $VARIABLE_STACK_SIZE *= 2;      
      $VARIABLE_STACK_LIMIT = $VARIABLE_STACK_SIZE - 100;      
      $VARIABLE_STACK = new List<int>($VARIABLE_STACK_SIZE);
      for(var i = 0; i < length; i++) {
        $VARIABLE_STACK[i] = list[i];
      }
    }    
    {{#STATES}}
    // TODO:
    continue;
    {{#ACTION}}
  }
  return $VARIABLE_RESULT;  
}
''';

  final InterpreterClassGenerator interpreterClassGenerator;

  Map<String, String> _localVariables;

  MethodParseGenerator(this.interpreterClassGenerator) {
    if (interpreterClassGenerator == null) {
      throw new ArgumentError("interpreterClassGenerator: $interpreterClassGenerator");
    }

    addTemplate(_TEMPLATE, _template);
    _localVariables = <String, String>{};
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var states = _generateDecoders();
    var stateMachine = new StateMachineGenerator(VARIABLE_OP, states);
    stateMachine.generate();
    block.assign("#STATES", stateMachine.generate());
    block.assign("#LOCAL_VARIABLES", _generateLocalVariables());
    return block.process();
  }

  // TODO: avoid local and global names conficts
  String registerLocalName(String name) {
    // TODO: use better way
    var alias = "loc_$name";
    _localVariables[name] = alias;
    return alias;
  }

  // TODO: Default state with "bad state error"
  Map<int, List<String>> _generateDecoders() {
    var generator = new InstructionDecodersGenerator(this);
    return generator.generate();
  }

  List<String> _generateLocalVariables() {
    var names = <String>[];
    for (var key in _localVariables.keys) {
      names.add(_localVariables[key]);
    }

    var result = "var ${names.join(", ")};";
    return [result];
  }
}
