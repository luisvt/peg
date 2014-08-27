part of peg.utils;

class Utils {
  static String charToString(int char, [bool printable = false]) {
    var string = _charToAscii(char, printable);
    if (string != null) {
      return string;
    } else {
      return _charToUnicode(char);
    }
  }

  static List<String> codeToStrings(String code) {
    if (code == null || code.isEmpty) {
      return [];
    }

    code = code.substring(1, code.lastIndexOf("}"));
    code = code.trimRight();
    code = code.replaceAll('\r\n', '\n');
    code = code.replaceAll('\r', '\n');
    code = code.replaceAll('\t', '  ');
    var lines = code.split('\n');
    var strings = [];
    if (lines.length == 1) {
      var line = lines[0];
      var length = line.length;
      var pos = 0;
      for (var i = 0; i < length; i++) {
        if (line[i] == ' ') {
          pos++;
        } else {
          break;
        }
      }

      line = line.substring(pos);
      strings.add(line);
      return strings;
    }

    var indent = 0;
    var second = lines[1];
    var length = second.length;
    for (var i = 0; i < length; i++) {
      if (second[i] == ' ') {
        indent++;
      } else {
        break;
      }
    }

    var numOfLines = lines.length;
    for (var i = 0; i < numOfLines; i++) {
      var string = lines[i];
      if (i == 0 || i == numOfLines - 1) {
        var length = string.length;
        var empty = true;
        for (var i = 0; i < length; i++) {
          if (string[i] != ' ') {
            empty = false;
            break;
          }
        }

        if (empty) {
          continue;
        }
      }

      var count = 0;
      var length = string.length;
      for (var i = 0; i < indent && i < length; i++, count++) {
        if (string[i] != ' ') {
          break;
        }
      }

      strings.add(string.substring(count));
    }

    return strings;
  }

  static String splitCamelCase(String string) {
    if (string == null) {
      throw new ArgumentError('string: $string');
    }

    var length = string.length;
    var result = [];
    for (var i = 0; i < length; i++) {
      var s = string[i];
      if (s != s.toUpperCase()) {
        result.add(s);
      } else {
        result.add(' ');
        result.add(s.toLowerCase());
      }
    }

    return result.join();
  }

  static String toPrintable(String string) {
    var strings = [];
    for (var charCode in string.codeUnits) {
      strings.add(charToString(charCode, true));
    }

    return strings.join();
  }

  static String _charToAscii(int char, [bool printable = false]) {
    if (char == null || char < 0) {
      throw new ArgumentError('c: $char');
    }

    String string = null;
    switch (char) {
      case 9:
        if (printable) {
          string = '\\\\t';
        } else {
          string = '\\t';
        }

        break;
      case 10:
        if (printable) {
          string = '\\\\n';
        } else {
          string = '\\n';
        }

        break;
      case 13:
        if (printable) {
          string = '\\\\r';
        } else {
          string = '\\r';
        }

        break;
      case 34:
        string = '\\"';

        break;
      case 36:
        string = r'\$';

        break;
      case 39:
        string = '\\\'';

        break;
      case 92:
        string = '\\\\';

        break;
    }

    if (string == null && char >= 32 && char <= 126) {
      string = new String.fromCharCode(char);
    }

    return string;
  }

  static String _charToUnicode(int char) {
    if (char == null || char < 0 || char > 0xfffffffff) {
      throw new ArgumentError('c: $char');
    }

    var hex = char.toRadixString(16);
    var length = hex.length;
    var count = 0;
    if (char <= 0xffff) {
      count = 4;
    } else {
      count = 8;
    }

    for (var i = 0; i < count - length; i++) {
      hex = '0$hex';
    }

    return '\\u$hex';
  }
}
