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

  ENDMETHOD.

  METHOD get_supply_data.

  ENDMETHOD.

  METHOD get_demand_data.

  ENDMETHOD.

  METHOD run.

  ENDMETHOD.

ENDCLASS.
