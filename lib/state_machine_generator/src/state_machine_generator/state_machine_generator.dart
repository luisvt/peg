part of peg.state_machine_generator.state_machine_generator;

class StateMachineGenerator extends TemplateGenerator {
  static const String _TEMPLATE = "TEMPLATE";

  static final _template = '''
{{#ACTIONS}}''';

  Map<int, List<String>> _actions;

  String _name;

  StateMachineGenerator(String name, Map<int, List<String>> actions) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    if (actions == null) {
      throw new ArgumentError("actions: $actions");
    }

    addTemplate(_TEMPLATE, _template);
    _actions = actions;
    _name = name;
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("#ACTIONS", _generateCases());
    return block.process();
  }

  List<String> _generateCases() {
    var body = new BodyBuilder();
    var blocks = <BlockBuilder>[];
    var cases = <int>[];
    for (var key in _actions.keys) {
      cases.add(key);
      var block = new BlockBuilder();
      blocks.add(block);
      for (var line in _actions[key]) {
        block.line(line);
      }
    }

    CaseGenerator.generate(_name, cases, blocks, body);
    return body.build(" ", 0);
  }
}
