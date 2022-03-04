*&---------------------------------------------------------------------*
*& Report z_general_syntax
*&---------------------------------------------------------------------*
*& Examples relevant for ABAP 7.50
*&---------------------------------------------------------------------*
report z_general_syntax.

*value - structure
data:
  begin of ls_animal,
    teeth type i value 24,
    tail  type abap_bool  value abap_true,
    hair  type string value 'long',
  end of ls_animal,
  ls_animal_1 like ls_animal,
  ls_animal_2 like ls_animal.

ls_animal_1 = value #( teeth = ls_animal-teeth
                       tail  = abap_false
                       hair  = ls_animal-hair  ).

ls_animal_2 = value #( teeth = 40
                       tail  = ls_animal-tail
                       hair  = 'very long'  ).

data(ls_animal_3) = value #( base ls_animal_2 tail = abap_false ).

data:
  begin of ls_new_animal,
    teeth     type i,
    tail      type abap_bool,
    hair      type string,
    dangerous type abap_bool,
  end of ls_new_animal.

ls_new_animal = value #( base corresponding #( ls_animal_1 ) dangerous = abap_true ).
cl_demo_output=>display_data( ls_new_animal ).

*switch
data(lv_digit) = 5.

data(lv_digit_name) = switch text15( lv_digit
    when 1 then 'one'
    when 2   then 'two'
    when 3   then 'three'
    when 4   then 'four'
    when 5   then 'five'
    when 6   then 'six'
    when 7   then 'seven'
    when 8   then 'eight'
    when 9   then 'nine'
    else 'not a digit')."

write |{ lv_digit } is { lv_digit_name }|. "5 is five

*cond
data(lv_digit_weight) = cond text30(
    when lv_digit <= 1  then 'very small'
    when lv_digit <= 3  then 'still small'
    when lv_digit <= 5  then 'okay'
    when lv_digit <= 8  then 'rather big'
    when lv_digit <= 10 then 'huge'
    else 'unknown to us' ).

write: /, |{ lv_digit } is { lv_digit_weight }|. "5 is okay

*conv + let
data(lr_rnd_1) = cl_abap_random_int=>create(
  seed = conv i( sy-uzeit ) min = 2 max = 5 ).

data(lr_rnd_2) = cl_abap_random_int=>create(
  seed = conv i( sy-uzeit ) min = 1 max = 9 ).

data(lv_motivation_msg) = conv string(
    let x = lr_rnd_1->get_next( )
        y = lr_rnd_2->get_next( )
    in |Dear colleague! We really appriciate your work. Your next promotion will be in 20{ x }{ y }! Best regards, boss| ).

write: /, lv_motivation_msg.
