REPORT ypp_supply_demand_report.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_date TYPE dats OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.

ycl_ypp_supply_demand=>run( p_date ).
