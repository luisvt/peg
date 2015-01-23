import "dart:io";
import "package:args_helper/args_helper.dart";
import 'package:path/path.dart' as path;
import 'package:peg/grammar/grammar.dart';
import 'package:peg/grammar/production_rule.dart';
import 'package:peg/grammar_analyzer/grammar_analyzer.dart';
import 'package:peg/grammar_reporter/grammar_reporter.dart';
import 'package:peg/general_parser/parser_generator.dart';
import 'package:peg/interpreter_parser/parser_generator.dart';
import 'package:peg/parser_generator/parser_generator_options.dart';
import 'package:strings/strings.dart';
import 'package:text/text.dart';
import "package:yaml/yaml.dart" as yaml;
import 'peg_parser.dart';

void main(List<String> arguments) {
  var configuration = yaml.loadYaml(_configuration);
  new ArgsHelper<Program>().run(arguments, configuration);
}

class Program {
  void generalCommand(String filename, {bool comment, bool lookahead, bool memoize, String name, String output, bool trace}) {
    var basename = path.basenameWithoutExtension(filename);
    if (output == null || output.isEmpty) {
      output = underscore(basename) + '_parser.dart';
    }

    if (name == null || name.isEmpty) {
      name = camelize(basename) + 'Parser';
    }

    // TODO: Temporarily disable lookahead
    lookahead = false;

    var parser = _getParser(filename);
    var grammar = _parseGrammar(parser);
    var options = new ParserGeneratorOptions();
    options.comment = comment;
    options.lookahead = lookahead;
    options.memoize = memoize;
    options.trace = trace;
    var generator = new GeneralParserGenerator(name, grammar, options);
    var genarated = generator.generate();
    new File(output).writeAsStringSync(genarated.join('\n'));
  }

  void interpretCommand(String filename, {bool memoize, String name, String output}) {
    print("Not implemented yet.");
    //exit(-1);
    var basename = path.basenameWithoutExtension(filename);
    if (output == null || output.isEmpty) {
      output = underscore(basename) + '_parser.dart';
    }

    if (name == null || name.isEmpty) {
      name = camelize(basename) + 'Parser';
    }

    var parser = _getParser(filename);
    var grammar = _parseGrammar(parser);
    var options = new ParserGeneratorOptions();
    options.memoize = memoize;
    var generator = new InterpreterParserGenerator(name, grammar, options);
    var genarated = generator.generate();
    print(genarated.join('\n'));
    //new File(output).writeAsStringSync(genarated.join('\n'));
  }

  void printCommand(String filename) {
    var parser = _getParser(filename);
    var grammar = _parseGrammar(parser);
    print(grammar);
  }

  void statCommand(String filename, {String detail}) {
    var parser = _getParser(filename);
    var grammar = _parseGrammar(parser);
    _report(new GrammarReporter(grammar), detail);
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

    var grammarAnalyzer = new GrammarAnalyzer();
    var warnings = grammarAnalyzer.analyze(grammar);
    if (!warnings.isEmpty) {
      for (var warning in warnings) {
        print(warning);
      }
    }

    return grammar;
  }

