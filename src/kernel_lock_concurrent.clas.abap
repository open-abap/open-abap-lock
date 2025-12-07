CLASS kernel_lock_concurrent DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    CLASS-METHODS enqueue
      IMPORTING
        input TYPE any
      EXCEPTIONS
        foreign_lock
        system_failure.

    CLASS-METHODS dequeue
      IMPORTING
        input TYPE any.
  PRIVATE SECTION.
    CLASS-METHODS cleanup_locks.
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
* todoooooo
    DELETE FROM kernel_locks WHERE username = sy-uname.
  ENDMETHOD.

  METHOD build_lock_key.

    DATA lr_dref         TYPE REF TO data.
    DATA lo_structdescr  TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS <lg_row> TYPE any.

    CREATE DATA lr_dref TYPE (table_name).
    ASSIGN lr_dref->* TO <lg_row>.

    lo_structdescr ?= cl_abap_typedescr=>describe_by_data( <lg_row> ).
    ASSERT lo_structdescr IS NOT INITIAL.

    LOOP AT lo_structdescr->components INTO DATA(ls_component).
      ASSIGN COMPONENT ls_component-name OF STRUCTURE input TO FIELD-SYMBOL(<lv_field>).
      " fields are not mandatory
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <lg_row> TO FIELD-SYMBOL(<lv_row_field>).
        ASSERT sy-subrc = 0.
        <lv_row_field> = <lv_field>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD enqueue.

    DATA lv_enqueue_name TYPE string.
    DATA lv_table_name   TYPE string.
    DATA ls_lock_row     TYPE kernel_locks.

*******************

    WRITE '@KERNEL lv_table_name.set(INPUT.TABLE_NAME);'.
    WRITE '@KERNEL lv_enqueue_name.set(INPUT.ENQUEUE_NAME);'.

    DATA(lv_lock_key) = build_lock_key(
      input      = input
      table_name = lv_table_name ).

    ls_lock_row-table_name = lv_table_name.
    ls_lock_row-lock_key = lv_lock_key.
    ls_lock_row-username = sy-uname.
    GET TIME STAMP FIELD ls_lock_row-timestamp.
    ls_lock_row-hostname = sy-host.
    ls_lock_row-lock_mode = ''.
    ls_lock_row-lock_name = lv_enqueue_name.

    WRITE: / 'Simulating enqueue for table:', lv_table_name, 'and enqueue:', lv_enqueue_name.

    lcl_advisory=>lock( lcl_key=>encode( ls_lock_row-lock_key ) ).
    INSERT kernel_locks FROM @ls_lock_row.
    ASSERT sy-subrc = 0.

  ENDMETHOD.

  METHOD dequeue.

    DATA lv_table_name TYPE string.

    WRITE '@KERNEL lv_table_name.set(INPUT.TABLE_NAME);'.

    DATA(lv_lock_key) = build_lock_key(
      input      = input
      table_name = lv_table_name ).

    TRY.
        lcl_advisory=>lock( lcl_key=>encode( lv_lock_key ) ).
      CATCH lcx_advisory_lock_failed.
        " it doesnt have the lock, or another session has the lock
        RETURN.
    ENDTRY.

    DELETE FROM kernel_locks WHERE table_name = lv_table_name AND lock_key = lv_lock_key.

    " advisory locks stack,
    lcl_advisory=>unlock( lcl_key=>encode( lv_lock_key ) ).
    lcl_advisory=>unlock( lcl_key=>encode( lv_lock_key ) ).
  ENDMETHOD.

ENDCLASS.