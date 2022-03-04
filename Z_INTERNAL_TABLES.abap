*&---------------------------------------------------------------------*
*& Report z_internal_tables
*&---------------------------------------------------------------------*
*& Examples relevant for ABAP 7.50
*&---------------------------------------------------------------------*
report z_internal_tables.

types: begin of ty_empl_rec,
         id(3) type n,
         name  type string,
         email type string,
         iq    type i,
       end of ty_empl_rec.

data lt_empl type hashed table of ty_empl_rec with unique key id
                                              with non-unique sorted key key_iq components iq.

*** VALUE
lt_empl = value #( ( id = '001' name = 'Socrates'   email = 'cool_socr@hellas.gr'       iq = 159 )
                   ( id = '002' name = 'Plato'      email = 'plato_plato@hellas.gr'     iq = 150 )
                   ( id = '003' name = 'Pythagores' email = 'a2plusb2eqc2@hellas.gr'    iq = 155 )
                   ( id = '004' name = 'Archimedes' email = 'heureka@hellas.gr'         iq = 160 ) ).

try.
    data(lv_hera_iq) = lt_empl[ name = 'Heraclitus' ]-iq. " Exception!

  catch cx_root into data(lx_root).
    write: 'Not yet hired: ', lx_root->get_text( ).
    lt_empl = value #( base lt_empl ( id = '005' name = 'Heraclitus' email = 'hera_ephesus@hellas.gr' iq = 144 ) ).

endtry.

if lv_hera_iq < 150.
  lt_empl[ id = '005' ]-iq = 150.
endif.

data(lv_euripides_iq) = value #( lt_empl[ name = 'Euripides' ]-iq optional ). " No exception
if lv_euripides_iq = 0.
  lt_empl = value #( base lt_empl ( id = '006' name = 'Euripides' email = 'everybody_cmon@hellas.gr' iq = 145 ) ).
endif.

*** REDUCE
data(l_sum_iq) = reduce i( init lv_res = 0
                           for  ls_empl in lt_empl
                           next lv_res = lv_res + ls_empl-iq ).
write: /, 'Sum IQ = ', l_sum_iq.

*** CORRESPONDING
types: begin of ty_empl_ext,
         sap_id    type i,
         empl_name type string,
         email     type string,
         iq        type i,
       end of ty_empl_ext.

types: tty_empl_ext type table of ty_empl_ext with default key.

data(lt_empl_ext) = corresponding tty_empl_ext( lt_empl
                                                mapping sap_id    = id
                                                        empl_name = name
                                                except iq ).

*** FILTER
data(lt_best_guys) = filter #( lt_empl using key key_iq where iq >= 155 ).

*** FOR
data(lr_rnd) = cl_abap_random_int=>create(
  seed = conv i( sy-uzeit ) min = 100 max = 160 ).

data(lt_updated_empl) = value tty_empl_ext(
        for ls_empl in lt_empl
*            index into idx !!!
            where ( iq > 0 )
            ( empl_name = ls_empl-name
              email   = ls_empl-email
              iq  = lr_rnd->get_next(  ) )
    ).


*** MOVE-CORRESPONDING
types: begin of ty_goods_ru,
         id           type numc10,
         name         type string,
         unit         type string,
         price_rub(3) type p decimals 2,
       end of ty_goods_ru.

types ty_t_goods_ru type standard table of ty_goods_ru with default key.

types: begin of ty_goods_global,
         id           type numc10,
         name         type string,
         price_usd(3) type p decimals 2,
       end of ty_goods_global.

types ty_t_goods_global type standard table of ty_goods_global with default key.

types: begin of ty_store_rus,
         id    type numc5,
         name  type string,
         goods type ty_t_goods_ru,
       end of ty_store_rus.

types: ty_t_store_rus type standard table of ty_store_rus with default key.

types: begin of ty_store_global,
         id    type numc10,
         name  type string,
         goods type ty_t_goods_global,
       end of ty_store_global.

