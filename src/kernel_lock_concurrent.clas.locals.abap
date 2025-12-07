CLASS lcl_advisory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS lock.
    CLASS-METHODS unlock.
ENDCLASS.

CLASS lcl_advisory IMPLEMENTATION.
  METHOD lock.
    WRITE / 'Advisory lock acquired'.
  ENDMETHOD.

  METHOD unlock.
    WRITE / 'Advisory lock released'.
  ENDMETHOD.
ENDCLASS.