part of string_matching.instructions;

class CharacterClassInstruction extends Instruction {
  static const int STRUCT_CHARACTER_CLASS_COUNT = 0;

  static const int STRUCT_CHARACTER_CLASS_RANGES = 1;

  static const int SIZE_OF_STRUCT_CHARACTER_CLASS = 1;

  static const int STRUCT_RANGE_START = 0;

  static const int STRUCT_RANGE_END = 1;

  static const int SIZE_OF_STRUCT_RANGE = 2;

  SparseList<bool> ranges;

  CharacterClassInstruction(this.ranges) {
    if (ranges == null) {
      throw new ArgumentError("ranges: $ranges");
    }

    if (ranges.groupCount == 0) {
      throw new ArgumentError("The list of ranges is empty");
    }
  }

  CharacterClassInstruction.parameterized({List<String> action, this.ranges}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.CHARACTER_CLASS;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitCharacterClass(this);
  }
}
