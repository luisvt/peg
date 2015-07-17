# How to write a good PEG grammar?

## Terminology

The following production rule kinds can be automatically recognized by the parser generator:

- Sentences (nonterminals)
- Lexemes (tokens)
- Morphemes

Sentences (nonterminals):

- Callers: sentences (nonterminals), none
- Callees: sentences (nonterminals), lexemes (tokens)

Lexemes (tokens):

- Callers: sentences (nonterminals)
- Callees: morhemes

Morphemes:

- Callers: lexemes (tokens)
- Callees: morphemes, none

Good grammar is a grammar with correctly logically specified rules by their kinds.

## Recommendations

Good grammar allows the parser generator generate high performance parsers with good error messages.

Main rule of the most of the grammars:

- White spaces that your grammar uses in lexemes (tokens) should be recogmized as `morphemes`

If you grammar required using the `white spaces` directly in sentences (nonterminals), in this case you should write a separate rule for that purpose and use in sentences (nonterminals) only this rule.  
In this case, your grammar is considered logically correct.

Eg.

```
### Sentences (nonterminals) ###

start <-
  leading_spaces? declarations* eof

### Lexemes (tokens) ###

declarations <-
  number
  / ident

eof <-
  !.

leading_spaces <-
  spaces

### Morphemes ###

ident <-
  [A-Za-z] spaces

number <-
  [0-9] spaces

spaces <-
  ('\r\n' / [\t-\n\r ])*
```

And short report about the grammar

```
--------------------------------
Sentences (nonterminals):
  start
--------------------------------
Lexemes (tokens):
  declarations
  eof
  leading_spaces
--------------------------------
Morphemes:
  ident
  number
  spaces

```

Don't use `lexemes` in the tokens.  
When lexeme used other lexeme in their expression in this case the first lexeme considered as a sentence (nonterminal) instead of will be recognized as a lexeme (token).

Parser generator is able automatically recognize all kinds of rules if your grammar follow the above recommendations.

Very often the main problem only in the incorrect usage of the `white spaces`, `eof` and `eol` production rules.

Check them first!

If you have some troubles you can use statistics.

`peg stat --detail high grammar.peg`
