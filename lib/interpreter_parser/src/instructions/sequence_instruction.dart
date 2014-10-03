part of peg.interpreter_parser.instructions;

class SequenceInstruction extends Instruction {
  static const int STRUCT_SEQUENCE_FLAG = 0;

  static const int STRUCT_SEQUENCE_INSTRUCTIONS = 1;

  static const int SIZE_OF_STRUCT_SEQUENCE = 2;

  List<Instruction> instructions;

  SequenceInstruction(this.instructions) {
    if (instructions == null) {
      throw new ArgumentError("instructions: $instructions");
    }
  }

  SequenceInstruction.parameterized({List<String> action, this.instructions}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.SEQUENCE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitSequence(this);
  }

  Object visitChildren(InstructionVisitor visitor) {
    var list = <Instruction>[];
    for (var instruction in instructions) {
      list.add(instruction.accept(visitor));
    }

    return list;
  }
}
