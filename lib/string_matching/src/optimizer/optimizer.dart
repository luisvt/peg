part of string_matching.optimizer;

class Optimizer {
  Instruction optimize(Instruction instruction) {
    if (instruction == null) {
      throw new ArgumentError();
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
