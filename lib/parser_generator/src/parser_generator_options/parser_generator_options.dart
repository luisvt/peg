part of peg.parser_generators.parser_generator_options;

class ParserGeneratorOptions {

  ParserGeneratorOptions();

  ParserGeneratorOptions.fromMap(Map options) {
    comment = _defaultIfNull(options['coments'], true);
    // TODO: Temporarily disable lookahead
    // lookahead = _defaultIfNull(options['lookahead'], false);
    lookahead = false;
    memoize = _defaultIfNull(options['memoize'], false);
    trace = _defaultIfNull(options['trace'], false);
  }

  _defaultIfNull(orig, def) => orig != null ? orig : def;

  bool comment = false;

  bool lookahead = false;

  bool memoize = false;

  bool trace = false;
}
