CLASS zcl_test_odata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_odata IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    zcl_odata_v4_model=>call_odata(  ).
  ENDMETHOD.
ENDCLASS.
