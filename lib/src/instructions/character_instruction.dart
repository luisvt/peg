part of peg.instructions;

class CharacterInstruction extends Instruction {
  String character;

  CharacterInstruction(this.character) {
    if (character == null || character.length != 1) {
      throw new ArgumentError("character: $character");
    }
  }

  InstructionTypes get type => InstructionTypes.CHARACTER;
}
