*&---------------------------------------------------------------------*
*& Report z_built_in_functions
*&---------------------------------------------------------------------*
*& Useful examples of built-in functions relevant for ABAP 7.50
*& Complete list of functions:
*& https://help.sap.com/doc/abapdocu_750_index_htm/7.50/en-US/index.htm?file=abenbuilt_in_functions_overview.htm
*&---------------------------------------------------------------------*
report z_built_in_functions.

*** String functions
* String template. Same as data lv_string type string
data(lv_string)   = | Can we really know everything?  |.

* Text string literal. Same as lv_string
data(lv_string_2) = ` Can we really know everything?  `.

* Text field literal
data(lv_char_str) = ' Can we really know everything?  '.

write: /, strlen( lv_string ).      " 33
write: /, strlen( lv_string_2 ).    " 33

* Trailing blanks are ignored for fixed length objects
write: /, strlen( lv_char_str ).    " 31

* Trailing blanks are ignored for both fixed length objects and strings
write: /,  numofchar( lv_string ) .     " 31
write: /,  numofchar( lv_char_str ) .   " 31
write: /,  numofchar( lv_string_2 ) .   " 31

write: /,  dbmaxlen( lv_string ) .                          " 536870912

** Condense
write: /, condense( val = '  ABAP   PABA  ' ). " 'ABAP PABA'
write: /, condense( val = 'XXX  ABAP XXX PABA  XXX' del = 'X' ). " ' ABAP XXX PABA '
write: /, condense( val = 'XXX  ABAP XXX PABA  XXX' from = 'X' to = 'Y' ). " 'Y  ABAP Y PABA  Y'
write: /, condense( val = 'XXX  ABAP XXX PABA  XXX' del = 'X' from = 'X' to = 'Y' ). " '  ABAP Y PABA  '
write: /, condense( val = 'XXX  ABAP XXX PABA  XXX' from = 'X' ). " '   ABAP   PABA  '
write: /, condense( val = 'XXX  ABAP XXX PABA  XXX' to = 'Z' ). " 'XXXZABAPZXXXZPABAZXXX'

** Replace
data(lv_val) = |Let eat bee|.
data(lv_new) = replace( val = lv_val with = 'drink' off = 4 len = 3 ).
write: /, lv_new. " 'Let drink bee'

"If only off is specified or if the value 0 is specified for len, replace works like insert.
lv_new = replace( val = lv_new with = 'r' off = strlen( lv_new )  ).
write: /, lv_new. "Let drink beer

write: /, replace( val = lv_val with = 'catch' sub = 'eat' ). "Let catch bee

write: /, replace( val = 'password = "Qwerty123!"' with = '*********' regex = '\"\C+\"' ). " password = *********

** Case functions
write: /, to_upper( val = 'word' ). "WORD
write: /, to_lower( val = 'WORD' ). "word
write: /, to_mixed( val = 'hello_world' ). "helloWorld
write: /, from_mixed( val = 'helloWorld' ). "HELLO_WORLD
write: /, from_mixed( val = 'helloWorld' case = 'x' ). "hello_world

*** Table functions
types: begin of lty_structure,
         name  type string,
         value type numc10,
       end of lty_structure,

       lty_tab type standard table of lty_structure with key name.

data(lt_prices) = value lty_tab( ( name = 'beer'    value = '120' )
                                 ( name = 'vine'    value = '450' )
                                 ( name = 'whiskey' value = '3200' )
                                 ( name = 'vodka'   value = '250' ) ).

write: /, lines( lt_prices ). "4
if line_exists( lt_prices[ name = 'whiskey' ] ).
  write: /, 'True'.
  data(lv_index) = line_index( lt_prices[ name = 'whiskey' ] ).
  write: /, 'Index: ', lv_index.
endif.

lv_index = line_index( lt_prices[ name = 'water' ] ).
write: /, lv_index. " 0

*** Logic fuctions

* matches
if matches( val = 'Give me 100 dollars' regex = '\d{3}' ). "Not matches
  write: /, 'Matches!'.
else.
  write: /, 'Not matches...'.
endif.

if matches( val = '100' regex = '\d{3}' ). "Matches!
  write: /, 'Matches!'.
else.
  write: /, 'Not matches...'.
endif.

*contains
if contains( val = 'Give me 100 dollars' regex = '\d{3}' ). "Contains!
  write: /, 'Contains!'.
else.
  write: /, 'Not contains...'.
endif.

if contains( val = 'Give me 100 dollars' start = 'Give' ). "Contains!
  write: /, 'Contains!'.
else.
  write: /, 'Not contains...'.
endif.

if contains( val = 'Give me 100 dollars' end = 'euros' ). "Not contains...
  write: /, 'Contains!'.
else.
  write: /, 'Not contains...'.
endif.

*boolc - returns string type value X or " "
write: /,  boolc( 2 * 2 = 4 ) . " 'X'
write: /,  boolc( 1 = 2 ) . " ' '

*xsdbool - same as boolc, but returns char(1) type value
write: /,  xsdbool( 2 * 2 = 4 ) . " 'X'
write: /,  xsdbool( 1 = 2 ) . " ' '

*** Numeric functions
data: lv_pi(3)       type p decimals 4 value '3.1416',
      lv_minus_pi(3) type p decimals 4.

*abs,
write: /, abs( lv_pi ). " 3.1416
lv_minus_pi = -1  * lv_pi.
write: /, abs( lv_minus_pi ). " 3.1416

*ceil,
write: /, ceil( lv_pi ). " 4,0000

*floor,
write: /, floor( lv_pi ). " 3,0000

*trunc
write: /, trunc( lv_pi ). " 3,0000

*round
write: /, | { round( val = lv_pi prec = 3 ) }|. " 3,14
write: /, | { round( val = lv_pi dec  = 3 ) }|. " 3,142