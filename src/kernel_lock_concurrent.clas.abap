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
ENDCLASS.

CLASS kernel_lock_concurrent IMPLEMENTATION.

  METHOD class_constructor.
    cleanup_locks( ).
  ENDMETHOD.

  METHOD cleanup_locks.
* todoooooo
    DELETE FROM kernel_locks WHERE username = sy-uname.
  ENDMETHOD.

  METHOD enqueue.

    DATA lv_table_name   TYPE string.
    DATA lv_enqueue_name TYPE string.
    DATA lo_structdescr  TYPE REF TO cl_abap_structdescr.
    DATA ls_lock_row     TYPE kernel_locks.
    DATA lr_dref         TYPE REF TO data.

    FIELD-SYMBOLS <lg_row> TYPE any.

*******************

    WRITE '@KERNEL lv_table_name.set(INPUT.TABLE_NAME);'.
    WRITE '@KERNEL lv_enqueue_name.set(INPUT.ENQUEUE_NAME);'.

    CREATE DATA lr_dref TYPE (lv_table_name).
    ASSERT sy-subrc = 0.
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

    ls_lock_row-table_name = lv_table_name.
    ls_lock_row-lock_key = <lg_row>.
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
    DATA lv_lock_key   TYPE string.

    WRITE '@KERNEL lv_table_name.set(INPUT.TABLE_NAME);'.

    DELETE FROM kernel_locks WHERE table_name = lv_table_name AND lock_key = lv_lock_key.

    WRITE / 'dequque todo'.
    lcl_advisory=>unlock( '123' ).
  ENDMETHOD.

ENDCLASS.