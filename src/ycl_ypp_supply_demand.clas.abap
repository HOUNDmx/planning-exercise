CLASS ycl_ypp_supply_demand DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_output,
              customer_id   TYPE ypp_demand-customer_id,
              customer_name TYPE ypp_demand-customer_name,
              productid     TYPE ypp_demand-productid,
              required_date TYPE ypp_demand-required_date,
              quantity      TYPE ypp_demand-quantity,
              vip           TYPE ypp_demand-vip,
              status        TYPE char10,
              stock         TYPE i,
              remaining     TYPE i,
              next_batch    TYPE dats,
            END OF ty_output,

            BEGIN OF ty_stock,
              productid TYPE ypp_supply_log-productid,
              quantity  TYPE ypp_supply_log-quantity,
            END OF ty_stock,

            tt_stock TYPE TABLE OF ty_stock WITH EMPTY KEY,
            tt_output TYPE TABLE OF ty_output WITH EMPTY KEY,
            tt_supply TYPE TABLE OF ypp_supply_log WITH EMPTY KEY,
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
    CLASS-METHODS process_data
      RETURNING
        VALUE(rt_data) TYPE tt_output.
    CLASS-METHODS display
      IMPORTING
        !it_data TYPE tt_output.
    CLASS-METHODS get_next_supply
      IMPORTING
        !iv_date      TYPE dats
        !iv_required  TYPE i
      RETURNING
        VALUE(rv_date) TYPE dats.
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
    SELECT * FROM ypp_supply_log INTO TABLE @rt_supply "small field catalog so pull everything
      WHERE available_date <= @iv_date "focus only on the date
      ORDER BY PRIMARY KEY.

  ENDMETHOD.

  METHOD get_demand_data.
    SELECT * FROM ypp_demand INTO TABLE @rt_demand "same
      WHERE required_date <= @iv_date "same
      ORDER BY PRIMARY KEY.

  ENDMETHOD.

  METHOD get_next_supply.

    SELECT SINGLE available_date FROM ypp_supply_log INTO @rv_date
      WHERE available_date > @iv_date.

  ENDMETHOD.

  METHOD process_data.

    SORT gt_supply_data BY productid.
    DATA: ls_stock  TYPE ty_stock,
          lt_stock  TYPE tt_stock,
          ls_output TYPE ty_output.

    "Calculate how much do we actually have by that date
    LOOP AT gt_supply_data INTO DATA(ls_supply).
      READ TABLE lt_stock ASSIGNING FIELD-SYMBOL(<fs_stock>) WITH KEY productid = ls_supply-productid.
      IF sy-subrc = 0.
        <fs_stock>-quantity = <fs_stock>-quantity + ls_supply-quantity.
      ELSE.
        ls_stock-productid = ls_supply-productid.
        ls_stock-quantity = ls_supply-quantity.
        APPEND ls_stock TO lt_stock.
      ENDIF.
    ENDLOOP.

    "Now we sort the demand by our criteria

    SORT gt_demand_data BY required_date vip DESCENDING quantity ASCENDING.

    ""APPEND VALUE#() could also do the trick maybe?
    LOOP AT gt_demand_data INTO DATA(ls_demand).
      ls_output-customer_id   = ls_demand-customer_id.
      ls_output-customer_name = ls_demand-customer_name.
      ls_output-productid     = ls_demand-productid.
      ls_output-required_date = ls_demand-required_date.
      ls_output-quantity      = ls_demand-quantity.
      ls_output-vip           = ls_demand-vip.
      ls_output-status        = abap_false.
      READ TABLE lt_stock ASSIGNING FIELD-SYMBOL(<fs_mod_stock>) WITH KEY productid = ls_demand-productid.
      IF sy-subrc = 0.
        IF ls_demand-quantity <= <fs_mod_stock>-quantity.
          ls_output-stock = <fs_mod_stock>-quantity.
          <fs_mod_stock>-quantity = <fs_mod_stock>-quantity - ls_demand-quantity.
          ls_output-remaining = <fs_mod_stock>-quantity.
          ls_output-status = abap_true.
        ELSE.
          ls_output-stock = <fs_mod_stock>-quantity.
          ls_output-remaining = <fs_mod_stock>-quantity.
          ls_output-next_batch = get_next_supply( iv_date = ls_demand-required_date iv_required = ls_demand-quantity - ls_output-stock ).
        ENDIF.
      ENDIF.
      APPEND ls_output TO rt_data.
      CLEAR ls_output.
    ENDLOOP.

  ENDMETHOD.

  METHOD display.
    DATA lt_data TYPE tt_output.
    DATA lo_table TYPE REF TO cl_salv_table.

    lt_data = it_data.

    cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_table
        CHANGING
          t_table      = lt_data ).

    DATA(lo_functions) = lo_table->get_functions( ).
    lo_functions->set_all( abap_true ).

    DATA(lo_columns) = lo_table->get_columns( ).
    DATA(lo_column) = lo_columns->get_column( 'CUSTOMER_ID' ).
    lo_column->set_long_text( 'Customer ID' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'CUSTOMER_NAME' ).
    lo_column->set_long_text( 'Customer Name' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'PRODUCTID' ).
    lo_column->set_long_text( 'Product ID' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'REQUIRED_DATE' ).
    lo_column->set_long_text( 'Required Date' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'QUANTITY' ).
    lo_column->set_long_text( 'Requested quantity' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'VIP' ).
    lo_column->set_long_text( 'VIP' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'STATUS' ).
    lo_column->set_long_text( 'Can it be fulfilled?' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'STOCK' ).
    lo_column->set_long_text( 'Current stock' ).
    lo_column->set_output_length( 20 ).
    lo_column = lo_columns->get_column( 'REMAINING' ).
    lo_column->set_long_text( 'Remaining stock after dispatch' ).
    lo_column->set_output_length( 30 ).
    lo_column = lo_columns->get_column( 'NEXT_BATCH' ).
    lo_column->set_long_text( 'Next batch that satisfies demand' ).
    lo_column->set_output_length( 30 ).

    lo_table->display( ).
  ENDMETHOD.

  METHOD run.
    check_auth( ).
    gt_supply_data = get_supply_data( iv_date ).
    gt_demand_data = get_demand_data( iv_date ).
    DATA(processed_data) = process_data( ).
    display( processed_data ).

  ENDMETHOD.

ENDCLASS.
