part of peg.expressions;

class RuleExpression extends Expression {
  final String name;

  ProductionRule rule;

  RuleExpression(this.name) : super() {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }
  }

  ExpressionTypes get type {
    return ExpressionTypes.RULE;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitRule(this);
  }

  String toString() {
    return name;
  }

  Object visitChildren(ExpressionVisitor visitor) {
    return this;
  }
}
