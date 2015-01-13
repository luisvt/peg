part of peg.interpreter_parser.instructions;

class LiteralInstruction extends Instruction {
  static const int STRUCT_LITERAL_CHARACTERS = 0;

  static const int STRUCT_LITERAL_STRING = 1;

  static const int SIZE_OF_STRUCT_LITERAL = 2;

  String string;

  LiteralInstruction(this.string) {
    if (string == null) {
      throw new ArgumentError("string: $string");
    }
  }

  LiteralInstruction.parameterized({List<String> action, this.string}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.LITERAL;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitLiteral(this);
  }
}
