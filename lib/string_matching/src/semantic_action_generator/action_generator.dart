part of string_matching.semantic_action_generator;

class ActionGenerator extends TemplateGenerator {
  static const String RESULT = "\$\$";

  static const String _VALUES = "v";

  static const String _TEMPLATE = "TEMPLATE";

  static const String _TEMPLATE_SINGLE = "TEMPLATE_SINGLE";

  static const String _TEMPLATE_VARIABLES = "TEMPLATE_VARIABLES";

  static final String _template = '''
{{#VARIABLES}}
{{#ACTION}}
return {{RESULT}};''';

  static final String _templateSingle = '''
final \$1 = $_VALUES;  
{{#ACTION}}
return {{RESULT}};''';

  static final String _templateVariables = '''
final {{VARIABLES}};''';

  List<String> action;

  final int count;

  final int position;

  ActionGenerator(this.action, this.position, this.count) {
    if (action == null) {
      throw new ArgumentError("action: $action");
    }

    if (position == null || position < 0) {
      throw new ArgumentError("position: $position");
    }

    if (count == null || count < 0) {
      throw new ArgumentError("count: $count");
    }

    addTemplate(_TEMPLATE, _template);
    addTemplate(_TEMPLATE_SINGLE, _templateSingle);
    addTemplate(_TEMPLATE_VARIABLES, _templateVariables);
  }

  List<String> generate() {
    if (position == 0 && count == 1) {
      return _generateSingle();
    } else {
      return _generate();
    }
  }

  List<String> _generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign("RESULT", RESULT);
    block.assign("#ACTION", action);
    block.assign("#VARIABLES", _generateVariables());
    return block.process();
  }

  List<String> _generateSingle() {
    var block = getTemplateBlock(_TEMPLATE_SINGLE);
    block.assign("RESULT", RESULT);
    block.assign("#ACTION", action);
    return block.process();
  }

  List<String> _generateVariables() {
    var block = getTemplateBlock(_TEMPLATE_VARIABLES);
    var vars = new List<String>(position + 1);
    for (var i = 0; i < vars.length; i++) {
      var name = _getValueName(i);
      vars[i] = "$name = $_VALUES[$i]";
    }

    block.assign("VARIABLES", vars.join(", "));
    return block.process();
  }

  String _getValueName(int position) {
    return "\$${position + 1}";
  }
}
