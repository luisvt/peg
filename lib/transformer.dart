import 'package:barback/barback.dart';
import 'package:peg/peg_parser.dart';
import 'package:peg/grammar/grammar.dart';
import 'package:parser_error/parser_error.dart';
import 'package:peg/grammar/production_rule.dart';
import 'package:peg/grammar_analyzer/grammar_analyzer.dart';
import 'package:peg/grammar_reporter/grammar_reporter.dart';
import 'package:peg/general_parser/parser_generator.dart';
import 'package:peg/interpreter_parser/parser_generator.dart';
import 'package:peg/parser_generator/parser_generator_options.dart';
import 'package:path/path.dart' as path;
import 'package:strings/strings.dart';
import 'dart:async';

class PegTransformer extends Transformer {
  final BarbackSettings _settings;

  PegTransformer.asPlugin(this._settings);

  String get allowedExtensions => ".peg";

  @override
  Future apply(Transform transform) async {
    var content = await transform.primaryInput.readAsString();
    var id = transform.primaryInput.id.changeExtension('.dart');
    transform.get
    print('id.path: ${id.path}');

    var basename = path.basenameWithoutExtension(id.path);
    print('basename: $basename');

    var parser = new PegParser(content);
    var grammar = _parseGrammar(parser);
    var options = new ParserGeneratorOptions.fromMap(_settings.configuration);

    var name = camelize(basename) + 'Parser';
    print('name: $name');

    var generated = new GeneralParserGenerator(name, grammar, options).generate().join('\n');

    print('generated: ${generated.substring(0, 10000)}');
    transform.addOutput(new Asset.fromString(id, generated));

    return new Future.delayed(new Duration(seconds: 5));

  }

  Grammar _parseGrammar(PegParser parser) {
    var grammar = parser.parse_Grammar();
    if (!parser.success) {
      var messages = [];
      for (var error in parser.errors()) {
        messages.add(new ParserErrorMessage(error.message, error.start, error.position));
      }

      var strings = ParserErrorFormatter.format(parser.text, messages);
      print(strings.join("\n"));
      throw new FormatException();
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
}