types: ty_t_store_global type standard table of ty_store_global with default key.

data(lt_store_rus) = value ty_t_store_rus( ( id     = '10001'
                                             name   = 'Универмаг "Маг"'
                                             goods = value #( ( id = '1' name = 'cucumber' unit = 'kg'      price_rub = '60.00' )
                                                              ( id = '2' name = 'garlic'   unit = 'kg'      price_rub = '40.00' )
                                                              ( id = '3' name = 'bread'    unit = 'loaf'    price_rub = '20.00' ) ) )
                                            ( id     = '10002'
                                             name   = 'Зоомагазин "Лютый зверь"'
                                             goods = value #( ( id = '1' name = 'dry cat food' unit = 'kg'   price_rub = '260.00' )
                                                              ( id = '2' name = 'wet cat food' unit = 'item' price_rub = '150.00' )
                                                              ( id = '3' name = 'fresh meat'   unit = 'kg'   price_rub = '320.00' ) ) ) ).


data(lt_store_global) = value ty_t_store_global( ( id    = '9000020001'
                                                   name  = 'Auto parts'
                                                   goods =  value #( ( id = 9211 name = 'Wheel'          price_usd = '20' )
                                                                     ( id = 9212 name = 'Big tyre'       price_usd = '100' )
                                                                     ( id = 9213 name = 'Very big tyre'  price_usd = '220' ) ) )
                                                  ( id    = '9000020002'
                                                   name  = 'Sports equipment'
                                                   goods =  value #( ( id = 9221 name = 'Barbell'        price_usd = '150' )
                                                                     ( id = 9222 name = 'Dumbbell'       price_usd = '60' )
                                                                     ( id = 9223 name = 'Protein bar'    price_usd = '5' ) ) ) ).

data(lt_global_holding_goods) = lt_store_global.

move-corresponding lt_store_rus to lt_global_holding_goods expanding nested tables.

lt_global_holding_goods = lt_store_global.
move-corresponding lt_store_rus to lt_global_holding_goods expanding nested tables keeping target lines.


*** loop with groupping
types: begin of lty_manager_bonus,
         depart_id    type i,
         manager_id   type i,
         annual_bonus type i,
       end of lty_manager_bonus.

types lty_t_manager_bonus type standard table of lty_manager_bonus with default key.

data(lt_manager_bonus) = value lty_t_manager_bonus( ( depart_id = 1 manager_id = 101 annual_bonus = 200 )
                                                    ( depart_id = 1 manager_id = 102 annual_bonus = 120 )
                                                    ( depart_id = 1 manager_id = 103 annual_bonus = 160 )
                                                    ( depart_id = 1 manager_id = 104 annual_bonus = 210 )
                                                    ( depart_id = 2 manager_id = 201 annual_bonus = 180 )
                                                    ( depart_id = 2 manager_id = 202 annual_bonus = 90 )
                                                    ( depart_id = 2 manager_id = 203 annual_bonus = 260 )
                                                    ( depart_id = 2 manager_id = 204 annual_bonus = 100 )
                                                    ( depart_id = 3 manager_id = 301 annual_bonus = 160 )
                                                    ( depart_id = 3 manager_id = 302 annual_bonus = 150 )
                                                    ( depart_id = 3 manager_id = 302 annual_bonus = 100 )
                                                    ( depart_id = 3 manager_id = 302 annual_bonus = 150 ) ).

loop at lt_manager_bonus into data(ls_group)
        group by ( depart_id = ls_group-depart_id
                    gs       = group size
                    gi       = group index )
        assigning field-symbol(<s_group>).

    write: /, 'Department ID: ', <s_group>-depart_id, ' Number of managers: ', <s_group>-gs.

    data(lv_sum_bonus) = 0.
    loop at group <s_group> assigning field-symbol(<s_group_member>).
        lv_sum_bonus = lv_sum_bonus + <s_group_member>-annual_bonus.
    endloop.

    write: /, 'Total department bonus = ', lv_sum_bonus.

endloop.