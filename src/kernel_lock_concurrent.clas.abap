CLASS kernel_lock_concurrent DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS enqueue
      IMPORTING
        input TYPE any
      EXCEPTIONS
        foreign_lock
        system_failure.

    CLASS-METHODS dequeue
      IMPORTING
        input TYPE any.
ENDCLASS.

CLASS kernel_lock_concurrent IMPLEMENTATION.

  METHOD enqueue.

    DATA lv_table_name TYPE string.
    DATA lv_enqueue_name TYPE string.
    DATA lo_structdescr TYPE REF TO cl_abap_structdescr.
    DATA ls_lock_row TYPE kernel_locks.
    DATA lr_dref TYPE REF TO data.
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
      WRITE: / 'Component:', ls_component-name, 'Type:', ls_component-type_kind.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE input TO FIELD-SYMBOL(<lv_field>).
      ASSERT sy-subrc = 0.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE <lg_row> TO FIELD-SYMBOL(<lv_row_field>).
      ASSERT sy-subrc = 0.
      <lv_row_field> = <lv_field>.
    ENDLOOP.

    ls_lock_row-table_name = lv_table_name.
    ls_lock_row-lock_key = <lg_row>.
    ls_lock_row-username = sy-uname.
    GET TIME STAMP FIELD ls_lock_row-timestamp.
    ls_lock_row-hostname = sy-host.
    ls_lock_row-lock_mode = ''.
    ls_lock_row-lock_name = lv_enqueue_name.

    WRITE: / 'Simulating enqueue for table:', lv_table_name, 'and enqueue:', lv_enqueue_name.

    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD dequeue.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

ENDCLASS.