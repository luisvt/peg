part of peg.template_block;

class TemplateBlock {
  Map<String, int> _keys;
  List<_TemplateLine> _lines;
  List<List> _values;

  TemplateBlock(String template) {
    if (template == null) {
      throw new ArgumentError('template: $template');
    }

    _keys = {};
    _lines = [];
    _values = [];
    var parser = new _TemplateLineParser();
    var text = template.replaceAll('\r\n', '\n');
    text = text.replaceAll('\r', '\n');
    var strings = text.split('\n');
    for (var string in strings) {
      var line = parser.parse(string, this);
      _lines.add(line);
    }
  }

  TemplateBlock._internal();

  void assign(String key, dynamic value) {
    if (key == null) {
      throw new ArgumentError('key: $key');
    }

    var index = _keys[key];
    if (index == null) {
      throw new StateError('Key not found: $key');
    }

    if (key.startsWith('#')) {
      _values[index].add(value);
    } else {
      _values[index] = value;
    }
  }

  TemplateBlock clone() {
    var cloned = new TemplateBlock._internal();
    cloned._keys = _keys;
    cloned._values = new List.generate(_values.length, (i) => []);
    cloned._lines = [];
    for (var line in _lines) {
      cloned._lines.add(line.clone(cloned));
    }

    return cloned;
  }

  List<String> process() {
    var strings = [];
    for (var line in _lines) {
      strings.addAll(line.process());
    }

    return strings;
  }

  void reassign(String key, dynamic value) {
    if (key == null) {
      throw new ArgumentError('key: $key');
    }

    var index = _keys[key];
    if (index == null) {
      throw new StateError('Key not found: $key');
    }

    _values[index] = [value];
  }

  int _addKey(String key) {
    if (key == null) {
      throw new ArgumentError('key: $key');
    }

    var index = _keys[key];
    if (index != null) {
      return index;
    }

    index = _values.length;
    _keys[key] = index;
    if (key.startsWith('#')) {
      _values.add([]);
    } else {
      _values.add(null);
    }

    return index;
  }
}

abstract class _TemplateLine {
  final TemplateBlock _template;

  _TemplateLine(this._template) {
    if (_template == null) {
      throw new ArgumentError('_template: $_template');
    }
  }

  _TemplateLine clone(TemplateBlock template);

  List<String> process();
}

class _TemplateMultiLine extends _TemplateLine {
  String _prefix;
  String _suffix;
  int _value;

  _TemplateMultiLine(TemplateBlock template) : super(template);

  _TemplateMultiLine clone(TemplateBlock template) {
    var cloned = new _TemplateMultiLine(template);
    cloned._prefix = _prefix;
    cloned._suffix = _suffix;
    cloned._value = _value;
    return cloned;
  }

  List<String> process() {
    List<String> strings = [];
    _processList(_template._values[_value], strings);

    return strings;
  }

  void _processList(List list, List<String> strings) {
    for (var value in list) {
      if (value is List) {
        _processList(value, strings);
      } else {
        strings.add('$_prefix$value$_suffix');
      }
    }
  }
}

class _TemplateSingleLine extends _TemplateLine {
  List _parts;

  _TemplateSingleLine(TemplateBlock template) : super(template);

  _TemplateSingleLine clone(TemplateBlock template) {
    var cloned = new _TemplateSingleLine(template);
    cloned._parts = _parts.toList();
    return cloned;
  }

  List<String> process() {
    var length = _parts.length;
    List<String> string = [];
    for (var i = 0; i < length; i++) {
      var part = _parts[i];
      if (part is int) {
        var value = _template._values[part];
        if (value != null) {
          string.add(value);
        }
      } else {
        string.add(_parts[i]);
      }
    }

    return [string.join()];
  }
}

class _TemplateLineParser {
  String text;
  int textLen;
  int textPos;

  _TemplateLine parse(String text, TemplateBlock template) {
    if (text == null) {
      throw new ArgumentError('text: $text');
    }

    this.text = text;
    textLen = text.length;
    textPos = 0;

    var result = _parseMultiLine(template);
    if (result != null) {
      return result;
    }

    return _parseSingleLine(template);
  }

  _TemplateMultiLine _parseMultiLine(TemplateBlock template) {
    var pos = textPos;
    var ident;
    var prefix = [];
    var suffix = [];
    while (true) {
      ident = _parseMultiValue();
      if (ident != null) {
        break;
      }

      var c = _getc();
      if (c == null) {
        break;
      }

      prefix.add(c);
    }

    if (ident != null) {
      while (true) {
        var c = _getc();
        if (c == null) {
          break;
        }

        suffix.add(c);
      }

      var line = new _TemplateMultiLine(template);
      line._prefix = prefix.join();
      line._suffix = suffix.join();
      line._value = template._addKey('#$ident');
      return line;
    }

    textPos = pos;
    return null;
  }

  _TemplateSingleLine _parseSingleLine(TemplateBlock template) {
    var pos = textPos;
    var parts = [];
    while (true) {
      var ident = _parseSingleValue();
      if (ident != null) {
        parts.add(template._addKey(ident));
      }

      var c = _getc();
      if (c == null) {
        break;
      }

      var part = [c];
      while (true) {
        var pos = textPos;
        if (_parseSingleValue() != null) {
          textPos = pos;
          break;
        }

        var c = _getc();
        if (c == null) {
          break;
        }
        part.add(c);
      }

      parts.add(part.join());
    }

    var line = new _TemplateSingleLine(template);
    line._parts = parts;
    return line;
  }

  String _parseMultiValue() {
    var pos = textPos;
    var result = [];
    if (_match('{{#')) {
      if (!_match('}}')) {
        var c = _getc();
        if (c != null) {
          result.add(c);
        }

        while (true) {
          if (_match('}}')) {
            break;
          }

          var c = _getc();
          if (c != null) {
            result.add(c);
          }
        }

        if (!result.isEmpty) {
          result = result.join();
          return result;
        }
      }
    }

    textPos = pos;
    return null;
  }

  String _parseSingleValue() {
    var pos = textPos;
    var result = [];
    if (_match('{{')) {
      if (!_match('}}')) {
        var c = _getc();
        if (c != null) {
          result.add(c);
        }

        while (true) {
          if (_match('}}')) {
            break;
          }

          var c = _getc();
          if (c != null) {
            result.add(c);
          }
        }

        if (!result.isEmpty) {
          result = result.join();
          return result;
        }
      }
    }

    textPos = pos;
    return null;
  }

  String _getc() {
    if (textPos < textLen) {
      return text[textPos++];
    }

    return null;
  }

  bool _match(String s) {
    var length = s.length;
    if (textPos + length <= textLen) {
      if (text.substring(textPos, textPos + length) == s) {
        textPos += length;
        return true;
      }
    }

    return false;
  }
}
