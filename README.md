# peg

PEG (Parsing expression grammar) parsers generator.

Version: 0.0.54

## Instalation and Usage

### As transformer
1. In your pubspec.yaml file add the peg transformer:

```yaml
...
transformers:
  #other transformers
  - peg
...
```

you could also specify which files to include or exclude by mean of `$include` and `$exclude`:

```yaml
...
transformers:
  #other transformers
  - peg:
    $include: bin/arithmetic_parser.dart
    $exclude: bin/main.dart
...
```

2. Create a dart file which contains the parser, for example: [arithmetic_parser.dart](https://github.com/luisvt/peg_transformer_sample/blob/master/bin/arithmetic_parser.dart).
3. Create a peg file which contains the grammar, for example: [arithmetic_parser.peg](https://github.com/luisvt/peg_transformer_sample/blob/master/bin/arithmetic_parser.peg).

Both dart and peg files should have the same name to be picked by the transformer.

You can view the full example in https://github.com/luisvt/peg_transformer_sample

### As stand alone application

To install this program you could do it by mean of:

    pub global activate peg

To run the program you only need to do:

    pub global run peg general <file>.peg

or you can also add the `.pub-cache/bin` directory to your path and run it directly

    peg general <file>.peg

## Main advantages

- The generated parsers has no dependencies
- The generated parsers has high performance

The generated parsers intended for embedding into programs with the time-critical execution.

A short ["How to write a good PEG grammar"](https://github.com/mezoni/peg/tree/master/bin/how_to_write_a_good_peg_grammar.md) available.

## Features

- Elimination of direct left recursion (via `pegfmt` tool)
- Generation of detailed comments
- Grammar analytics
- Grammar reporting
- Grammar statistics
- High quality generated source code
- Lazy memoization (individually for each rule)
- Lookahead mapping tables
- Memoization
- Possibility to trace parsing 
- Powerful error and mistakes detection
- Printing grammar
- Symbols transitions (upcomming)
- Terminal and nonterminal symbol recognition

## Analysis of internal characteristic of grammar

Autodetection of the following production rule kinds:

- Sentences (nonterminals)
- Lexemes (tokens)
- Morhemes

In-depth analysis of the most important characteristics of the grammar allows generate the high quality, high performance PEG parsers.  
List of expression analyzers:

- Resolver of expected lexemes
- Resolver of expressions that are able not consume input
- Resolver of expression callers
- Resolver of expression hierarchy
- Resolver of expression length
- Resolver of expression level
- Resolver of expression that are matches eof
- Resolver of expression ownership
- Resolver of expression with actions
- Resolver of invocations
- Resolver of left expressions
- Resolver of optional expressions
- Resolver of production rule kinds
- Resolver of repetition expressions
- Resolver of right expressions
- Resolver of rule expressions
- Resolver of starting rules
- Resolver of start characters

Generators used such collected data very intensively for generating the highly optimized, high performance parsers.

Also for providing statistical information used the following grammar analyzers.

- Finder of choices with optional expression
- Finder of duplicate rules
- Finder of empty expression in predicates
- Finder of infinite loops
- Finder of left recursions
- Finder of nonterminals with lexemes
- Finder of optional expression in predicates
- Finder of starting rules
- Finder of unresolved rules

## Elimination of direct left recursion (experimental)

Grammar with direct left recursion can be rewritten with `pegfmt` tool.  
Suppored expressions:

```
# Original
A <- A a

# Rewritten
A <- a+

# Original
A <- A a / b

# Rewritten
A <- b A1
A1 <- a A1 / ''

# Original
A <- b / A a

# Rewritten
A <- b A1
A1 <- a A1 / ''
```

Limitation:

Expressions that starts with recursion should not contains actions in grammar before rewriting them.  
They (actions) should be added after rewriting grammar.

Eg.

```
# Semantic variable `$1` does not reffers to `A` after the rewriting.
# Before 
A <-
  A a { $$ = $1; # UNSAFE }
  / b { $$ = $1; # SAFE }

# After 
A <- b { $$ = $1; # SAFE } A1
A1 <- a A1 / ''
```

## Error detection

- Infinite loops
- Left recursive rules
- Optional expression in choices

## Trace

Trace information are useful for diagnose the problems.

Trace displayed in the following format:

column, line:state rule padding code position

Eg:

```
94, 8: F* OPEN    '-' Char { $$ = [$1, $3]; (2343)
94, 8:  > Literal '-' Char { $$ = [$1, $3]; (2343)

```

State:

Cache : Match : Direction

Cache:
 
- 'C' - Cache
- ' ' - Not cache

Match:
 
- 'F' - Failed
- ' ' - Succeed

Direction:

- '>' - Enter
- '<' - Leave
- 'S' - Skip (lookahead)

Examples:

- '  >' Enter
- '  <' Leave, success
- ' F<' Leave, failed
- 'C <' Leave, succeed, uses cached result 
- 'CF<' Leave, failed, uses cached result
- '  S' Skip (lookahead), succeed
- ' FS' Skip (lookahead), failed

## Grammar

```
Grammar <- LEADING_SPACES? GLOBALS? MEMBERS? Definition+ EOF

Definition <- IDENTIFIER LEFTARROW Expression

Expression <- Sequence (SLASH Sequence)*

Sequence <- Prefix+

Prefix <- (AND / NOT)? Suffix ACTION?

Suffix <- Primary (QUESTION / STAR / PLUS)?

Primary <- IDENTIFIER !LEFTARROW / OPEN Expression CLOSE / LITERAL / CLASS / DOT

ACTION <- '{' ACTION_BODY* '}' SPACING

AND <- '&' SPACING

CLASS <- '[' (!']' RANGE)* ']' SPACING

CLOSE <- ')' SPACING

DOT <- '.' SPACING

EOF <- !.

...

```

## Example

### Arithmetic grammar

```
%{
part of peg.example.arithmetic;

num _buildBinary(num first, List rest) {
  num builder(num result, List element) {
    var left = result;
    var right = element[1];
    var operator = element[0];
    switch(operator) {
      case "+":
        return left + right;
      case "-":
        return left - right;
      case "*":
        return left * right;
      case "/":
        return left / right;
      default:
        throw "Unsupported binary operation '$operator'";
    }
  };
  return _buildTree(first, rest, builder);
}

...
}%

### Sentences (nonterminals) ###

Start <-
  LEADING_SPACES? Expression EOF { $$ = $2; }

Expression <-
  AdditiveExpression

AdditiveExpression <-
  MultiplicativeExpression ((PLUS / MINUS) MultiplicativeExpression)* { $$ = _buildBinary($1, $2); }

MultiplicativeExpression <-
  UnaryExpression ((DIV / MUL) UnaryExpression)* { $$ = _buildBinary($1, $2); }

UnaryExpression <-
  PrimaryExpression
  / MINUS UnaryExpression { $$ = _unary($1, $2); }

PrimaryExpression <-
  CONSTANT
  / LPAREN Expression RPAREN { $$ = $2; }
  
...
```

Rest of the code ommited, please view [arithmetic.peg](./example/arithmetic.peg)

The generated code can be foudn at [arithmetic_parser.dart](./example/arithmetic_parser.dart).

The generated grammar statistics cand be found at [arithmetic.peg.stat.txt](https://github.com/luisvt/peg/blob/add_transformer/example/arithmetic.peg.stat.txt)

