CLASS lsc_zbgpfr_inventorytp_006 DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zbgpfr_inventorytp_006 IMPLEMENTATION.

  METHOD save_modified.

    DATA : inventories           TYPE STANDARD TABLE OF zbgpf_inven_006,
           lt_create_inventories TYPE TABLE FOR CHANGE zbgpfr_inventorytp_006\\inventory,
           inventory             TYPE                   zbgpf_inven_006,
           events_to_be_raised   TYPE TABLE FOR EVENT ZBGPFR_InventoryTP_006~ProcessCompleted,
           events_to_be_raised2  TYPE TABLE FOR EVENT ZBGPFR_InventoryTP_006~CreatedEvent.

    DATA update_inventory_2 TYPE STRUCTURE FOR CHANGE zbgpfr_inventorytp_006\\inventory.
    DATA update_inventories_2 TYPE TABLE FOR CHANGE ZBGPFR_InventoryTP_006\\Inventory.

    IF create-inventory IS NOT INITIAL.

      lt_create_inventories[] = create-inventory[].
      LOOP AT lt_create_inventories ASSIGNING FIELD-SYMBOL(<create_inventory>).
        "check if a process via bgpf shall be started
        TRY.
*            DATA(bgpf_process_name1) = zbgpfcl_calc_inventory_006=>run_via_bgpf( i_rap_bo_entity_key = <create_inventory>-%key ).
            DATA(bgpf_process_name1) = zbgpfcl_calc_inventory_006=>run_via_bgpf_tx_uncontrolled( i_rap_bo_entity_key = <create_inventory>-%key ).

            DATA(lo_process_monitor) = cl_bgmc_process_factory=>create_monitor_from_string( bgpf_process_name1 ).
            DATA(ld_state) = lo_process_monitor->get_state( ).

            <create_inventory>-%control-BgpgProcessName = if_abap_behv=>mk-on.
            <create_inventory>-BgpgProcessName = bgpf_process_name1.
            <create_inventory>-HideEdit = abap_true.
            <create_inventory>-HideButton1 = abap_true. "Hide display messages
            <create_inventory>-processStatus = 'In Process'.
          CATCH cx_bgmc INTO DATA(bgpf_exception1).
            "handle exception
            <create_inventory>-%control-remark = if_abap_behv=>mk-on.
            <create_inventory>-remark = bgpf_exception1->get_text(  ).
        ENDTRY.
      ENDLOOP.

      INSERT new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                            text = 'Data updates is in progress. Wait until the status is updated or click refresh to check' )
         INTO TABLE reported-%other.

    ENDIF.

    IF update-inventory IS NOT INITIAL.
      LOOP AT update-inventory ASSIGNING FIELD-SYMBOL(<update_inventory>).

        "check if a process via bgpf shall be started
