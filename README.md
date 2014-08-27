#peg
==========

PEG (Parsing expression grammar) parsers generator.

Version: 0.0.2

Status: Experimental

**Features:**

- Generation of detailed comments
- Generated parsers has no dependencies
- Grammar analytics
- Grammar reporting
- Grammar statistics
- High quality generated source code
- Lookahead mapping tables
- Memoization
- Possibility to trace parsing
- Powerful error and mistakes detection
- Printing grammar
- Terminal and nonterminal symbol recognition

In the future, will be added generator of an alternative PEG (a state machine based) parser.

**Error detection**

- Infinite loops
- Left recursive rules
- Optional expression in choices

**Grammar**

```
Grammar <- SPACING Globals? Members? Definition+ EOF

Globals <- "%{" GlobalsBody* "}%" SPACING

GlobalsBody <- !"}%" .

Members <- "{" ActionBody* "}" SPACING

Action <- "{" ActionBody* "}" SPACING

ActionBody <- Action / !"}" .

Definition <- IDENTIFIER LEFTARROW Expression

Expression <- Sequence (SLASH Sequence)*

Sequence <- Prefix+

Prefix <- (AND / NOT)? Suffix Action?

Suffix <- Primary (QUESTION / STAR / PLUS)?

Primary <- IDENTIFIER !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT

Literal <- "\'" (!"\'" Char)* ['] SPACING / "\"" (!"\"" Char)* ["] SPACING

Class <- "[" (!"]" Range)* "]" SPACING

Range <- Char "-" Char / Char

Char <- "\\" ["'\-\[-\]nrt] / HEX_NUMBER / !"\\" .

EOF <- !.

IDENTIFIER <- IDENT_START IDENT_CONT* SPACING

IDENT_START <- [A-Z_a-z]

IDENT_CONT <- IDENT_START / [0-9]

LEFTARROW <- "<-" SPACING

SLASH <- "/" SPACING

AND <- "&" SPACING

NOT <- "!" SPACING

QUESTION <- "?" SPACING

STAR <- "*" SPACING

PLUS <- "+" SPACING

OPEN <- "(" SPACING

CLOSE <- ")" SPACING

DOT <- "." SPACING

HEX_NUMBER <- "\\u" [0-9A-Fa-f]+

SPACING <- (SPACE / COMMENT)*

COMMENT <- "#" (!EOL .)* EOL

SPACE <- " " / "\t" / EOL

EOL <- "\r\n" / "\n" / "\r"

```
