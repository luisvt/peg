part of peg.interpreter_parser.instructions;

class SequenceWithOneElementInstruction extends UnaryInstruction {
  static const int FLAG_HAS_ACTION = 1;

  static const int STRUCT_SEQUENCE_ELEMENT_FLAG = 0;

  static const int STRUCT_SEQUENCE_ELEMENT_INSTRUCTION = 1;

  static const int SIZE_OF_STRUCT_SEQUENCE_ELEMENT = 2;

  SequenceWithOneElementInstruction(Instruction instruction) : super(instruction);

  SequenceWithOneElementInstruction.parameterized({List<String> action, Instruction instruction}) : super.parameterized(action: action, instruction: instruction);

  InstructionTypes get type => InstructionTypes.SEQUENCE_WITH_ONE_ELEMENT;

  Object accept(InstructionVisitor visitor) {
    return visitor.visitSequenceWithOneElement(this);
  }

  Object visitChildren(InstructionVisitor visitor) {
    return instruction.accept(visitor);
  }
}
