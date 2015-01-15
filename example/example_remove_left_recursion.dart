import "dart:convert";

/**
 * A <- b / A a
 *
 * ==========
 * b
 * A1 a1 a2 aN
 * A2 a1 a2 aN
 * AN a1 a2 aN
 * ==========
 */
String auto_way = '''
cast_expression
multiplicative_expression MUL DIV MOD
additive_expression ADD SUB
''';

/**
 * A <- b / A a
 *
 * ==========
 * A1 # b # a
 * A2 # b # a
 * AN # b # a
 * ==========
 */
String manual_way = '''
multiplicative_expression # cast_expression # MUL cast-expression  
multiplicative_expression # cast_expression # DIV cast-expression
multiplicative_expression # cast_expression # MOD cast-expression
additive_expression # multiplicative_expression # ADD additive_expression
additive_expression # multiplicative_expression # SUB additive_expression
''';

void main() {
  example1();
  example2();
}

void example1() {
  print("=========================");
  print("Manual way");
  var rules = <String, Rule>{};
  var lines = new LineSplitter().convert(manual_way);
  for (var line in lines) {
    var parts = line.split("#");
    if (parts.length != 3) {
      throw new StateError("Illegal line: $line");
    }

    var key = parts[0].trim();
    var rule = rules[key];
    if (rule == null) {
      rule = new Rule(key);
      rules[key] = rule;
    }

    var b = parts[1].trim();
    var a = parts[2].trim();
    var tuple = new Expr(a: a, b: b);
    rule.tuples.add(tuple);
  }

  print(generateRules(rules));
}

void example2() {
  print("=========================");
  print("Auto way");
  var rules = <String, Rule>{};
  var lines = new LineSplitter().convert(manual_way);
  var length = lines.length;
  for (var i = 1; i < length; i++) {
    var line = lines[i].trim();
    var parts = line.split(" ");
    parts = parts.where((e) => !e.isEmpty).toList();
    if (parts.length < 2) {
      throw new StateError("Illegal line: $line");
    }

    var name = parts.removeAt(0).trim();
    var rule = new Rule(name);
    var a = lines[i - 1].trim();
    for (var part in parts) {

    }
  }

  print(generateRules(rules));
}

String generateRules(Map<String, Rule> rules) {
  var sb = new StringBuffer();
  for (var rule in rules.values) {
    var A = "${rule.name}";
    var A1 = "${A}1";
    sb.write(A);
    sb.write(" <-");
    sb.writeln();
    var tuples = rule.tuples;
    var length = tuples.length;
    var b_used = new Set<String>();
    for (var i = 0; i < length; i++) {
      var tuple = tuples[i];
      var b = tuple.b;
      if (b_used.contains(b)) {
        continue;
      }

      if (i == 0) {
        sb.write("  ");
      } else {
        sb.write("  / ");
      }

      sb.write(b);
      sb.write(" ");
      sb.write(A1);
      sb.writeln();
      b_used.add(b);
    }

    sb.writeln();
    sb.write(A1);
    sb.write(" <-");
    sb.writeln();
    for (var i = 0; i < length; i++) {
      var tuple = tuples[i];
      var a = tuple.a;
      if (i == 0) {
        sb.write("  ");
      } else {
        sb.write("  / ");
      }

      sb.write("(");
      sb.write(a);
      sb.write(" ");
      sb.write(A1);
      sb.write(")?");
      sb.writeln();
    }

    sb.writeln();
  }

  return sb.toString();
}

class Rule {
  List<Expr> tuples = <Expr>[];

  String name;

  Rule(this.name);
}

class Expr {
  String a;

  String b;

  Expr({this.a, this.b});
}
