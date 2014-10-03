part of peg.interpreter_parser.instructions;

abstract class UnaryInstruction extends Instruction {
  static const int OFFSET_INSTRUCTION = 0;

  Instruction instruction;

  UnaryInstruction(this.instruction) {
    if (instruction == null) {
      throw new ArgumentError("instruction: $instruction");
    }
  }

  UnaryInstruction.parameterized({List<String> action, this.instruction}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  Object visitChildren(InstructionVisitor visitor) {
    return instruction.accept(visitor);
  }
}
