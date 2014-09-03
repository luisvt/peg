part of peg.instructions;

class CharacterClassInstruction extends Instruction {
  static const int OFFSET_RANGE_COUNT = 0;

  static const int OFFSET_RANGES = 1;

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

  InstructionTypes get type => InstructionTypes.CHARACTER_CLASS;
}
