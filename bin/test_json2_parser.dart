import 'dart:io';
import 'json2_parser.dart';

void main() {
  var filename = 'test.json';
  var file = new File(filename);
  if(!file.existsSync()) {
    print('File not found: $filename');
    exit(-1);
  }

  var text2 = file.readAsStringSync();
  var parser = new Json2Parser(text2);
  var sw = new Stopwatch();
  sw.start();
  var result = parser.parse_jsonText();
  sw.stop();
  print('${sw.elapsedMilliseconds}');

  sw.reset();
  parser.reset(0);
  sw.start();
  result = parser.parse_jsonText();
  sw.stop();
  print('${sw.elapsedMilliseconds}');

  if(result == null) {
    var column = parser.column;
    var line = parser.line;
    var expected = parser.expected;
    var unexpected = parser.unexpected;
    if(!expected.isEmpty) {
      var str = expected.join('\', \'');
      stdout.writeln('Parser error at ($line, $column): expected \'$str\' but found \'$unexpected\'');
    } else {
      if(!unexpected.isEmpty) {
        stdout.writeln('Parser error at ($line, $column): unexpected "$unexpected"');
      } else {
        stdout.writeln('Parser error at ($line, $column): unexpected end of file');
      }
    }

    exit(-1);
  }
}

var text =
'''
class G { 
  foo() {
    throw 1;
  }
}
''';