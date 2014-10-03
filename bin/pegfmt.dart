import "dart:io";
import 'peg_parser.dart';
import "package:args_helper/args_helper.dart";
import 'package:peg/grammar/grammar.dart';
import 'package:peg/grammar/expressions.dart';
import 'package:peg/grammar/expression_visitors.dart';
import 'package:peg/grammar/production_rule.dart';
import 'package:peg/utils/utils.dart';
import 'package:text/text.dart';
import "package:yaml/yaml.dart" as yaml;

void main(List<String> arguments) {
  var configuration = yaml.loadYaml(_configuration);
  new ArgsHelper<Program>().run(arguments, configuration);
}

class Program {
  void formatCommand(String filename, {String output, String sort}) {
    var parser = _getParser(filename);
    var grammar = _parseGrammar(parser);
    var nonterminals = <ProductionRule>[];
    var lexemes = <ProductionRule>[];
    var morphemes = <ProductionRule>[];
    _sort(grammar.productionRules, sort, nonterminals, lexemes, morphemes);
    var text = _print(grammar, nonterminals, lexemes, morphemes);
    if (output != null) {
      new File(output).writeAsStringSync(text);
    } else {
      print(text);
    }
  }

  void _error(String message) {
    print(message);
    exit(-1);
  }

  PegParser _getParser(String filename) {
    var file = new File(filename);
    if (!file.existsSync()) {
      _error('File not found: $filename');
      return null;
    }

    var text = file.readAsStringSync();
    return new PegParser(text);
  }

  Grammar _parseGrammar(PegParser parser) {
    var grammar = parser.parse_Grammar();
    if (!parser.success) {
      var text = new Text(parser.text);
      for (var error in parser.errors()) {
        var location = text.locationAt(error.position);
        var message = "Parser error at $location. ${error.message}";
        print(message);
      }

      exit(-1);
    }

    return grammar;
  }

  String _print(Grammar grammar, List<ProductionRule> nonterminals, List<ProductionRule> lexemes, List<ProductionRule> morphemes) {
    var sb = new StringBuffer();
    var globals = grammar.globals;
    if (globals != null) {
      sb.writeln("%{");
      for (var string in Utils.codeToStrings(globals)) {
        sb.writeln(string);
      }

      sb.writeln("}%");
      sb.writeln("");
    }

    var members = grammar.members;
    if (members != null) {
      sb.writeln("{");
      for (var string in Utils.codeToStrings(globals)) {
        sb.writeln(string);
      }

      sb.writeln("}");
      sb.writeln("");
    }

    if (!nonterminals.isEmpty) {
      sb.writeln("# Nonterminals");
      sb.writeln("");
      _printProductionRules(nonterminals, sb);
    }

    if (!lexemes.isEmpty) {
      sb.writeln("");
      sb.writeln("# Lexemes");
      sb.writeln("");
      _printProductionRules(lexemes, sb);
    }

    if (!morphemes.isEmpty) {
      sb.writeln("");
      sb.writeln("# Morphemes");
      sb.writeln("");
      _printProductionRules(morphemes, sb);
    }

    return sb.toString();
  }

  void _printProductionRules(List<ProductionRule> productionRules, StringBuffer sb) {
    var length = productionRules.length;
    for (var i = 0; i < length; i++) {
      var productionRule = productionRules[i];
      var expression = productionRule.expression;
      if (i != 0) {
        sb.writeln();
      }

      sb.write(productionRule.name);
      sb.writeln(" <-");
      expression.accept(new TextPrinter(sb));
    }
  }

