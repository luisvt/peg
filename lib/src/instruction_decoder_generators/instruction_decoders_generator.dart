part of peg.instruction_decoder_generators;

class InstructionDecodersGenerator {
  final MethodParseGenerator methodParseGenerator;

  InstructionDecodersGenerator(this.methodParseGenerator) {
    if (methodParseGenerator == null) {
      throw new ArgumentError("methodParseGenerator: $methodParseGenerator");
    }
  }

  Map<int, List<String>> generate() {
    var result = <int, List<String>>{};
    var generators = <InstructionDecoderGenerator>[];
    generators.add(new AndPredicateDecoderGenerator(methodParseGenerator));
    generators.add(new AnyCharacterDecoderGenerator(methodParseGenerator));
    generators.add(new CharacterClassDecoderGenerator(methodParseGenerator));
    generators.add(new CharacterDecoderGenerator(methodParseGenerator));
    generators.add(new EmptyDecoderGenerator(methodParseGenerator));
    generators.add(new LiteralDecoderGenerator(methodParseGenerator));
    generators.add(new NotPredicateDecoderGenerator(methodParseGenerator));
    generators.add(new OneOrMoreDecoderGenerator(methodParseGenerator));
    generators.add(new OptionalDecoderGenerator(methodParseGenerator));
    generators.add(new OrderedChoiceDecoderGenerator(methodParseGenerator));
    generators.add(new RuleDecoderGenerator(methodParseGenerator));
    generators.add(new SequenceDecoderGenerator(methodParseGenerator));
    generators.add(new SequenceSingleDecoderGenerator(methodParseGenerator));
    generators.add(new ZeroOrMoreDecoderGenerator(methodParseGenerator));
    for (var generator in generators) {
      var lines = generator.generate();
      var builder = new StateMethodBuilder();
      var helper = new _StateMethodBuilderHelper(generator);
      var states = builder.build(lines, helper);
      var length = states.length;
      if (generator.stateCount != length) {
        throw new StateError("Incorrect number of states in '${generator.runtimeType}'");
      }

      for (var i = 0; i < length; i++) {
        var state = states[i];
        result[generator.getStateId(i)] = state;
      }
    }

    return result;
  }
}

class _StateMethodBuilderHelper extends StateMethodBuilderHelper {
  static final String _BP = MethodParseGenerator.VARIABLE_BP;

  static final String _SP = MethodParseGenerator.VARIABLE_SP;

  static final String _STACK = MethodParseGenerator.VARIABLE_STACK;

  final InstructionDecoderGenerator generator;

  StackHelper _stackHelper;

  _StateMethodBuilderHelper(this.generator) {
    _stackHelper = new StackHelper(generator);
  }

  String get separator => generator.stateSeparator;

  List<String> onEnd(int index, int count) {
    if (index == count - 1 && generator.withLeave) {
      var result = <String>[];
      result.addAll(_stackHelper.leave());
      return result;
    } else {
      return const <String>[];
    }
  }

  List<String> onStart(int index, int count) {
    var result = <String>[];
    result.addAll(_generateComments(index));
    if (index == 0) {
      result.addAll(_stackHelper.enter());
    } else {
      //
    }

    return result;
  }

  List<String> _generateComments(int index) {
    if (generator._interpreterClassGenerator.interpreterGenerator.comment) {
      return <String>["// ${generator.instructionType} ($index)"];
    } else {
      return const <String>[];
    }
  }

  int _getStackSize() {
    return generator.localVariables.length;
  }
}
