part of peg.trace;

class Trace {
  static String getTraceState({bool cached: false, bool enter: true, bool skip: false, bool success: true}) {
    var s0 = cached ? "C" : " ";
    var s1 = success ? " " : 'F';
    var s2 = enter ? ">" : '<';
    s2 = skip ? "S" : s2;
    return "$s0$s1$s2";
  }
}
