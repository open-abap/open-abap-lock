CLASS lcl_key DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS encode
      IMPORTING
        iv_text       TYPE string
      RETURNING
        VALUE(rv_key) TYPE string.

    CLASS-METHODS decode
      IMPORTING
        iv_key         TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.
ENDCLASS.

CLASS lcl_key IMPLEMENTATION.
  METHOD encode.
    DATA lv_numc TYPE n LENGTH 3.
    DATA lv_index TYPE i.
    DATA(lv_hex) = cl_abap_conv_codepage=>create_out( )->convert( iv_text ).
    DO xstrlen( lv_hex ) TIMES.
      lv_index = sy-index - 1.
      lv_numc = lv_hex+lv_index(1).
      rv_key = rv_key && |{ lv_numc }|.
    ENDDO.
  ENDMETHOD.

  METHOD decode.
    DATA lv_index   TYPE i.
    DATA lv_len     TYPE i.
    DATA lv_xstring TYPE xstring.
    DATA lv_hex     TYPE x LENGTH 1.
    DATA lv_length  TYPE i.
    DATA lv_numc    TYPE n LENGTH 3.

    lv_index = strlen( iv_key ).
    lv_length = 3.
    " decode 3 chars from right to left,
    WHILE lv_index <> 0.
      lv_index = lv_index - 3.
      IF lv_index < 0.
        lv_index = 0.
      ENDIF.
      lv_numc = iv_key+lv_index(3).
      lv_hex = lv_numc+1(2).
      CONCATENATE lv_hex lv_xstring INTO lv_xstring IN BYTE MODE.
    ENDWHILE.
    rv_text = cl_abap_conv_codepage=>create_in( )->convert( lv_xstring ).
  ENDMETHOD.
ENDCLASS.

******************************************************************

CLASS lcl_advisory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS lock
      IMPORTING
        key TYPE string.

    CLASS-METHODS unlock
      IMPORTING
        key TYPE string.
ENDCLASS.

CLASS lcl_advisory IMPLEMENTATION.
  METHOD lock.
    WRITE / 'Advisory lock acquired'.
  ENDMETHOD.

  METHOD unlock.
    WRITE / 'Advisory lock released'.
  ENDMETHOD.
ENDCLASS.