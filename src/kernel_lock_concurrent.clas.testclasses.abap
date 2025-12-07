CLASS ltcl_test_key DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM FINAL.
  PUBLIC SECTION.
    METHODS test1 FOR TESTING RAISING cx_static_check.
    METHODS test_empty_text FOR TESTING RAISING cx_static_check.
    METHODS test_roundtrip_cases FOR TESTING RAISING cx_static_check.
    METHODS test_roundtrip_nibbles FOR TESTING RAISING cx_static_check.
    METHODS test_encode_deterministic FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test_key IMPLEMENTATION.
  METHOD test1.
    DATA(lv_input) = |abc|.
    DATA(lv_key) = lcl_key=>encode( lv_input ).
    cl_abap_unit_assert=>assert_not_initial( lv_key ).
    DATA(lv_text) = lcl_key=>decode( lv_key ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_text
      exp = lv_input ).
  ENDMETHOD.

  METHOD test_empty_text.
    DATA(lv_input) = ||.
    DATA(lv_key) = lcl_key=>encode( lv_input ).
    cl_abap_unit_assert=>assert_initial( lv_key ).
    DATA(lv_text) = lcl_key=>decode( lv_key ).
    cl_abap_unit_assert=>assert_initial( lv_text ).
  ENDMETHOD.

  METHOD test_roundtrip_cases.
    TYPES ty_inputs TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_inputs TYPE ty_inputs.
    lt_inputs = VALUE #( ( |ABC123| )
               ( |The quick brown fox 123!| )
               ( |padded    text| )
               ( |~!@#$%^&*()_+-=| ) ).

    LOOP AT lt_inputs INTO DATA(lv_input).
      DATA(lv_key) = lcl_key=>encode( lv_input ).
      DATA(lv_key_length) = strlen( lv_key ).
      cl_abap_unit_assert=>assert_equals(
        act = lv_key_length MOD 3
        exp = 0
        msg = |Key length not divisible by 3 for input "{ lv_input }"| ).
      DATA(lv_text) = lcl_key=>decode( lv_key ).
      cl_abap_unit_assert=>assert_equals(
        act = lv_text
        exp = lv_input
        msg = |Roundtrip failed for "{ lv_input }"| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_roundtrip_nibbles.
    TYPES ty_inputs TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_inputs TYPE ty_inputs.
    lt_inputs = VALUE #( ( |fizz buzz| )
                         ( |xyzzy| )
                         ( |nibble hex case| ) ).

    LOOP AT lt_inputs INTO DATA(lv_input).
      DATA(lv_key) = lcl_key=>encode( lv_input ).
      DATA(lv_text) = lcl_key=>decode( lv_key ).
      cl_abap_unit_assert=>assert_equals(
        act = lv_text
        exp = lv_input
        msg = |Nibble roundtrip failed for "{ lv_input }"| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_encode_deterministic.
    DATA(lv_input) = |HexF0xValue|.
    DATA(lv_key_one) = lcl_key=>encode( lv_input ).
    DATA(lv_key_two) = lcl_key=>encode( lv_input ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_key_one
      exp = lv_key_two
      msg = 'Encoding must be deterministic' ).

    DATA(lv_text_one) = lcl_key=>decode( lv_key_one ).
    DATA(lv_text_two) = lcl_key=>decode( lv_key_two ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_text_one
      exp = lv_input ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_text_two
      exp = lv_input ).
  ENDMETHOD.
ENDCLASS.