  void _sort(List<ProductionRule> productionRules, String sort, List<ProductionRule> nonterminals, List<ProductionRule> lexemes, List<ProductionRule> morphemes) {
    switch (sort) {
      case "call":
        _sortByOccurence(productionRules, nonterminals, lexemes, morphemes);
        lexemes.sort((a, b) => a.name.compareTo(b.name));
        morphemes.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "name":
        _sortByGroup(productionRules, nonterminals, lexemes, morphemes);
        nonterminals.sort((a, b) => a.name.compareTo(b.name));
        lexemes.sort((a, b) => a.name.compareTo(b.name));
        morphemes.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "none":
        _sortByGroup(productionRules, nonterminals, lexemes, morphemes);
        lexemes.sort((a, b) => a.name.compareTo(b.name));
        morphemes.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  void _sortByGroup(List<ProductionRule> productionRules, List<ProductionRule> nonterminals, List<ProductionRule> lexemes, List<ProductionRule> morphemes) {
    for (var productionRule in productionRules) {
      if (productionRule.isLexeme) {
        lexemes.add(productionRule);
      } else if (productionRule.isMorpheme) {
        morphemes.add(productionRule);
      } else {
        nonterminals.add(productionRule);
      }
    }
  }

  void _sortByOccurence(List<ProductionRule> productionRules, List<ProductionRule> nonterminals, List<ProductionRule> lexemes, List<ProductionRule> morphemes) {
    var processed = new Set<ProductionRule>();
    for (var productionRule in productionRules) {
      if (productionRule.isStartingRule) {
        _sortByOccurence2(productionRule, nonterminals, lexemes, morphemes, processed);
      }
    }
  }

  void _sortByOccurence2(ProductionRule productionRule, List<ProductionRule> nonterminals, List<ProductionRule> lexemes, List<ProductionRule> morphemes, Set<ProductionRule> processed) {
    if (processed.contains(productionRule)) {
      return;
    }

    processed.add(productionRule);
    if (productionRule.isLexeme) {
      lexemes.add(productionRule);
    } else if (productionRule.isMorpheme) {
      morphemes.add(productionRule);
    } else {
      nonterminals.add(productionRule);
    }

    for (var directCallee in productionRule.directCallees) {
      _sortByOccurence2(directCallee, nonterminals, lexemes, morphemes, processed);
    }
  }
}

class TextPrinter extends ExpressionVisitor {
  StringBuffer sb;

  TextPrinter(this.sb);

  visitAndPredicate(AndPredicateExpression expression) {
    sb.write("&");
    expression.expression.accept(this);
  }

  visitAnyCharacter(AnyCharacterExpression expression) {
    sb.write(expression);
  }

  visitCharacterClass(CharacterClassExpression expression) {
    sb.write(expression);
  }

  visitLiteral(LiteralExpression expression) {
    sb.write(expression);
  }

  visitNotPredicate(NotPredicateExpression expression) {
    sb.write("!");
    expression.expression.accept(this);
  }

  visitOneOrMore(OneOrMoreExpression expression) {
    expression.expression.accept(this);
    sb.write("+");
  }

  visitOptional(OptionalExpression expression) {
    expression.expression.accept(this);
    sb.write("?");
  }

  visitOrderedChoice(OrderedChoiceExpression expression) {
    var parent = expression.parent;
    var expressions = expression.expressions;
    var length = expressions.length;
    if (parent != null) {
      sb.write("(");
    }

    for (var i = 0; i < length; i++) {
      if (parent == null) {
        sb.write("  ");
      }

      if (i != 0) {
        if (parent != null) {
          sb.write(" ");
        }

        sb.write("/ ");
      }

      var child = expressions[i];
      child.accept(this);
      if (parent == null) {
        sb.writeln();
      }
    }

    if (parent != null) {
      sb.write(")");
    }
  }

  visitRule(RuleExpression expression) {
    sb.write(expression.name);
  }

  visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var length = expressions.length;
    for (var i = 0; i < length; i++) {
      if (i != 0) {
        sb.write(" ");
      }

      var child = expressions[i];
      child.accept(this);
      _printAction(child.action);
    }
  }

  visitZeroOrMore(ZeroOrMoreExpression expression) {
    expression.expression.accept(this);
    sb.write("*");
  }

  void _error(Expression expression) {
    throw new StateError("Unknow expression type: ${expression.type}");
  }

  void _printAction(String action) {
    if (action == null) {
      return;
    }

    var strings = Utils.codeToStrings(action);
    if (strings.length == 1) {
      sb.write(" { ");
      sb.write(strings.first);
      sb.write(" }");
    } else {
      sb.writeln();
      sb.writeln("  {");
      for (var string in strings) {
        sb.write("    ");
        sb.writeln(string);
      }

      sb.write("  }");
    }
  }
}

class RulesFinder extends UnifyingExpressionVisitor {
  Set<ProductionRule> productionRules;

  RulesFinder() {
    productionRules = new Set<ProductionRule>();
  }

  visitRule(RuleExpression expression) {
    var productionRule = expression.rule;
    if (productionRule != null) {
      productionRules.add(productionRule);
    }
  }
}

var _configuration = '''
name: pegfmt
description: PEG (Parsing expression grammar) formatter.
commands:
  format:
    description: Format PEG grammar.
    options:      
      output:
        help: The output file name.
        abbr: o
      sort:       
        help: Sort order of nonterminals.
        allowed: [call, name, none]
        defaultsTo: call
        abbr: s
    rest:
      allowMultiple: false
      help: PEG grammar file
      name: pegfile
      required: true
''';
