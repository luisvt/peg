part of string_matching.instructions;

class OrderedChoiceInstruction extends Instruction {
  static const int FLAG_IS_OPTIONAL = 1;

  static const int STRUCT_ORDERED_CHOICE_FLAG = 0;

  static const int STRUCT_ORDERED_CHOICE_INSTRUCTIONS = 1;

  static const int STRUCT_ORDERED_CHOICE_SYMBOLS = 2;

  static const int STRUCT_ORDERED_CHOICE_EMPTY = 3;

  static const int SIZE_OF_STRUCT_ORDERED_CHOICE = 4;

  static const int STRUCT_TRANSITION_START = 0;

  static const int STRUCT_TRANSITION_END = 1;

  static const int STRUCT_TRANSITION_INTSRUCTIONS = 2;

  static const int SIZE_OF_STRUCT_TRANSITION = 3;

  List<Instruction> empty;

  int flag;

  List<Instruction> instructions;

  SparseList<List<Instruction>> symbols;

  OrderedChoiceInstruction(this.instructions, this.symbols, this.empty, this.flag) {
    if (symbols == null) {
      throw new ArgumentError("symbols: $symbols");
    }

    if (empty == null) {
      throw new ArgumentError("empty: $empty");
    }

    if (flag == null) {
      throw new ArgumentError("flag: $flag");
    }
  }

  OrderedChoiceInstruction.parameterized({List<String> action, this.empty, this.flag, this.instructions, this.symbols}) : super.parameterized(action: action);

  int get size => Instruction.MIN_SIZE + 1;

  InstructionTypes get type => InstructionTypes.ORDERED_CHOICE;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitOrderedChoice(this);
  }

  Object visitChildren(InstructionVisitor visitor) {
    var list = <Instruction>[];
    for (var instruction in instructions) {
      list.add(instruction.accept(visitor));
    }

    return list;
  }
}