*        IF     <update_inventory>-BgpfStatus          = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo
*           AND <update_inventory>-%control-processStatus = if_abap_behv=>mk-off.
        IF <update_inventory>-%control-processStatus = if_abap_behv=>mk-off.

          TRY.
              DATA(bgpf_process_name2) = zbgpfcl_calc_inventory_006=>run_via_bgpf( i_rap_bo_entity_key = <update_inventory>-%key ).
              update_inventory_2-%control-BgpgProcessName = if_abap_behv=>mk-on.
              update_inventory_2-bgpgprocessname = bgpf_process_name2.
              update_inventory_2-%key = <update_inventory>-%key.
              update_inventory_2-HideEdit = abap_true.
              update_inventory_2-HideButton1 = abap_true. "Hide display messages
              update_inventory_2-processStatus = 'In Process'.
              update_inventory_2-Remark = ''.
              update_inventory_2-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo.
              update_inventory_2-%control-HideEdit = if_abap_behv=>mk-on.
              update_inventory_2-%control-processStatus = if_abap_behv=>mk-on.
              update_inventory_2-%control-HideButton1 = if_abap_behv=>mk-on.
              update_inventory_2-%control-Remark = if_abap_behv=>mk-on.
              update_inventory_2-%control-BgpfStatus = if_abap_behv=>mk-on.
              APPEND update_inventory_2 TO update_inventories_2.

            CATCH cx_bgmc INTO DATA(bgpf_exception2).
              "handle exception
              update_inventory_2-%control-remark = if_abap_behv=>mk-on.
              update_inventory_2-remark = bgpf_exception2->get_text(  ).
              update_inventory_2-%key = <update_inventory>-%key.
              APPEND update_inventory_2 TO update_inventories_2.

          ENDTRY.

        ENDIF.

        "the quantity is updated via BGPF
        IF <update_inventory>-%control-processStatus = if_abap_behv=>mk-on AND <update_inventory>-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-successful.
          CLEAR events_to_be_raised.
          APPEND INITIAL LINE TO events_to_be_raised.
          events_to_be_raised[ 1 ] = CORRESPONDING #( <update_inventory> ).
          RAISE ENTITY EVENT zbgpfr_inventorytp_006~ProcessCompleted FROM events_to_be_raised.
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF create-inventory IS NOT INITIAL.
      CLEAR events_to_be_raised2.
      APPEND INITIAL LINE TO events_to_be_raised2.
      events_to_be_raised2[ 1 ] = CORRESPONDING #( <create_inventory> ).
      RAISE ENTITY EVENT zbgpfr_inventorytp_006~CreatedEvent FROM events_to_be_raised2.
      RAISE ENTITY EVENT zbgpfr_inventorytp_006~CreatedEvent FROM events_to_be_raised2.
    ENDIF.

    "Code needed if an unmanaged save is used
    IF create-inventory IS NOT INITIAL.
      inventories = CORRESPONDING #( lt_create_inventories MAPPING FROM ENTITY ).
      INSERT zbgpf_inven_006 FROM TABLE @inventories.
    ENDIF.

    IF update IS NOT INITIAL.
      CLEAR inventories.
      UPDATE zbgpf_inven_006 FROM TABLE @update-inventory
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY. .
    ENDIF.

    IF update_inventory_2 IS NOT INITIAL.
      UPDATE zbgpf_inven_006 FROM TABLE @update_inventories_2
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete IS NOT INITIAL.
      LOOP AT delete-inventory INTO DATA(inventory_delete).
        DELETE FROM zbgpf_inven_006  WHERE uuid = @inventory_delete-uuid.
        DELETE FROM zbgpfinve00d_006 WHERE uuid = @inventory_delete-uuid.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_inventory DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Inventory
        RESULT result,
      calculateinventoryid FOR DETERMINE ON SAVE
        IMPORTING
          keys FOR  Inventory~CalculateInventoryID ,
      reCalculateInventory FOR MODIFY
        IMPORTING keys FOR ACTION Inventory~reCalculateInventory,
      validateQuantity FOR VALIDATE ON SAVE
        IMPORTING keys FOR Inventory~validateQuantity,
      checkQuantity FOR DETERMINE ON SAVE
        IMPORTING keys FOR Inventory~checkQuantity,
      setPrice FOR DETERMINE ON SAVE
        IMPORTING keys FOR Inventory~setPrice,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Inventory RESULT result,
      displayMessages FOR MODIFY
        IMPORTING keys FOR ACTION Inventory~displayMessages,
      refreshDisplay FOR MODIFY
        IMPORTING keys FOR ACTION Inventory~refreshDisplay.

*    CONSTANTS :
*      BEGIN OF bgpf_state,
*        unknown         TYPE int1 VALUE IS INITIAL,
*        erroneous       TYPE int1 VALUE 1,
*        new             TYPE int1 VALUE 2,
*        running         TYPE int1 VALUE 3,
*        successful      TYPE int1 VALUE 4,
*        started_from_bo TYPE int1 VALUE 99,
*      END OF bgpf_state.

ENDCLASS.

