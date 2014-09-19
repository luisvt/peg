part of string_matching.instructions;

class InstructionTypes {
  static const InstructionTypes AND_PREDICATE = const InstructionTypes("AND_PREDICATE", 0);

  static const InstructionTypes ANY_CHARACTER = const InstructionTypes("ANY_CHARACTER", 1);

  static const InstructionTypes CHARACTER = const InstructionTypes("CHARACTER", 2);

  static const InstructionTypes CHARACTER_CLASS = const InstructionTypes("CHARACTER_CLASS", 3);

  static const InstructionTypes EMPTY = const InstructionTypes("EMPTY", 4);

  static const InstructionTypes LITERAL = const InstructionTypes("LITERAL", 5);

  static const InstructionTypes NOT_PREDICATE = const InstructionTypes("NOT_PREDICATE", 6);

  static const InstructionTypes ONE_OR_MORE = const InstructionTypes("ONE_OR_MORE", 7);

  static const InstructionTypes OPTIONAL = const InstructionTypes("OPTIONAL", 8);

  static const InstructionTypes ORDERED_CHOICE = const InstructionTypes("ORDERED_CHOICE", 9);

  static const InstructionTypes ORDERED_CHOICE_WITH_ONE_ELEMENT = const InstructionTypes("ORDERED_CHOICE_WITH_ONE_ELEMENT", 10);

  static const InstructionTypes PRODUCTION_RULE = const InstructionTypes("PRODUCTION_RULE", 11);

  static const InstructionTypes RULE = const InstructionTypes("RULE", 12);

  static const InstructionTypes SEQUENCE = const InstructionTypes("SEQUENCE", 13);

  static const InstructionTypes SEQUENCE_WITH_ONE_ELEMENT = const InstructionTypes("SEQUENCE_WITH_ONE_ELEMENT", 14);

  static const InstructionTypes ZERO_OR_MORE = const InstructionTypes("ZERO_OR_MORE", 15);

  final int id;

  final String name;

  const InstructionTypes(this.name, this.id);

  String toString() => name;
}

abstract class Instruction {
  static const int OFFSET_ID = 0;

  static const int OFFSET_DATA = 1;

  static const int MIN_SIZE = 1;

  List<String> action;

  int address;

  Instruction();

  Instruction.parameterized({this.action});

  int get size;

  InstructionTypes get type;

  Object accept(InstructionVisitor visitor);

  Object visitChildren(InstructionVisitor visitor) {
    return null;
  }

  String toString() => type.toString();
}
