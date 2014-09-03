part of peg.instructions;

class OrderedChoiceInstruction extends Instruction {
  static const int OFFSET_TRANSITION_COUNT = 0;

  static const int OFFSET_TRANSITIONS = 1;

  static const int STRUCT_INTRUCTION_COUNT = 0;

  static const int STRUCT_INTRUCTION_ELEMENTS = 1;

  static const int STRUCT_TRANSITION_START = 0;

  static const int STRUCT_TRANSITION_END = 1;

  static const int STRUCT_TRANSITION_INTSRUCTIONS = 2;

  static const int SIZE_OF_STRUCT_TRANSITION = 3;

  SparseList<List<Instruction>> transitions;

  OrderedChoiceInstruction(this.transitions) {
    if (transitions == null) {
      throw new ArgumentError("transitions: $transitions");
    }
  }

  InstructionTypes get type => InstructionTypes.ORDERED_CHOICE;
}
