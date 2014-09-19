part of peg.general_parser.expressions_generators;

abstract class ListExpressionGenerator extends ExpressionGenerator {
  ListExpressionGenerator(ListExpression expression, ProductionRuleGenerator productionRuleGenerator) : super(expression, productionRuleGenerator) {
    for (var expression in expression.expressions) {
      _generators.add(createGenerator(expression, productionRuleGenerator));
    }
  }
}
