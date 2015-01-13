part of peg.interpreter_parser.optimizer;

class Optimizer {
  Instruction optimize(Instruction instruction) {
    if (instruction == null) {
      throw new ArgumentError();
    }

    // TODO: Temporarily don't optimize
    if (true == true) {
      return instruction;
    }

    while (true) {
      var opimizer = new RedundantInstructionRemover();
      instruction = opimizer.optimize(instruction);
      if (opimizer.numberOfOptimizations == 0) {
        break;
      }
    }

    return instruction;
  }
}
