## 0.0.34

- Fixed bug in `StartCharactersResolver` 

## 0.0.33

- Added the binary search algorithm to method `getState` (determiner of the current state through the symbol transitions) in a generated `general` parsers. This feature improves the performance of the parsing of a complex grammar with a wide range of used input symbols

## 0.0.32

- Fixed bug in `OrderedChoiceExpressionGenerator` associated with incomplete coverage of range in symbol transitions

## 0.0.31

- Added grammar formatter utility `pegfmt.dart`
- Fixed bug in `_text() => String`

## 0.0.30

- Minor (speed up) changes in `json` grammar. From now the generated `json_parser` is a fast enough parser, given the fact that it is the generated PEG parser
- Minor (speed up) changes in `peg` grammar
- Minor (speed up) changes in expression resolvers

## 0.0.29

- Fixed bug in `LeftRecursionsFinder`

## 0.0.28

- Improved implementation of the symbol transition code generation

## 0.0.27

- Added initial support and implementation of the symbol transitions. The complex grammar should be parsed faster  

## 0.0.25

- Fixed a very small bug in the creation of the parser error
- Improved statistic information in the command `stat`

## 0.0.24

- Added recognition and error reporting of the `malformed tokens` (eg, number's)
- Added recognition and error reporting of the `unterminated tokens` (eg, string's)
- Added statistic information in the command `stat` about the `expected lexemes` in the nonterminals. Can be used for visual analysing of the quality of the developed grammar and the proposed error messages on the failures
- Fixed bugs in the grammar `example/json.peg` (thanks to the newly added recognition and error reporting of the `malformed tokens`) 

## 0.0.23

- Added function `errors() => List<ParserError>`
- Breaking change. Removed 'line' and 'column' properties.
- Refactored the entire codebase for easiest implementing several kinds of parser generators
- Started the improvements of the error messages. From now all the parser errors are an instances of `XxxParserError` type.

## 0.0.21

- Fixed bug in `_matchString`
- Removed convention on a naming terminals and nonterminals in favor to the possibility of analyzing (and control) the grammar on the subject of the auto generated representation names of terminals

## 0.0.20

- Added statistics about an auto generated names of the terminals (they used in the error messages). This feature useful for correcting grammar for better perception of the components of the grammar
- Fixed bugs in `ExpectationResolver` (error messages about the expected lexemes are now more correct)

## 0.0.19

- Added full functional example of json parser
- Fixed bug in `CharacterClassExpressionGenerator`

## 0.0.18

- Fixed bug in `AndPredicateExpressionGenerator` (was missed character `;` in the template after refactoring) 

## 0.0.16

- Added initial support of the tokens for improving the errors messages and support of the upcomming AST generator
- Was improved the basic ("expectation") error messages

## 0.0.15

- Added instruction optimizer in the interpreter parser
- Added the subordination of terminals (master, slave, master/slave). In some cases this can helps developers to writing (after the analysing) grammar better and, also, this helps for the generator to better optimize the grammar and helps to improve error messages
- Breaking change: All methods, except the starting rules, are now private methods in all parsers. This is done for the interoperability of the generated parsers, better error messaging and performance improvement of parsing processes

## 0.0.12

- Added new parser generator: interpreter parser
- Minor bug fixes

## 0.0.11

- Restored the previous performance (which has been decreased due to the support of the Unicode characters) through the addition of a pre-generated ASCII strings table  

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

