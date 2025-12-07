CLASS ltcl_test_key DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM FINAL.
  PUBLIC SECTION.
    METHODS test1 FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_key IMPLEMENTATION.
  METHOD test1.
    DATA lv_input TYPE string.
    DATA lv_key   TYPE string.
    DATA lv_text  TYPE string.

    lv_input = 'abc'.
    lv_key = lcl_key=>encode( lv_input ).
    cl_abap_unit_assert=>assert_not_initial( lv_key ).
    WRITE: / 'Encoded key:', lv_key.
    lv_text = lcl_key=>decode( lv_key ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_text
      exp = lv_input ).
  ENDMETHOD.
ENDCLASS.