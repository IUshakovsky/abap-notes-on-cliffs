*&---------------------------------------------------------------------*
*& Report z_open_sql
*&---------------------------------------------------------------------*
*& Some improvements in Open SQL in ABAP 7.4+
*&---------------------------------------------------------------------*
report z_open_sql.

class z_test_class definition.
  public section.
    class-methods get_last_processed_partner
      returning value(rv_partner) type bu_partner.
endclass.

class z_test_class implementation.
  method get_last_processed_partner.
    rv_partner = '0005999999'.
  endmethod.
endclass.

start-of-selection.
*** Efficient way to check if line exists in dbTab
*** (no data transported from db to AS)
  select single @abap_true
      into @data(lv_exists)
      from but000
      where partner = '1000000001'.

*** CASE statement (ABAP 7.4+)
  select partner,
         case when type = '1' then ' '
              when type = '2' then ' '
              else 'group'
         end as bp_type
  from but000
  into table @data(lt_sql_result)
  where partner in ( '1000000001','1000000002' ).


*** Where clause improvements
* string functions (length, lpad, concat etc.)
  select single b~name_last, b~name_first, b~namemiddle,
  concat( b~name_last, b~name_first ) as concat_name,
  lpad( b~name_last, 20, 'X' ) as lpad_x_name_last,
  length( b~name_last ) as len_name_last
  from but000 as b
  where partner = '0001003728'
  into @data(ls_partner).

* calculations, method calls etc. (ABAP 7.5+)
  select count(*) from but000
  where type = '2'
  and partner > @( z_test_class=>get_last_processed_partner(  ) )
   into @data(lv_partners_left_amnt).

  select carrid, connid, fldate, seatsmax - seatsocc as free_seats "7.4+
  from sflight
  where seatsmax - seatsocc > 50 "7.5+
  into table @data(lt_flight_seats).

*** Arithmetic functions
  select record_id,
       z~zzcredlimin,
       floor( z~zzcredlimin ) as fl,
       ceil( z~zzcredlimin ) as cl,
       round( z~zzcredlimin, 1 ) as rnd
  from ztab0001qd as z
  into table @data(lt_records_2).

*** Joins improvements (ABAP 7.4+)
* asterisk
  select b2~name_last, b1~*
  from but0id as b1
  inner join but000 as b2 on b1~partner = b2~partner
  into table @data(lt_partner_ids)
  where b2~type = '1'.

* IN, LIKE etc. with JOINs
  select b2~name_last, b1~*
  from but0id as b1
  inner join but000 as b2 on b1~partner = b2~partner
                          and b2~name_first in ( 'Alexander','Roger' )
                          and b2~nickname like 'Lucky%'
  into table @lt_partner_ids
  where b2~type = '1'.

*** Unions (ABAP 7.5+)
  select partner1 as p from but050
  where partner1 in ( '0001003738','0001786265','0003186045' )
  union all
  select partner2 as p from but050
  where partner1 in ( '0001004543','0001752366','0007183048' )
  into table @data(lt_united_partners).
