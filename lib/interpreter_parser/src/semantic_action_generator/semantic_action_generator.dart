part of string_matching.semantic_action_generator;

class SemanticActionGenerator extends UnifyingInstructionVisitor<Instruction> {
  static const String _ACTION = MethodActionGenerator.NAME;

  ParserClassGenerator _parserClassGenerator;

  Map<int, List<String>> _states;

  Set<Instruction> _visited;

  void generate(Map<String, Instruction> entryPoints, ParserClassGenerator parserClassGenerator) {
    if (entryPoints == null) {
      throw new ArgumentError("entryPoints: $entryPoints");
    }

    if (parserClassGenerator == null) {
      throw new ArgumentError("parserClassGenerator: $parserClassGenerator");
    }

    _parserClassGenerator = parserClassGenerator;
    _states = <int, List<String>>{};
    _visited = new Set<Instruction>();
    for (var instruction in entryPoints.values) {
      instruction.accept(this);
    }

    parserClassGenerator.addMethod(new MethodActionGenerator(_states));
  }

  visitOrderedChoice(OrderedChoiceInstruction instruction) {
    if (_visited.contains(instruction)) {
      return instruction;
    }

    _visited.add(instruction);
    instruction.visitChildren(this);
    return instruction;
  }

  visitProductionRule(ProductionRuleInstruction instruction) {
    if (_visited.contains(instruction)) {
      return instruction;
    }

    _visited.add(instruction);
    instruction.instruction.accept(this);
    return instruction;
  }

  Instruction visitSequence(SequenceInstruction instruction) {
    var instructions = instruction.instructions;
    var length = instruction.instructions.length;
    for (var i = 0; i < length; i++) {
      var child = instructions[i];
      child.accept(this);
      _generate(child, i, length);
    }

    return instruction;
  }

  Instruction visitSequenceWithOneElement(SequenceWithOneElementInstruction instruction) {
    var child = instruction.instruction;
    child.accept(this);
    _generate(child, 0, 1);
    return instruction;
  }

  void _generate(Instruction instruction, int position, int count) {
    var action = instruction.action;
    if (action == null) {
      return;
    }

    var address = instruction.address;
    var name = "${_ACTION}${address}";
    var generator = new ActionGenerator(action, position, count);
    _states[address] = generator.generate();
  }
}
