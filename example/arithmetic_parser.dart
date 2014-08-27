// This code was generated by a tool.
// Processing tool available at https://github.com/mezoni/peg

part of peg.example.arithmetic;

num _binop(num left, num right, String op) {
  switch(op) {
    case "+":
      return left + right;
    case "-":
      return left - right;
    case "*":
      return left * right;
    case "/":
      return left / right;
    default:
      throw "Unsupported operation $op";  
  }
}
class ArithmeticParser {
  static const int EOF = -1;
  static final List<bool> _lookahead = _unmap([0x800013, 0x3ff01]);
  // '\t', '\n', '\r', ' '
  static final List<bool> _mapping0 = _unmap([0x800013]);
  bool success;
  List _cache;
  int _cachePos;
  List<int> _cacheRule;
  List<int> _cacheState;
  int _ch;
  int _column;
  List<String> _expected;
  int _failurePos;
  int _flag;
  int _inputLen;
  int _inputPos;
  int _line;
  int _testing;
  String _text;
  
  ArithmeticParser(String text) {
    if (text == null) {
      throw new ArgumentError('text: $text');
    }
    _text = text;  
    _inputLen = _text.length;
    if (_inputLen >= 0x3fffffe8 / 32) {
      throw new StateError('File size to big: $_inputLen');
    }  
    reset(0);    
  }
  
  int get column { 
    if (_column == -1) { 
      _calculatePos(_failurePos); 
    } 
    return _column;       
  } 
   
  int get line { 
    if (_line == -1) { 
      _calculatePos(_failurePos); 
    } 
    return _line;       
  } 
   
  dynamic parse_Atom() {
    // NONTERMINAL
    // Atom <- NUMBER / OPEN Sentence CLOSE
    var $$;  
    while (true) {
      // NUMBER
      if (_ch >= 48 && _ch <= 57 && _lookahead[_ch + -9]) {
        $$ = parse_NUMBER();
      }    
      else {
        success = false;  
        $$ = null;
        if (_inputPos > _testing) _failure(const ["NUMBER"]);  
      }
      if (success) break;
      var ch0 = _ch;
      var pos0 = _inputPos;
      while (true) {  
        // OPEN
        if (_ch == 40) $$ = parse_OPEN();
        else {  
         success = false;
         $$ = null;
         if (_inputPos > _testing) _failure(const ["("]);  
        }
        if (!success) break;
        var seq = new List(3);
        seq[0] = $$;
        // Sentence
        if (_ch >= 9 && _ch <= 57 && _lookahead[_ch + -9]) {
          $$ = parse_Sentence();
        }    
        else {
          success = false;  
          $$ = null;
          if (_inputPos > _testing) _failure(null);  
        }
        if (!success) break;
        seq[1] = $$;
        // CLOSE
        if (_ch == 41) $$ = parse_CLOSE();
        else {  
         success = false;
         $$ = null;
         if (_inputPos > _testing) _failure(const [")"]);  
        }
        if (!success) break;
        seq[2] = $$;
        $$ = seq;
        if (success) {    
          // OPEN
          final $1 = seq[0];
          // Sentence
          final $2 = seq[1];
          // CLOSE
          final $3 = seq[2];
          $$ = $2;    
        }
        break;  
      }
      if (!success) {
        _ch = ch0;
        _inputPos = pos0;
      }
      break;
    }
    return $$;
  }
  
