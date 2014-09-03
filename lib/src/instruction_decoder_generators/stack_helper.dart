part of peg.instruction_decoder_generators;

class StackHelper extends TemplateGenerator {
  static const String _BP = MethodParseGenerator.VARIABLE_BP;

  static const String _SP = MethodParseGenerator.VARIABLE_SP;

  static const String _STACK = MethodParseGenerator.VARIABLE_STACK;

  static const String _TEMPLATE_CODE = "\$\$_TEMPLATE_CODE";

  static final String _templateCode = '''
{{#CODE}}''';

  final InstructionDecoderGenerator instructionDecoderGenerator;

  StackHelper(this.instructionDecoderGenerator) {
    if (instructionDecoderGenerator == null) {
      throw new ArgumentError("instruction: $instructionDecoderGenerator");
    }

    addTemplate(_TEMPLATE_CODE, _templateCode);
  }

  List<String> switchState(dynamic address, dynamic returnTo) {
    var block = getTemplateBlock(_TEMPLATE_CODE);
    block.assign("#CODE", push(returnTo));
    block.assign("#CODE", push(address));
    return block.process();
  }

  List<String> generate() {
    return const <String>[];
  }

  List<String> enter() {
    var block = getTemplateBlock(_TEMPLATE_CODE);
    var code = <String>[];
    for (var key in instructionDecoderGenerator.localVariables) {
      var name = instructionDecoderGenerator.getLocalVariableName(key);
      code.add(push(name));
    }

    block.assign("#CODE", code);
    return block.process();
  }

  List<String> leave() {
    var block = getTemplateBlock(_TEMPLATE_CODE);
    var code = <String>[];
    for (var key in instructionDecoderGenerator.localVariables) {
      var name = instructionDecoderGenerator.getLocalVariableName(key);
      code.add(pop(name));
    }

    block.assign("#CODE", code);
    return block.process();
  }

  String pop(dynamic value) {
    return "$value = $_STACK[--$_SP];";
  }

  String push(dynamic value) {
    return "$_STACK[$_SP++] = $value;";
  }
}
