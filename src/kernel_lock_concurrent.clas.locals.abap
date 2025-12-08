CLASS lcl_key DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS encode
      IMPORTING
        iv_text       TYPE kernel_locks-lock_key
      RETURNING
        VALUE(rv_key) TYPE int8.
ENDCLASS.

CLASS lcl_key IMPLEMENTATION.
  METHOD encode.
    DATA lv_hash  TYPE xstring.
    DATA lv_empty TYPE xstring.

* todo: rework this sometime? there might be collissions
    TRY.
        cl_abap_hmac=>calculate_hmac_for_raw(
          EXPORTING
            if_algorithm   = 'MD5'
            if_key         = lv_empty
            if_data        = cl_abap_conv_codepage=>create_out( )->convert( |{ iv_text }| )
          IMPORTING
            ef_hmacxstring = lv_hash ).
      CATCH cx_abap_message_digest.
        ASSERT 1 = 2.
    ENDTRY.

    rv_key = lv_hash(8).
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
        WRITE / 'SQL Error:'.
        WRITE / lx_sql->get_text( ).
        ASSERT 1 = 2.
    ENDTRY.

    IF lr_foo <> abap_true.
      RAISE EXCEPTION TYPE lcx_advisory_lock_failed.
    ENDIF.

  ENDMETHOD.

  METHOD unlock.

    TRY.
        NEW cl_sql_statement( )->execute_query( |SELECT pg_advisory_unlock( { key } )| ).
      CATCH cx_sql_exception INTO DATA(lx_sql).
        WRITE / 'SQL Error:'.
        WRITE / lx_sql->get_text( ).
        ASSERT 1 = 2.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.