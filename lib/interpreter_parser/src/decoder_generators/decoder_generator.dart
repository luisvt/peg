part of peg.interpreter_parser.decoder_generators;

abstract class DecoderGenerator extends DeclarationGenerator {
  static const String VARIABLE_CP = "cp";

  static const String _CODE = InterpreterClassGenerator.CODE;

  InstructionTypes get instructionType;

  String dataFromCode(String cp) {
    return "$_CODE[$cp + ${Instruction.OFFSET_DATA}]";
  }
}