  void _report(GrammarReporter reporter, String level) {
    String ruleAndKind(ProductionRule rule) {
      var kind = " ";
      switch (rule.kind) {
        case ProductionRuleKinds.LEXEME:
          kind = "L";
          break;
        case ProductionRuleKinds.MORHEME:
          kind = "M";
          break;
        case ProductionRuleKinds.SENTENCE:
          kind = "S";
          break;
      }

      return "($kind) ${rule.name}";
    }

    var detail = level == 'high';
    if (detail) {
      print('--------------------------------');
      print('Log entries:');
      for (var line in reporter.logs) {
        print('${line}');
      }

      print('--------------------------------');
      print('Starting rules:');
      for (var rule in reporter.startingRules) {
        print('${rule.name}');
      }

      print('--------------------------------');
      print('Rules:');
      for (var rule in reporter.rules) {
        print('--------------------------------');
        print('${rule.name}:');
        var type = "";
        switch (rule.kind) {
          case ProductionRuleKinds.LEXEME:
            type = "Lexeme (token)";
            break;
          case ProductionRuleKinds.MORHEME:
            type = "Morheme";
            break;
          case ProductionRuleKinds.SENTENCE:
            type = "Sentence (nonterminal)";
            break;
        }

        print(' Type: $type');
        print(' Direct callees:');
        var callees = rule.directCallees.toList();
        callees.sort((a, b) => a.name.compareTo(b.name));
        for (var callee in callees) {
          print('  ${ruleAndKind(callee)}');
        }

        print(' All callees:');
        callees = rule.allCallees.toList();
        callees.sort((a, b) => a.name.compareTo(b.name));
        for (var callee in callees) {
          print('  ${ruleAndKind(callee)}');
        }

        print(' Direct callers:');
        var callers = rule.directCallers.toList();
        callers.sort((a, b) => a.name.compareTo(b.name));
        for (var caller in callers) {
          print('  ${ruleAndKind(caller)}');
        }

        print(' All callers:');
        callers = rule.allCallers.toList();
        callers.sort((a, b) => a.name.compareTo(b.name));
        for (var caller in callers) {
          print('  ${ruleAndKind(caller)}');
        }

        print(' Start characters:');
        var characters = <String>[];
        for (var group in rule.expression.startCharacters.groups) {
          String end;
          String start;
          if (group.end < 128) {
            end = toPrintable(new String.fromCharCode(group.end));
          } else {
            end = toUnicode(group.end);
          }

          if (group.start < 128) {
            start = toPrintable(new String.fromCharCode(group.start));
          } else {
            start = toUnicode(group.start);
          }

          if (group.start == group.end) {
            characters.add("[$start]");
          } else {
            characters.add("[$start-$end]");
          }
        }

        if (!characters.isEmpty) {
          print('  ${characters.join()}');
        }

        print(' Expected lexemes (tokens):');
        var expected = <String>[];
        for (var lexeme in rule.expression.expectedLexemes) {
          expected.add(lexeme);
        }

        if (!expected.isEmpty) {
          print('  ${expected.join(" ")}');
        }
      }
    }

    print('--------------------------------');
    print('Sentences (nonterminals):');
    for (var rule in reporter.nonterminals) {
      print('  ${rule.name}');
    }

    print('--------------------------------');
    print('Lexemes (tokens):');
    for (var rule in reporter.terminals) {
      if (rule.isLexeme) {
        print('  ${rule.name}');
      }
    }

    print('--------------------------------');
    print('Morphemes:');
    for (var rule in reporter.terminals) {
      if (rule.isMorpheme) {
        print('  ${rule.name}');
      }
    }

    print('--------------------------------');
    print('Lexeme (token) names:');
    for (var rule in reporter.terminals) {
      if (rule.isLexeme) {
        print('  ${rule.name} : ${rule.getTokenName()}');
      }
    }

    print('--------------------------------');
    print('Recursives:');
    for (var rule in reporter.recursives) {
      print('  ${rule.name}');
    }
  }
}

String _configuration = '''
name: peg
description: PEG (Parsing expression grammar) parser generator.
commands:
  general:
    description: Generate a general parser based on method invocations.
    options:
      comment:
        help: Generate the comments for each expression.
        isFlag: true
        defaultsTo: false
        abbr: c
      lookahead:
        help: Increases the performance by reducing the number of invocations of production rules (looks ahead).
        isFlag: true
        defaultsTo: false
        abbr: l
      memoize:
        help: Memoize the intermediate results of all invocations of the mutually recursive parsing functions.
        isFlag: true
        defaultsTo: true
        abbr: m
      name:
        help: The class name of the generated parser.
        abbr: n
      output:
        help: The output file name.
        abbr: o
      trace:
        help: Generate the code with tracing information.
        isFlag: true
        defaultsTo: false
        abbr: t                       
    rest:
      allowMultiple: false
      help: PEG grammar file
      name: grammar
      required: true
  interpret:
    description: Generate a parser based on the interpreter with a virtual machine.
    options:
      memoize:
        help: Memoize the intermediate results of all mutually recursive production rules.
        isFlag: true
        defaultsTo: true
        abbr: m
      name:
        help: The class name of the generated parser.
        abbr: n
      output:
        help: The output file name.
        abbr: o
    rest:
      allowMultiple: false
      help: PEG grammar file
      name: grammar
      required: true
  print:
    description: Print plain grammar.
    rest:
      allowMultiple: false
      help: PEG grammar file
      name: grammar
      required: true
  stat:
    description: Print grammar statistics.
    options:
      detail:
        help: The level of the detail of the statistics.
        abbr: d
        allowed: [low, high]
        defaultsTo: low
    rest:
      allowMultiple: false
      help: PEG grammar file
      name: grammar
      required: true
''';
