part of peg.instructions;

class LiteralInstruction extends Instruction {
  static const int OFFSET_STRING = 0;

  String string;

  LiteralInstruction(this.string) {
    if (string == null) {
      throw new ArgumentError("string: $string");
    }
  }

  InstructionTypes get type => InstructionTypes.LITERAL;
}
