CLASS lcl_key DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS encode
      IMPORTING
        iv_text       TYPE kernel_locks-lock_key
      RETURNING
        VALUE(rv_key) TYPE string.

    CLASS-METHODS decode
      IMPORTING
        iv_key         TYPE string
      RETURNING
        VALUE(rv_text) TYPE kernel_locks-lock_key.
ENDCLASS.

CLASS lcl_key IMPLEMENTATION.
  METHOD encode.
    DATA lv_numc  TYPE n LENGTH 3.
    DATA lv_index TYPE i.
    DATA lv_byte  TYPE i.
    DATA lv_hex   TYPE x LENGTH 1.
    DATA(lv_xstr) = cl_abap_conv_codepage=>create_out( )->convert( |{ iv_text }| ).
    DO xstrlen( lv_xstr ) TIMES.
      lv_index = sy-index - 1.
      lv_hex = lv_xstr+lv_index(1).
      lv_byte = lv_hex.
      lv_numc = lv_byte.
      rv_key = rv_key && |{ lv_numc }|.
    ENDDO.
  ENDMETHOD.

  METHOD decode.
    DATA lv_index   TYPE i.
    DATA lv_xstring TYPE xstring.
    DATA lv_hex     TYPE x LENGTH 1.
    DATA lv_numc    TYPE n LENGTH 3.
    DATA lv_int     TYPE i.
    DATA lv_len     TYPE i.

    lv_len = strlen( iv_key ).
    lv_index = 0.
    " decode 3 chars from left to right
    WHILE lv_len > lv_index.
      lv_numc = iv_key+lv_index(3).
      lv_int = lv_numc.
      lv_hex = lv_int.
      CONCATENATE lv_xstring lv_hex INTO lv_xstring IN BYTE MODE.
      lv_index = lv_index + 3.
    ENDWHILE.
    rv_text = cl_abap_conv_codepage=>create_in( )->convert( lv_xstring ).
  ENDMETHOD.
ENDCLASS.

******************************************************************

CLASS lcx_advisory_lock_failed DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

CLASS lcx_advisory_lock_failed IMPLEMENTATION.
ENDCLASS.

******************************************************************

CLASS lcl_advisory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS lock
      IMPORTING
        key TYPE string
      RAISING
        lcx_advisory_lock_failed.

    CLASS-METHODS unlock
      IMPORTING
        key TYPE string.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_advisory IMPLEMENTATION.

  METHOD lock.

    DATA lv_str TYPE string.
    DATA lr_foo TYPE REF TO data.


    ASSERT key IS NOT INITIAL.
    GET REFERENCE OF lv_str INTO lr_foo.

    TRY.
        DATA(lo_result) = NEW cl_sql_statement( )->execute_query( |SELECT pg_try_advisory_lock( { key } )| ).
        lo_result->set_param( lr_foo ).
        lo_result->next( ).
        lo_result->close( ).
      CATCH cx_sql_exception INTO DATA(lx_sql).
        ASSERT 1 = 2.
    ENDTRY.

    WRITE / 'Advisory lock acquired'.
  ENDMETHOD.

  METHOD unlock.
" pg_advisory_unlock
    WRITE / 'Advisory lock released'.
  ENDMETHOD.

ENDCLASS.