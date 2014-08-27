part of peg.expressions;

class CharacterClassExpression extends Expression {
  SparseBoolList _ranges;

  CharacterClassExpression(List<List<int>> ranges) : super() {
    if (ranges == null) {
      throw new ArgumentError('ranges: $ranges');
    }

    if (ranges.isEmpty) {
      throw new ArgumentError('The list of ranges cannot be empty.');
    }

    _ranges = new SparseBoolList();
    var length = ranges.length;
    for (var i = 0; i < length; i++) {
      var range = ranges[i];
      var end = range[1];
      var start = range[0];
      if (start > end) {
        start = end;
        end = range[0];
      }

      _ranges.addGroup(new GroupedRangeList<bool>(start, end, true));
    }
  }

  SparseBoolList get ranges {
    return _ranges;
  }

  ExpressionTypes get type {
    return ExpressionTypes.CHARACTER_CLASS;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitCharacterClass(this);
  }

  String toString() {
    var strings = [];
    for (var range in _ranges.groups) {
      if (range.start == range.end) {
        // var char = Utils.charToString(range.start);
        var char = toPrintable(new String.fromCharCode(range.start));
        strings.add(_escape(char));
      } else {
        // var end = Utils.charToString(range.end);
        // var start = Utils.charToString(range.start);
        var end = toPrintable(new String.fromCharCode(range.end));
        var start = toPrintable(new String.fromCharCode(range.start));
        strings.add(_escape(start));
        strings.add('-');
        strings.add(_escape(end));
      }
    }

    return '[${strings.join()}]';
  }

  Object visitChildren(ExpressionVisitor visitor) {
    return this;
  }

  String _escape(String string) {
    switch (string) {
      case '[':
      case '-':
      case ']':
        return '\\$string';
      default:
        return string;
    }
  }
}
