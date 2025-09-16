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
*    zcl_odata_v4_model=>call_odata(  ).
****Update other RAP BO
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
*        update_line-field1 = 'Test with validation2'.
*        APPEND update_line TO update.
*      ENDLOOP.
*
*      MODIFY ENTITIES OF zrbr_dummyrapbo
*                  ENTITY DummyEntity
*                    UPDATE FIELDS ( Field1 Field2 Field3 )
*                    WITH update
*                    MAPPED DATA(mapped_ready)
*                    REPORTED DATA(reported_ready)
*                    FAILED DATA(failed_ready).
*
*      COMMIT ENTITIES.
*    ENDIF.
    DATA create TYPE TABLE FOR CREATE /DMO/I_Travel_U.
    SELECT SINGLE AirlineID, ConnectionID, FlightDate FROM /DMO/I_Flight INTO @DATA(flight).
    create = VALUE #( ( %cid                 = 'create_travel'
                         CustomerID           = '1'
                         AgencyID             = '70006'
                         BeginDate            = flight-FlightDate
                         EndDate              = flight-FlightDate
   ) ).

    MODIFY ENTITIES OF /DMO/I_Travel_U
         ENTITY Travel
           CREATE FIELDS ( CustomerID AgencyID BeginDate EndDate ) WITH create
     MAPPED DATA(mapped)
     REPORTED DATA(reported)
     FAILED DATA(failed).

    COMMIT ENTITIES BEGIN.
    LOOP AT mapped-travel INTO DATA(ls_mapped).
      CONVERT KEY OF /DMO/I_Travel_U FROM ls_mapped-%pid TO FINAL(ls_key).
*
*       CONVERT KEY OF demo_umanaged_root_late_num
*        FROM <mapped_early>-%pid
*        TO FINAL(lv_root_key).
    ENDLOOP.
    COMMIT ENTITIES END.

  ENDMETHOD.
ENDCLASS.
