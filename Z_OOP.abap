*&---------------------------------------------------------------------*
*& Report z_oop
*&---------------------------------------------------------------------*
*& Examples relevant for ABAP 7.50
*& Down Cast means assigning the reference of a Super Class back to a Sub Class.
*&---------------------------------------------------------------------*
report z_oop.

class base definition.

  public section.
    methods:
      constructor,
      display_prop.

    data:
        mv_prop type string.

endclass.

class base implementation.
  method constructor.
    mv_prop = 'base'.
  endmethod.

  method display_prop.
    write: /,  |My prop is { mv_prop }|.
  endmethod.

endclass.


class child definition inheriting from base.

  public section.
    methods:
      constructor,
      new_method.

    data:
        mv_prop_child type string.
endclass.

class child implementation.
  method constructor.
    super->constructor(  ).
    mv_prop = 'child'.
  endmethod.

  method new_method.
    write: /,  'Here comes new method implementation... '.
  endmethod.


endclass.


start-of-selection.
  data(lr_base) = new base(  ).

  data(lr_child) = new child(  ).

  data: lr_child_2 type ref to child,
        lr_base_2  type ref to base.

  write: 'Base ref before casting' color col_heading.
  lr_base->display_prop(  ).

  write: /, 'Child ref before casting' color col_heading.
  lr_child->display_prop(  ).

* UP cast (or narrow cast)
  lr_base = lr_child.
  write: /, 'Base ref after up casting pointing to child ref' color col_heading.
  lr_base->display_prop(  ).

* DOWN cast (or widening cast)
  write: /, 'Child_2 ref after down casting pointing to child ref' color col_heading.
  lr_child_2 = cast #( lr_base ). " same as lr_child ?= lr_base .
  lr_child_2->display_prop(  ).
  lr_child_2->new_method(  ).

  try.
      write: /, 'Creating base_2 ref, trying to down cast without preceding up cast' color col_heading.
      lr_base_2 = new base(  ).
      lr_child_2 = cast #( lr_base_2 ).
    catch cx_root into data(lr_root).

      write: /, 'Nice pretty dump: ',  lr_root->get_text(  ) color col_negative.
  endtry.