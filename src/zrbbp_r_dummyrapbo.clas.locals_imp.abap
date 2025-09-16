CLASS lhc_zrbr_dummyrapbo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR DummyEntity
        RESULT result,
      validatefield1 FOR VALIDATE ON SAVE
        IMPORTING keys FOR DummyEntity~validatefield1.
ENDCLASS.

CLASS lhc_zrbr_dummyrapbo IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD validatefield1.
    READ ENTITIES OF zrbr_dummyrapbo IN LOCAL MODE
        ENTITY DummyEntity
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(roots).
    LOOP AT roots ASSIGNING FIELD-SYMBOL(<root>).
      APPEND VALUE #( %tky = <root>-%tky ) TO failed-DummyEntity.
      APPEND VALUE #( %tky        = <root>-%tky
                      %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text = 'Error' ) ) TO reported-DummyEntity.
      APPEND VALUE #( %tky        = <root>-%tky
                      %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                              text = 'Information' ) ) TO reported-DummyEntity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
