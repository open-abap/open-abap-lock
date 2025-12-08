CLASS kernel_lock_concurrent DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    CLASS-METHODS enqueue
      IMPORTING
        input        TYPE any
        table_name   TYPE string
        enqueue_name TYPE string
      EXCEPTIONS
        foreign_lock
        system_failure.

    CLASS-METHODS dequeue
      IMPORTING
        table_name   TYPE string
        enqueue_name TYPE string
        input        TYPE any.

    TYPES: BEGIN OF ty_cleanup,
             valid_locks   TYPE i,
             cleaned_locks TYPE i,
           END OF ty_cleanup.
    CLASS-METHODS cleanup_locks
      RETURNING
        VALUE(rs_result) TYPE ty_cleanup.
  PRIVATE SECTION.
    CLASS-METHODS build_lock_key
      IMPORTING
        input              TYPE any
        table_name         TYPE string
      RETURNING
        VALUE(rv_lock_key) TYPE kernel_locks-lock_key.
ENDCLASS.

CLASS kernel_lock_concurrent IMPLEMENTATION.

  METHOD class_constructor.
    cleanup_locks( ).
  ENDMETHOD.

  METHOD cleanup_locks.
    SELECT * FROM kernel_locks INTO TABLE @DATA(lt_locks) ORDER BY PRIMARY KEY ##SUBRC_OK.
    LOOP AT lt_locks INTO DATA(ls_lock).
      DATA(lv_exists) = lcl_advisory=>exists( lcl_key=>encode( ls_lock-lock_key ) ).
      IF lv_exists = abap_true.
        rs_result-valid_locks = rs_result-valid_locks + 1.
      ELSE.
        DELETE FROM kernel_locks WHERE table_name = @ls_lock-table_name AND lock_key = @ls_lock-lock_key.
        rs_result-cleaned_locks = rs_result-cleaned_locks + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_lock_key.

    DATA lr_dref        TYPE REF TO data.
    DATA lo_structdescr TYPE REF TO cl_abap_structdescr.
    DATA lv_string      TYPE string.

    FIELD-SYMBOLS <lg_row> TYPE any.

    CREATE DATA lr_dref TYPE (table_name).
    ASSIGN lr_dref->* TO <lg_row>.

    lo_structdescr ?= cl_abap_typedescr=>describe_by_data( <lg_row> ).
    ASSERT lo_structdescr IS NOT INITIAL.

    LOOP AT lo_structdescr->components INTO DATA(ls_component).
      WRITE '@KERNEL lv_string.set(input[ls_component.get().name.get().toLowerCase().trimEnd()] || "");'.

      ASSIGN COMPONENT ls_component-name OF STRUCTURE <lg_row> TO FIELD-SYMBOL(<lv_row_field>).
      ASSERT sy-subrc = 0.
      <lv_row_field> = lv_string.
    ENDLOOP.

    rv_lock_key = <lg_row>.

  ENDMETHOD.

  METHOD enqueue.

    DATA ls_lock_row TYPE kernel_locks.

*******************

    DATA(lv_lock_key) = build_lock_key(
      input      = input
      table_name = table_name ).
    ASSERT lv_lock_key IS NOT INITIAL.

    ls_lock_row-table_name = table_name.
    ls_lock_row-lock_key = lv_lock_key.
    ls_lock_row-username = sy-uname.
    GET TIME STAMP FIELD ls_lock_row-timestamp.
    ls_lock_row-hostname = sy-host.
    ls_lock_row-lock_mode = ''.
    ls_lock_row-lock_name = enqueue_name.

    TRY.
        lcl_advisory=>lock( lcl_key=>encode( ls_lock_row-lock_key ) ).
      CATCH lcx_advisory_lock_failed.
        RAISE foreign_lock.
    ENDTRY.

    INSERT kernel_locks FROM @ls_lock_row.
    ASSERT sy-subrc = 0.

  ENDMETHOD.

  METHOD dequeue.

    DATA(lv_lock_key) = build_lock_key(
      input      = input
      table_name = table_name ).

    TRY.
        lcl_advisory=>lock( lcl_key=>encode( lv_lock_key ) ).
      CATCH lcx_advisory_lock_failed.
        " it doesnt have the lock, or another session has the lock
        RETURN.
    ENDTRY.

    DELETE FROM kernel_locks WHERE table_name = table_name AND lock_key = lv_lock_key.

    " advisory locks stack,
    lcl_advisory=>unlock( lcl_key=>encode( lv_lock_key ) ).
    lcl_advisory=>unlock( lcl_key=>encode( lv_lock_key ) ).
  ENDMETHOD.

ENDCLASS.