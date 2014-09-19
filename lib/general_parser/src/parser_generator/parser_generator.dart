part of peg.general_parser.parser_generator;

class GeneralParserGenerator extends ParserGenerator {
  GeneralParserGenerator(String name, Grammar grammar, ParserGeneratorOptions options) : super(name, grammar, options);

  List<String> generate() {
    addClass(new GeneralParserClassGenerator(name, grammar, this));
    return super.generate();
  }
}
