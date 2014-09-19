part of string_matching.generators;

abstract class TemplateGenerator extends Generator {
  static Map<String, String> _templates = {};

  static Map<String, TemplateBlock> _templateBlocks = {};

  void addTemplate(String name, String template) {
    if (name == null) {
      throw new ArgumentError('name: $name');
    }

    if (template == null) {
      throw new ArgumentError('template: $template');
    }

    var key = '${_generatorId}_$name';
    _templates[key] = template;
  }

  String get _generatorId => runtimeType.toString();

  String getTemplate(String name) {
    var template = _templates['${_generatorId}_$name'];
    if (template == null) {
      throw new StateError('Template not found: $name');
    }

    return template;
  }

  TemplateBlock getTemplateBlock(String name) {
    var key = '${_generatorId}_$name';
    var block = _templateBlocks[key];
    if (block == null) {
      var template = getTemplate(name);
      block = new TemplateBlock(template);
      _templateBlocks[key] = block;
      return block;
    }

    return block.clone();
  }
}
