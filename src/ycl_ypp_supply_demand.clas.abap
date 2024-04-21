CLASS ycl_ypp_supply_demand DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS run
    IMPORTING
      !iv_date TYPE dats.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS check_auth
    RETURNING
      VALUE(rv_auth) TYPE abap_bool.  

ENDCLASS.

CLASS ycl_ypp_supply_demand IMPLEMENTATION.

  METHOD check_auth.

  ENDMETHOD.

  METHOD run.

  ENDMETHOD.

ENDCLASS.