  dynamic parse_CLOSE() {
    // TERMINAL
    // CLOSE <- ")" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // ")"
      $$ = _matchString(')', const [")"]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_DIV() {
    // TERMINAL
    // DIV <- "/" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // "/"
      $$ = _matchString('/', const ["/"]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // "/"
        final $1 = seq[0];
        // SPACES
        final $2 = seq[1];
        $$ = $1;    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_EOF() {
    // TERMINAL
    // EOF <- !.
    var $$;  
    // !.
    var ch0 = _ch;
    var pos0 = _inputPos;
    var testing0 = _testing; 
    _testing = _inputLen + 1;
    // .
    $$ = _matchAny();
    _ch = ch0;
    _inputPos = pos0; 
    _testing = testing0;
    $$ = null;
    success = !success;
    if (!success && _inputPos > _testing) _failure();
    return $$;
  }
  
  dynamic parse_Expr() {
    // NONTERMINAL
    // Expr <- Sentence EOF
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // Sentence
      if (_ch >= 9 && _ch <= 57 && _lookahead[_ch + -9]) {
        $$ = parse_Sentence();
      }    
      else {
        success = false;  
        $$ = null;
        if (_inputPos > _testing) _failure(null);  
      }
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // EOF
      $$ = parse_EOF();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // Sentence
        final $1 = seq[0];
        // EOF
        final $2 = seq[1];
        $$ = $1;    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_MINUS() {
    // TERMINAL
    // MINUS <- "-" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // "-"
      $$ = _matchString('-', const ["-"]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // "-"
        final $1 = seq[0];
        // SPACES
        final $2 = seq[1];
        $$ = $1;    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_MUL() {
    // TERMINAL
    // MUL <- "*" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // "*"
      $$ = _matchString('*', const ["*"]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // "*"
        final $1 = seq[0];
        // SPACES
        final $2 = seq[1];
        $$ = $1;    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_NUMBER() {
    // TERMINAL
    // NUMBER <- [0-9]+ SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // [0-9]+
      var testing0;
      for (var first = true, reps; ;) {  
        // [0-9]  
        $$ = _matchRange(48, 57);  
        if (success) {
         if (first) {      
            first = false;
            reps = [$$];
            testing0 = _testing;                  
          } else {
            reps.add($$);
          }
          _testing = _inputPos;   
        } else {
          success = !first;
          if (success) {      
            _testing = testing0;
            $$ = reps;      
          } else $$ = null;
          break;
        }  
      }
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // [0-9]+
        final $1 = seq[0];
        // SPACES
        final $2 = seq[1];
        $$ = int.parse($1.join());    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_OPEN() {
    // TERMINAL
    // OPEN <- "(" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // "("
      $$ = _matchString('(', const ["("]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_PLUS() {
    // TERMINAL
    // PLUS <- "+" SPACES
    var $$;  
    var ch0 = _ch;
    var pos0 = _inputPos;
    while (true) {  
      // "+"
      $$ = _matchString('+', const ["+"]);
      if (!success) break;
      var seq = new List(2);
      seq[0] = $$;
      // SPACES
      $$ = parse_SPACES();
      if (!success) break;
      seq[1] = $$;
      $$ = seq;
      if (success) {    
        // "+"
        final $1 = seq[0];
        // SPACES
        final $2 = seq[1];
        $$ = $1;    
      }
      break;  
    }
    if (!success) {
      _ch = ch0;
      _inputPos = pos0;
    }
    return $$;
  }
  
  dynamic parse_SPACES() {
    // TERMINAL
    // SPACES <- WS*
    var $$;  
    // WS*
    var testing0 = _testing; 
    for (var reps = []; ; ) {
      _testing = _inputPos;
      // WS
      if (_ch >= 9 && _ch <= 32 && _lookahead[_ch + -9]) {
        $$ = parse_WS();
      }    
      else {
        success = false;  
        $$ = null;
        if (_inputPos > _testing) _failure(const ["WS"]);  
      }
      if (success) {  
        reps.add($$);
      } else {
        success = true;
        _testing = testing0;
        $$ = reps;
        break; 
      }
    }
    return $$;
  }
  
  dynamic parse_Sentence() {
    // NONTERMINAL
    // Sentence <- SPACES Term (PLUS / MINUS) Sentence / Term
    var $$;  
    while (true) {
      var ch0 = _ch;
      var pos0 = _inputPos;
      while (true) {  
        // SPACES
        $$ = parse_SPACES();
        if (!success) break;
        var seq = new List(4);
        seq[0] = $$;
        // Term
        if (_ch >= 40 && _ch <= 57 && _lookahead[_ch + -9]) {
          $$ = parse_Term();
        }    
        else {
          success = false;  
          $$ = null;
          if (_inputPos > _testing) _failure(null);  
        }
        if (!success) break;
        seq[1] = $$;
        while (true) {
          // PLUS
          if (_ch == 43) $$ = parse_PLUS();
          else {  
           success = false;
           $$ = null;
           if (_inputPos > _testing) _failure(const ["+"]);  
          }
          if (success) break;
          // MINUS
          if (_ch == 45) $$ = parse_MINUS();
          else {  
           success = false;
           $$ = null;
           if (_inputPos > _testing) _failure(const ["-"]);  
          }
          break;
        }
        if (!success) break;
        seq[2] = $$;
        // Sentence
        if (_ch >= 9 && _ch <= 57 && _lookahead[_ch + -9]) {
          $$ = parse_Sentence();
        }    
        else {
          success = false;  
          $$ = null;
          if (_inputPos > _testing) _failure(null);  
        }
        if (!success) break;
        seq[3] = $$;
        $$ = seq;
        if (success) {    
          // SPACES
          final $1 = seq[0];
          // Term
          final $2 = seq[1];
          // PLUS / MINUS
          final $3 = seq[2];
          // Sentence
          final $4 = seq[3];
          $$ = _binop($2, $4, $3);    
        }
        break;  
      }
      if (!success) {
        _ch = ch0;
        _inputPos = pos0;
      }
      if (success) break;
      // Term
      if (_ch >= 40 && _ch <= 57 && _lookahead[_ch + -9]) {
        $$ = parse_Term();
      }    
      else {
        success = false;  
        $$ = null;
        if (_inputPos > _testing) _failure(null);  
      }
      break;
    }
    return $$;
  }
  
  dynamic parse_Term() {
    // NONTERMINAL
    // Term <- Atom (MUL / DIV) Term / Atom
    var $$;  
    while (true) {
      var ch0 = _ch;
      var pos0 = _inputPos;
      while (true) {  
        // Atom
        if (_ch >= 40 && _ch <= 57 && _lookahead[_ch + -9]) {
          $$ = parse_Atom();
        }    
        else {
          success = false;  
          $$ = null;
          if (_inputPos > _testing) _failure(null);  
        }
        if (!success) break;
        var seq = new List(3);
        seq[0] = $$;
        while (true) {
          // MUL
          if (_ch == 42) $$ = parse_MUL();
          else {  
           success = false;
           $$ = null;
           if (_inputPos > _testing) _failure(const ["*"]);  
          }
          if (success) break;
          // DIV
          if (_ch == 47) $$ = parse_DIV();
          else {  
           success = false;
           $$ = null;
           if (_inputPos > _testing) _failure(const ["/"]);  
          }
          break;
        }
        if (!success) break;
        seq[1] = $$;
        // Term
        if (_ch >= 40 && _ch <= 57 && _lookahead[_ch + -9]) {
          $$ = parse_Term();
        }    
        else {
          success = false;  
          $$ = null;
          if (_inputPos > _testing) _failure(null);  
        }
        if (!success) break;
        seq[2] = $$;
        $$ = seq;
        if (success) {    
          // Atom
          final $1 = seq[0];
          // MUL / DIV
          final $2 = seq[1];
          // Term
          final $3 = seq[2];
          $$ = _binop($1, $3, $2);    
        }
        break;  
      }
      if (!success) {
        _ch = ch0;
        _inputPos = pos0;
      }
      if (success) break;
      // Atom
      if (_ch >= 40 && _ch <= 57 && _lookahead[_ch + -9]) {
        $$ = parse_Atom();
      }    
      else {
        success = false;  
        $$ = null;
        if (_inputPos > _testing) _failure(null);  
      }
      break;
    }
    return $$;
  }
  
  dynamic parse_WS() {
    // TERMINAL
    // WS <- [\t-\n\r ] / "\r\n"
    var $$;  
    while (true) {
      // [\t-\n\r ]
      $$ = _matchMapping(9, 32, _mapping0);
      if (success) break;
      // "\r\n"
      $$ = _matchString('\r\n', const ["\\r\\n"]);
      break;
    }
    return $$;
  }
  
  void _addToCache(dynamic result, int start, int id) {  
    var cached = _cache[start];
    if (cached == null) {
      _cacheRule[start] = id;
      _cache[start] = [result, _inputPos, success];
    } else {    
      var slot = start >> 5;
      var r1 = (slot << 5) & 0x3fffffff;    
      var mask = 1 << (start - r1);    
      if ((_cacheState[slot] & mask) == 0) {
        _cacheState[slot] |= mask;   
        cached = [new List.filled(2, 0), new Map<int, List>()];
        _cache[start] = cached;                                      
      }
      slot = id >> 5;
      r1 = (slot << 5) & 0x3fffffff;    
      mask = 1 << (id - r1);    
      cached[0][slot] |= mask;
      cached[1][id] = [result, _inputPos, success];      
    }
    if (_cachePos < start) {
      _cachePos = start;
    }    
  }
  
  void _calculatePos(int pos) {
    if (pos == null || pos < 0 || pos > _inputLen) {
      return;
    }
    _line = 1;
    _column = 1;
    for (var i = 0; i < _inputLen && i < pos; i++) {
      var c = _text.codeUnitAt(i);
      if (c == 13) {
        _line++;
        _column = 1;
        if (i + 1 < _inputLen && _text.codeUnitAt(i + 1) == 10) {
          i++;
        }
      } else if (c == 10) {
        _line++;
        _column = 1;
      } else {
        _column++;
      }
    }
  }
  
  void _failure([List<String> expected]) {  
    if (_failurePos > _inputPos) {
      return;
    }
    if (_inputPos > _failurePos) {    
      _expected = [];
     _failurePos = _inputPos;
    }
    if (expected != null) {
      _expected.addAll(expected);
    }  
  }
  
  List _flatten(dynamic value) {
    if (value is List) {
      var result = [];
      var length = value.length;
      for (var i = 0; i < length; i++) {
        var element = value[i];
        if (element is Iterable) {
          result.addAll(_flatten(element));
        } else {
          result.add(element);
        }
      }
      return result;
    } else if (value is Iterable) {
      var result = [];
      for (var element in value) {
        if (element is! List) {
          result.add(element);
        } else {
          result.addAll(_flatten(element));
        }
      }
    }
    return [value];
  }
  
  dynamic _getFromCache(int id) {  
    var result = _cache[_inputPos];
    if (result == null) {
      return null;
    }    
    var slot = _inputPos >> 5;
    var r1 = (slot << 5) & 0x3fffffff;  
    var mask = 1 << (_inputPos - r1);
    if ((_cacheState[slot] & mask) == 0) {
      if (_cacheRule[_inputPos] == id) {      
        _inputPos = result[1];
        success = result[2];      
        if (_inputPos < _inputLen) {
          _ch = _text.codeUnitAt(_inputPos);
        } else {
          _ch = EOF;
        }      
        return result;
      } else {
        return null;
      }    
    }
    slot = id >> 5;
    r1 = (slot << 5) & 0x3fffffff;  
    mask = 1 << (id - r1);
    if ((result[0][slot] & mask) == 0) {
      return null;
    }
    var data = result[1][id];  
    _inputPos = data[1];
    success = data[2];
    if (_inputPos < _inputLen) {
      _ch = _text.codeUnitAt(_inputPos);
    } else {
      _ch = EOF;
    }   
    return data;  
  }
  
  String _matchAny() {
    success = _inputPos < _inputLen;
    if (success) {
      var result = _text[_inputPos++];
      if (_inputPos < _inputLen) {
        _ch = _text.codeUnitAt(_inputPos);
      } else {
        _ch = EOF;
      }    
      return result;
    }
    if (_inputPos > _testing) {
      _failure();
    }  
    return null;  
  }
  
  String _matchChar(int ch, List<String> expected) {
    success = _ch == ch;
    if (success) {
      var result = _text[_inputPos++];
      if (_inputPos < _inputLen) {
        _ch = _text.codeUnitAt(_inputPos);
      } else {
        _ch = EOF;
      }    
      return result;
    }
    if (_inputPos > _testing) {
      _failure(expected);
    }  
    return null;  
  }
  
  String _matchMapping(int start, int end, List<bool> mapping) {
    success = _ch >= start && _ch <= end;
    if (success) {    
      if(mapping[_ch - start]) {
        var result = _text[_inputPos++];
        if (_inputPos < _inputLen) {
          _ch = _text.codeUnitAt(_inputPos);
        } else {
          _ch = EOF;
        }      
        return result;
      }
      success = false;
    }
    if (_inputPos > _testing) {
       _failure();
    }  
    return null;  
  }
  
  String _matchRange(int start, int end) {
    success = _ch >= start && _ch <= end;
    if (success) { 
      var result = _text[_inputPos++];
      if (_inputPos < _inputLen) {
        _ch = _text.codeUnitAt(_inputPos);
      } else {
        _ch = EOF;
      }  
      return result;
    }
    if (_inputPos > _testing) {
      _failure();
    }  
    return null;  
  }
  
  String _matchRanges(List<int> ranges) {
    var length = ranges.length;
    for (var i = 0; i < length; i += 2) {
      if (_ch <= ranges[i + 1]) {
        if (_ch >= ranges[i]) {
          var result = _text[_inputPos++];
          if (_inputPos < _inputLen) {
            _ch = _text.codeUnitAt(_inputPos);
          } else {
             _ch = EOF;
          }
          success = true;    
          return result;
        }      
      } else break;  
    }
    if (_inputPos > _testing) {
      _failure();
    }
    success = false;  
    return null;  
  }
  
  String _matchString(String string, List<String> expected) {
    success = _text.startsWith(string, _inputPos);
    if (success) {
      _inputPos += string.length;      
      if (_inputPos < _inputLen) {
        _ch = _text.codeUnitAt(_inputPos);
      } else {
        _ch = EOF;
      }    
      return string;      
    } 
    if (_inputPos > _testing) {
      _failure(expected);
    }  
    return null; 
  }
  
  void _nextChar([int count = 1]) {  
    success = true;
    _inputPos += count; 
    if (_inputPos < _inputLen) {
      _ch = _text.codeUnitAt(_inputPos);
    } else {
      _ch = EOF;
    }    
  }
  
  bool _testChar(int c, int flag) {
    if (c < 0 || c > 127) {
      return false;
    }    
    int slot = (c & 0xff) >> 6;  
    int mask = 1 << c - ((slot << 6) & 0x3fffffff);  
    if ((flag & mask) != 0) {    
      return true;
    }
    return false;           
  }
  
  bool _testInput(int flag) {
    if (_inputPos >= _inputLen) {
      return false;
    }
    var c = _text.codeUnitAt(_inputPos);
    if (c < 0 || c > 127) {
      return false;
    }    
    int slot = (c & 0xff) >> 6;  
    int mask = 1 << c - ((slot << 6) & 0x3fffffff);  
    if ((flag & mask) != 0) {    
      return true;
    }
    return false;           
  }
  
  static List<bool> _unmap(List<int> mapping) {
    var length = mapping.length;
    var result = new List<bool>(length * 31);
    var offset = 0;
    for (var i = 0; i < length; i++) {
      var v = mapping[i];
      for (var j = 0; j < 31; j++) {
        result[offset++] = v & (1 << j) == 0 ? false : true;
      }
    }
    return result;
  }
  
  List<String> get expected {
    var set = new Set<String>();  
    set.addAll(_expected);
    if (set.contains(null)) {
      set.clear();
    }  
    var result = set.toList();
    result.sort(); 
    return result;        
  }
  
  void reset(int pos) {
    if (pos == null) {
      throw new ArgumentError('pos: $pos');
    }
    if (pos < 0 || pos > _inputLen) {
      throw new RangeError('pos');
    }
    success = true;    
    _cache = new List(_inputLen + 1);
    _cachePos = -1;
    _cacheRule = new List(_inputLen + 1);
    _cacheState = new List.filled(((_inputLen + 1) >> 5) + 1, 0);
    _ch = EOF;  
    _column = -1; 
    _expected = [];
    _failurePos = -1;
    _flag = 0;  
    _inputPos = pos;
    _line = -1;    
    _testing = -1;
    if (pos < _inputLen) {
      _ch = _text.codeUnitAt(pos);
    }    
  }
  
  String get unexpected {
    if (_failurePos < 0 || _failurePos >= _inputLen) {
      return '';    
    }
    return _text[_failurePos];      
  }
  
}

