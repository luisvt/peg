part of peg.expressions;

abstract class Expression {
  static const int FLAG_ABLE_NOT_CONSUME_INPUT = 1;

  static const int FLAG_HAS_ACTIONS = 2;

  static const int FLAG_OPTIONAL = 4;

  static const int FLAG_REPETITION = 8;

  static final GroupedRangeList<bool> asciiGroup = new GroupedRangeList<bool>(0, 127, true);

  static final GroupedRangeList<bool> nonAsciiGroup = new GroupedRangeList<bool>(128, 1114111, true);

  static final GroupedRangeList<bool> unicodeGroup = new GroupedRangeList<bool>(0, 1114111, true);

  String action;

  Set<Expression> allAbleNotConsumeInputExpressions = new Set<Expression>();

  Set<Expression> allLeftExpressions = new Set<Expression>();

  Set<Expression> allRightExpressions = new Set<Expression>();

  Set<Expression> directAbleNotConsumeInputExpressions = new Set<Expression>();

  Set<Expression> directLeftExpressions = new Set<Expression>();

  Set<Expression> directRightExpressions = new Set<Expression>();

  Set<String> expectedLexemes = new Set<String>();

  int flag = 0;

  // TODO: remove
  int level = 0;

  Expression next;

  ProductionRule owner;

  Expression parent;

  int positionInSequence = 0;

  // TODO: remove 'sematicValue'
  String semanticValue;

  // TODO: rename
  SparseBoolList startCharacters = new SparseBoolList();

  Expression previous;

  bool get hasActions {
    return (flag & FLAG_HAS_ACTIONS) != 0;
  }

  bool get isAbleNotConsumeInput {
    return (flag & FLAG_ABLE_NOT_CONSUME_INPUT) != 0;
  }

  bool get isOptional {
    return (flag & FLAG_OPTIONAL) != 0;
  }

  bool get isRepetition {
    return (flag & FLAG_REPETITION) != 0;
  }

  bool get startsWithAny {
    if (startCharacters.isEmpty) {
      return false;
    }

    var range = new RangeList(startCharacters.start, startCharacters.end);
    return range == unicodeGroup;
  }

  bool get startsWithNonAscii {
    if (startCharacters.isEmpty) {
      return false;
    }

    var range = new RangeList(startCharacters.start, startCharacters.end);
    return range.intersect(nonAsciiGroup);
  }

  ExpressionTypes get type;

  Object accept(ExpressionVisitor visitor);

  Object visitChildren(ExpressionVisitor visitor);
}
