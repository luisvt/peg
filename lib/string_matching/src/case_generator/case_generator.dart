part of string_matching.case_generator;

// TODO: Improve
class CaseGenerator {
  static void generate(String name, List<int> cases, List<BlockBuilder> blocks, Builder parent) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (blocks == null) {
      throw new ArgumentError('blocks: $blocks');
    }

    if (cases == null) {
      throw new ArgumentError('cases: $cases');
    }

    if (parent == null) {
      throw new ArgumentError('parent: $parent');
    }

    var length = blocks.length;
    if (cases.length != length) {
      throw new StateError('Lists of blocks and cases are different lengths');
    }

    List<Case> data = [];
    var values = [];
    for (var i = 0; i < length; i++) {
      if (blocks[i] is! BlockBuilder) {
        throw new StateError('Lists of blocks contains illegal values');
      }

      var value = cases[i];
      if (value is! int) {
        throw new StateError('Lists of cases contains illegal values');
      }

      if (values.contains(value)) {
        throw new StateError('Lists of cases contains repeating values');
      }

      values.add(value);
      data.add(new Case(value, blocks[i]));
    }

    data.sort((a, b) {
      return a.value - b.value;
    });

    _if(name, data, parent);
  }

  static void _if(String name, List<Case> data, BodyBuilder parent) {
    var length = data.length;
    switch (length) {
      case 0:
        break;
      case 1:
        parent.if_('$name == ${data[0].value}', (builder) {
          builder.builders.addAll(data[0].builder.builders);
        });

        break;
      case 2:
        parent.if_('$name == ${data[1].value}', (builder) {
          builder.builders.addAll(data[1].builder.builders);
          _else(name, [data[0]], builder);
        });

        break;
      case 3:
        parent.if_('$name == ${data[0].value}', (builder) {
          builder.builders.addAll(data[0].builder.builders);
          _else(name, data.sublist(1), builder);
        });

        break;
      default:
        var left = length ~/ 2;
        var right = length - left;
        parent.if_('$name < ${data[left].value}', (builder) {
          _if(name, data.sublist(0, left), builder);
          _else(name, data.sublist(left), builder);
        });

        break;
    }
  }

  static void _else(String name, List<Case> data, IfElseBuilder parent) {
    var length = data.length;
    switch (length) {
      case 0:
        break;
      case 1:
        parent.else_if('$name == ${data[0].value}', (builder) {
          builder.builders.addAll(data[0].builder.builders);
        });

        break;
      case 2:
        parent.else_if('$name == ${data[0].value}', (builder) {
          builder.builders.addAll(data[0].builder.builders);
          _else(name, [data[1]], builder);
        });

        break;
      default:
        var left = length ~/ 2;
        var right = length - left;
        parent.else_if('$name < ${data[left].value}', (builder) {
          _if(name, data.sublist(0, left), builder);
          _else(name, data.sublist(left), builder);
        });

        break;
    }
  }
}

class Case {
  int value;

  BodyBuilder builder;

  Case(this.value, this.builder);
}

abstract class Builder {
  List<Builder> builders = [];

  final Builder parent;

  Builder([this.parent]);

  Builder add(Builder builder) {
    builders.add(builder);
    return builder;
  }

  List<String> build(String indent, int level) {
    var indentation = getIndentation(indent, level);
    var lines = [];
    var count = builders.length;
    for (var i = 0; i < count; i++) {
      var builder = builders[i];
      lines.addAll(builder.build(indent, level + 1));
    }

    return lines;
  }

  String getIndentation(String indent, int level) {
    if (level > 0) {
      return new List.filled(level, indent).join('');
    }

    return '';
  }

  LineBuilder line(String text) {
    var lineBuilder = new LineBuilder(text, this);
    builders.add(lineBuilder);
    return lineBuilder;
  }
}

class LineBuilder extends Builder {
  final String text;

  LineBuilder(this.text, [Builder parent]) : super(parent);

  List<String> build(String indent, int level) {
    return ['${getIndentation(indent, level)}$text'];
  }
}

class BodyBuilder extends Builder {
  BodyBuilder([Builder parent]) : super(parent);

  BlockBuilder block(body(BodyBuilder parent)) {
    var blockBuilder = new BlockBuilder(this);
    if (body != null) {
      body(blockBuilder);
    }

    return add(blockBuilder);
  }

  IfBuilder if_(String expression, body(BodyBuilder parent)) {
    var ifBuilder = new IfBuilder(expression, this);
    if (body != null) {
      body(ifBuilder);
    }

    return add(ifBuilder);
  }
}

class StatementBuilder extends BodyBuilder {
  bool noParameters = false;

  final String parameters;

  final String statementName;

  StatementBuilder(this.statementName, this.parameters, [BodyBuilder parent]) : super(parent) {
    if (parent != null && parent.builders.length != 0) {
      if (this is! ElseBuilder && this is! ElseIfBuilder) {
        //parent.line('');
      }
    }
  }

  List<String> build(String indent, int level) {
    var indentation = getIndentation(indent, level);
    var name = statementName.isEmpty ? '' : '$statementName ';
    var lines = [];
    if (noParameters) {
      lines.add('$indentation$name{');
    } else {
      lines.add('$indentation$statementName($parameters) {');
    }

    for (var builder in builders) {
      lines.addAll(builder.build(indent, level + 1));
    }

    if (this is IfElseBuilder) {
      IfElseBuilder builder = this as IfElseBuilder;
      if (builder._else != null) {
        var strings = builder._else.build(indent, level);
        if (strings.length > 0) {
          strings[0] = strings[0].substring(indent.length * level);
        }

        strings[0] = '$indentation} ${strings[0]}';
        lines.addAll(strings);
      } else {
        lines.add('$indentation}');
        //lines.add('');
      }

    } else {
      lines.add('$indentation}');
      //lines.add('');
    }

    return lines;
  }
}

class BlockBuilder extends StatementBuilder {
  bool noParameters = true;

  BlockBuilder([BodyBuilder parent]) : super('', '', parent);
}

class ElseBuilder extends StatementBuilder {
  bool noParameters = true;

  ElseBuilder([BodyBuilder parent]) : super('else', '', parent);
}

class ElseIfBuilder extends IfElseBuilder {
  ElseIfBuilder(String expression, [BodyBuilder parent]) : super('else if', expression, parent);
}

abstract class IfElseBuilder extends StatementBuilder {
  StatementBuilder _else;

  IfElseBuilder(String statementName, String expression, [BodyBuilder parent]) : super(statementName, expression, parent);

  ElseBuilder else_(body(BodyBuilder parent)) {
    if (_else != null) {
      throw new StateError('Else block alredy defined');
    }

    _else = new ElseBuilder(this);
    if (body != null) {
      body(_else);
    }

    return _else;
  }

  ElseIfBuilder else_if(String expression, body(BodyBuilder parent)) {
    if (_else != null) {
      throw new StateError('Else block alredy defined');
    }

    _else = new ElseIfBuilder(expression, this);
    if (body != null) {
      body(_else);
    }

    return _else;
  }
}

class IfBuilder extends IfElseBuilder {
  StatementBuilder _else;

  IfBuilder(String expression, [BodyBuilder parent]) : super('if', expression, parent);
}
