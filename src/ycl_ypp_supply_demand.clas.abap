CLASS ycl_ypp_supply_demand DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_supply TYPE TABLE OF ypp_supply_log WITH EMPTY KEY,
           tt_demand TYPE TABLE OF ypp_demand WITH EMPTY KEY.

    CLASS-METHODS run
    IMPORTING
      !iv_date TYPE dats.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA: gt_supply_data TYPE tt_supply,
                gt_demand_data TYPE tt_demand.

    CLASS-METHODS check_auth
    RETURNING
      VALUE(rv_auth) TYPE abap_bool.
    CLASS-METHODS get_supply_data
    IMPORTING
      !iv_date TYPE dats
    RETURNING
      VALUE(rt_supply) TYPE tt_supply.
    CLASS-METHODS get_demand_data
    IMPORTING
      !iv_date TYPE dats
    RETURNING
      VALUE(rt_demand) TYPE tt_demand.
ENDCLASS.

CLASS ycl_ypp_supply_demand IMPLEMENTATION.

  METHOD check_auth.
*  "Auth check, run whatevs checks here for auths and permissions, like:
*    AUTHORITY-CHECK OBJECT 's_supply_demand'
*      ID 'ACTVT' FIELD '03'.
*
*      IF sy-subrc <> 0.
*        rv_auth = abap_false.
*      ENDIF.
  ENDMETHOD.

  METHOD get_supply_data.
    SELECT * FROM ypp_supply_log INTO TABLE rt_supply "small field catalog so pull everything
      WHERE date <= iv_date "focus only on the date
      ORDER BY PRIMARY KEY.

  ENDMETHOD.

  METHOD get_demand_data.
    SELECT * FROM ypp_demand INTO TABLE rt_demand "same
      WHERE date <= iv_date "same
      ORDER BY PRIMARY KEY.

  ENDMETHOD.

  METHOD run.
    check_auth( ).
    gt_supply_data = get_supply_data( iv_date ).
    gt_demand_data = get_demand_data( iv_date ).


  ENDMETHOD.

ENDCLASS.
