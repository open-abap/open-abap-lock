CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM FINAL.
  PUBLIC SECTION.
    METHODS test_enqueue_dequeue FOR TESTING RAISING cx_static_check.
    METHODS standalone_dequeue FOR TESTING RAISING cx_static_check.
    METHODS cleanup_valid FOR TESTING RAISING cx_static_check.
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

  METHOD cleanup_valid.

* start with a clean state
    kernel_lock_concurrent=>cleanup_locks( ).

    CALL FUNCTION 'ENQUEUE_EZABAPGIT_UNIT_T'
      EXPORTING
        bname          = 'HELLO'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(ls_result) = kernel_lock_concurrent=>cleanup_locks( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-valid_locks
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-cleaned_locks
      exp = 0 ).

    CALL FUNCTION 'DEQUEUE_EZABAPGIT_UNIT_T'
      EXPORTING
        bname = 'HELLO'.

  ENDMETHOD.

ENDCLASS.