CLASS lhc_inventory IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD calculateinventoryid.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
      ENTITY Inventory
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities).
    DELETE entities WHERE InventoryID IS NOT INITIAL.
    CHECK entities IS NOT INITIAL.
    "Dummy logic to determine object_id
    SELECT MAX( inventory_id ) FROM zbgpf_inven_006 INTO @DATA(max_object_id).
    "Add support for draft if used in modify
    "SELECT SINGLE FROM FROM ZBGPFINVE00D_006 FIELDS MAX( InventoryID ) INTO @DATA(max_orderid_draft). "draft table
    "if max_orderid_draft > max_object_id
    " max_object_id = max_orderid_draft.
    "ENDIF.
    MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
      ENTITY Inventory
        UPDATE FIELDS ( InventoryID )
          WITH VALUE #( FOR entity IN entities INDEX INTO i (
          %tky          = entity-%tky
          InventoryID     = max_object_id + i
    ) ).
  ENDMETHOD.

  METHOD reCalculateInventory.

    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
         ENTITY Inventory
         FIELDS ( BgpfStatus )
         WITH CORRESPONDING #( keys )
       RESULT DATA(inventories).

    LOOP AT inventories ASSIGNING FIELD-SYMBOL(<inventory>) .
      CASE <inventory>-BgpfStatus.
        WHEN zbgpfcl_calc_inventory_006=>bgpf_state-unknown .
          <inventory>-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo.
        WHEN zbgpfcl_calc_inventory_006=>bgpf_state-successful .
          <inventory>-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo.
        WHEN OTHERS.
          "do nothing
      ENDCASE.
    ENDLOOP.

*    LOOP AT inventories ASSIGNING <inventory>.
*      APPEND VALUE #( %tky = <inventory>-%tky ) TO failed-inventory.
*      APPEND VALUE #( %tky = <inventory>-%tky
**                      %state_area         = 'VALIDATE_ONSAVE'
*                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                        text = 'Error message 1' )
*
*                     ) TO reported-inventory.
*      APPEND VALUE #( %tky = <inventory>-%tky
**                      %state_area         = 'VALIDATE_ONSAVE'
*                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                        text = 'Warning' )
*
*                     ) TO reported-inventory.
*      APPEND VALUE #( %tky = <inventory>-%tky
**                      %state_area         = 'VALIDATE_ONSAVE'
*                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                        text = 'Success message for remarks' )
*                     ) TO reported-inventory.
*
*    ENDLOOP.

    MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
    ENTITY Inventory
    UPDATE FIELDS ( Remark )
    WITH CORRESPONDING #( inventories ).
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*
*      READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
*       ENTITY Inventory
*         ALL FIELDS "( Quantity QuantityUnit )
*         WITH VALUE #( ( %tky = CORRESPONDING #( <key>-%tky ) ) )
*       RESULT DATA(inventories).
*
*      DELETE inventories WHERE BgpfStatus = skip_bgpf_status_running .
*      CHECK inventories IS NOT INITIAL.
*
*      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
*        ENTITY Inventory
*          UPDATE FROM VALUE #( FOR <s_salooon> IN inventories ( %tky        = CORRESPONDING #( <s_salooon> )
*                                                                Quantity = <s_salooon>-Quantity + 10
*                                                                %control    = VALUE #( Quantity = if_abap_behv=>mk-on ) ) )
*          REPORTED DATA(lt_reported).
*
*    ENDLOOP.
*
*    " not ok but for demo only one cinema is affected
*    reported = CORRESPONDING #( DEEP lt_reported ) .

  ENDMETHOD.

  METHOD validateQuantity.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
         ENTITY Inventory
           ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(roots).

*    LOOP AT roots ASSIGNING FIELD-SYMBOL(<root>).
*
*      APPEND VALUE #( %tky = <root>-%tky ) TO failed-inventory.
*      APPEND VALUE #( %tky        = <root>-%tky
*                      %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                 number   = 001
*                                                 severity = if_abap_behv_message=>severity-error
*                                                 v1       = 'Error' ) ) TO reported-inventory.
*      APPEND VALUE #( %tky        = <root>-%tky
*                      %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                 number   = 001
*                                                 severity = if_abap_behv_message=>severity-error
*                                                 v1       = 'Error' ) ) TO reported-inventory.
*
*
*    ENDLOOP.
  ENDMETHOD.

  METHOD checkQuantity.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
          ENTITY Inventory
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(roots).

    LOOP AT roots ASSIGNING FIELD-SYMBOL(<root>).

