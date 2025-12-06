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
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD dequeue.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

ENDCLASS.