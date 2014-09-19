part of peg.general_parser.expressions_generators;

abstract class UnaryExpressionGenerator extends ExpressionGenerator {
  UnaryExpressionGenerator(Expression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    if (expression is! UnaryExpression) {
      throw new StateError('Expression must be UnaryExpression');
    }

    _generators.add(createGenerator((expression as UnaryExpression).expression, productionRuleGenerator));
  }
}