*        APPEND VALUE #( %tky        = <root>-%tky
*                        %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                   number   = 001
*                                                   severity = if_abap_behv_message=>severity-error
*                                                   v1       = 'Error' ) ) TO reported-inventory.
*        APPEND VALUE #( %tky        = <root>-%tky
*                        %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                   number   = 001
*                                                   severity = if_abap_behv_message=>severity-error
*                                                   v1       = 'Error' ) ) TO reported-inventory.


    ENDLOOP.
  ENDMETHOD.

  METHOD setPrice.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
          ENTITY Inventory
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(roots).

*    LOOP AT roots ASSIGNING FIELD-SYMBOL(<root>).
*
*      APPEND VALUE #( %tky        = <root>-%tky
*                      %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                 number   = 001
*                                                 severity = if_abap_behv_message=>severity-error
*                                                 v1       = 'Error' ) ) TO reported-inventory.
*      APPEND VALUE #( %tky        = <root>-%tky
*                      %msg        = new_message( id       = '/DMO/CM_FSA'
*                                                 number   = 001
*                                                 severity = if_abap_behv_message=>severity-error
*                                                 v1       = 'Error' ) ) TO reported-inventory.
*
*
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
           ENTITY Inventory
             FIELDS ( ProcessStatus )
             WITH CORRESPONDING #( keys )
           RESULT DATA(lt_data).

    result = VALUE #( FOR ls_data IN lt_data
                      ( %tky      = ls_data-%tky
                                               %action-reCalculateInventory   = COND #( WHEN ls_data-ProcessStatus IS INITIAL
                                                THEN if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )

                       ) ).
  ENDMETHOD.

  METHOD displayMessages.


    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
          ENTITY Inventory
          FIELDS ( BgpfStatus )
          WITH CORRESPONDING #( keys )
        RESULT DATA(inventories).


    LOOP AT inventories ASSIGNING FIELD-SYMBOL(<inventory>).
      APPEND VALUE #( %tky = <inventory>-%tky ) TO failed-inventory.
*      APPEND VALUE #( %tky = <inventory>-%tky ) TO mapped-inventory.

      INSERT new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                              text = 'Information' )
           INTO TABLE reported-%other.

      INSERT new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text = 'Error' )
          INTO TABLE reported-%other.

      INSERT new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                            text = 'Warning' )
         INTO TABLE reported-%other.

*        APPEND VALUE #(
**%tky = <inventory>-%tky
*
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
*                                                          text = 'Information' )
*
*                       ) TO reported-inventory.
*
*               APPEND VALUE #(
*
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
*                                                          text = 'Success' )
*
*                       ) TO reported-inventory.
*
*                            APPEND VALUE #(
*
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                          text = 'Error' )
*
*                       ) TO reported-inventory.
*
*                         APPEND VALUE #(
*                                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
*                                                          text = 'Warning' )
*
*                       ) TO reported-inventory.




    ENDLOOP.
  ENDMETHOD.

  METHOD refreshDisplay.

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
*                FAILED DATA(lt_failed).
*
*    IF entities IS NOT INITIAL.
*      LOOP AT entities INTO DATA(entity).
*        update_line-%is_draft = if_abap_behv=>mk-off.
*        update_line-uuid = entity-uuid.
*        update_line-field1 = '1212323214'.
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
*    ENDIF.

*    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
*         ENTITY Inventory ALL FIELDS
*         WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_inventories).
*
*    result = VALUE #( FOR inventory IN lt_inventories
*                          ( %tky   = inventory-%tky
*                            %param = inventory ) ).

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
     MAPPED DATA(lt_mapped)
     REPORTED DATA(lt_reported)
     FAILED DATA(lt_failed).

  ENDMETHOD.

ENDCLASS.
