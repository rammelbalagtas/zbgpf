*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_local_events DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    METHODS handleCreate FOR ENTITY EVENT it_parameters FOR Inventory~CreatedEvent.
ENDCLASS.


CLASS lcl_local_events IMPLEMENTATION.
  METHOD handleCreate.

    cl_abap_tx=>save( ).
    zcl_odata_v4_model=>call_odata(  ).

*    DATA update TYPE TABLE FOR UPDATE zrbr_dummyrapbo\\DummyEntity.
*    DATA update_line TYPE STRUCTURE FOR UPDATE zrbr_dummyrapbo\\DummyEntity.
*
*    READ ENTITIES OF zrbr_dummyrapbo
*                ENTITY DummyEntity
*                ALL FIELDS
*                WITH VALUE #( ( %is_draft = if_abap_behv=>mk-off
*                                %key-uuid = 'E2AD113320E21FE0A4CBDC4CC92A2D3C'
*                            ) )
*                RESULT DATA(entities)
*                FAILED DATA(failed).
*
*    IF entities IS NOT INITIAL.
*      LOOP AT entities INTO DATA(entity).
*        update_line-%is_draft = if_abap_behv=>mk-off.
*        update_line-uuid = entity-uuid.
*        update_line-field1 = 'Change 1'.
*        update_line-field2 = 'Change 2'.
*        update_line-field3 = 'Change 3'.
*        APPEND update_line TO update.
*      ENDLOOP.
*
*      MODIFY ENTITIES OF zrbr_dummyrapbo
*                  ENTITY DummyEntity
*                    UPDATE FIELDS ( Field1 Field2 Field3 )
*                    WITH update
*                    REPORTED DATA(reported_ready)
*                    FAILED DATA(failed_ready).
*
*    ENDIF.
*
*    SELECT * FROM zbgpfmess INTO TABLE @DATA(lt_current_messages).
*
*    "this line is required to change the phase from modify to save phase
*    "we can put our updates to database after this
*    cl_abap_tx=>save( ).
*
*    COMMIT ENTITIES RESPONSE OF zrbr_dummyrapbo
*                   " TODO: variable is assigned but never used (ABAP cleaner)
*                 FAILED   DATA(ls_save_failed)
*                 " TODO: variable is assigned but never used (ABAP cleaner)
*                 REPORTED DATA(ls_save_reported).
*
*    DELETE zbgpfmess FROM TABLE @lt_current_messages.

  ENDMETHOD.
ENDCLASS.
