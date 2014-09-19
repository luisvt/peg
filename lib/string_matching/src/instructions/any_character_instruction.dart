part of string_matching.instructions;

class AnyCharacterInstruction extends Instruction {
  AnyCharacterInstruction();

  AnyCharacterInstruction.parameterized({List<String> action}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE;

  InstructionTypes get type => InstructionTypes.ANY_CHARACTER;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitAnyCharacter(this);
  }
}
