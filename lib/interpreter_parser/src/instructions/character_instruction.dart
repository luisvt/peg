part of peg.interpreter_parser.instructions;

class CharacterInstruction extends Instruction {
  static const int STRUCT_CHARACTER_RUNE = 0;

  static const int STRUCT_CHARACTER_STRING = 1;

  static const int SIZE_OF_STRUCT_CHARACTER = 2;

  String character;

  CharacterInstruction(this.character) {
    if (character == null || character.length != 1) {
      throw new ArgumentError("character: $character");
    }
  }

  CharacterInstruction.parameterized({List<String> action, this.character}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.CHARACTER;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitCharacter(this);
  }
}
