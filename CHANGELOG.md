## 0.0.19

- Added full functional example of json parser
- Fixed bug in `CharacterClassExpressionGenerator`

## 0.0.18

- Fixed bug in `AndPredicateExpressionGenerator` (was missed character `;` in the template after refactoring) 

## 0.0.16

- Added initial support of the tokens for improving the errors messages and support of the upcomming AST generator.
- Was improved the basic ("expectation") error messages

## 0.0.15

- Added instruction optimizer in the interpreter parser
- Added the subordination of terminals (master, slave, master/slave). In some cases this can helps developers to writing (after the analysing) grammar better and, also, this helps for the generator to better optimize the grammar and helps to improve error messages.
- Breaking change: All methods, except the starting rules, are now private methods in all parsers. This is done for the interoperability of the generated parsers, better error messaging and performance improvement of parsing processes.

## 0.0.12

- Added new parser generator: interpreter parser
- Minor bug fixes

## 0.0.11

- Restored the previous performance (which has been decreased due to the support of the Unicode characters) through the addition of a pre-generated ASCII strings table.  

## 0.0.10

- Bug fixes for the full support of the Unicode characters

## 0.0.9

- Fixed bugs (the character code units are not an Unicode characters)
- Parser now supports the Unicode characters (uses 32-bit runes instead of 16-bit code units) 

## 0.0.8

- Medium improvements of performance by reducing restrictions on the prediction on optional rules without semantic actions

## 0.0.7

- Minor improvements in the expression generators (reduction of the `break` statements)

## 0.0.6

- Fixed bug in the original peg grammar in `COMMENT`

## 0.0.3

- Added an example of the usage of a simple `arithmetic` grammar
- Added an example of the usage of a simple `arithmetic` grammar

## 0.0.2

- Small fixes in `bin/peg.dart`

## 0.0.1

- Initial release

