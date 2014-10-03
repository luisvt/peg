part of peg.grammar.expressions;

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
        strings.add(_escape(range.start));
      } else {
        strings.add(_escape(range.start));
        strings.add('-');
        strings.add(_escape(range.end));
      }
    }

    return '[${strings.join()}]';
  }

  Object visitChildren(ExpressionVisitor visitor) {
    return this;
  }

  String _escape(int character) {
    switch (character) {
      case 9:
        return '\\t';
      case 10:
        return '\\n';
      case 13:
        return '\\r';
    }

    if (character < 32 || character >= 127) {
      return "\\u${character.toRadixString(16)}";
    }

    switch (character) {
      case 45:
        return '\\-';
      case 91:
        return '\\[';
      case 92:
        return '\\\\';
      case 93:
        return '\\]';
    }

    return new String.fromCharCode(character);
  }
}
