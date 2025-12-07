CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM FINAL.
  PUBLIC SECTION.
    METHODS test_enqueue_dequeue FOR TESTING RAISING cx_static_check.
    METHODS standalone_dequeue FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.

  METHOD test_enqueue_dequeue.

    CALL FUNCTION 'ENQUEUE_EZABAPGIT_UNIT_T'
      EXPORTING
        bname          = 'HELLO'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    cl_abap_unit_assert=>assert_subrc( ).

    " todo: test that lock is held?

    CALL FUNCTION 'DEQUEUE_EZABAPGIT_UNIT_T'
      EXPORTING
        bname = 'HELLO'.

  ENDMETHOD.

  METHOD standalone_dequeue.

    " should not raise error even if no lock is held
    CALL FUNCTION 'DEQUEUE_EZABAPGIT_UNIT_T'
      EXPORTING
        bname = 'NONEXISTENT_LOCK'.

  ENDMETHOD.

ENDCLASS.