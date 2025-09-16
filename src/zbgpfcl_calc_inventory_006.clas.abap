CLASS zbgpfcl_calc_inventory_006 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr.
    INTERFACES if_bgmc_op_single .

    TYPES: BEGIN OF ts_rap_bo_entity_key,
             uuid TYPE sysuuid_x16,
           END OF ts_rap_bo_entity_key.

    CLASS-METHODS run_via_bgpf
      IMPORTING i_rap_bo_entity_key             TYPE ts_rap_bo_entity_key
      RETURNING VALUE(r_process_monitor_string) TYPE string
      RAISING   cx_bgmc.

    CLASS-METHODS run_via_bgpf_tx_uncontrolled
      IMPORTING i_rap_bo_entity_key             TYPE   ts_rap_bo_entity_key
      RETURNING VALUE(r_process_monitor_string) TYPE string
      RAISING   cx_bgmc.

    METHODS constructor
      IMPORTING i_rap_bo_entity_key TYPE ts_rap_bo_entity_key.

    CONSTANTS :
      BEGIN OF bgpf_state,
        unknown         TYPE int1 VALUE IS INITIAL,
        erroneous       TYPE int1 VALUE 1,
        new             TYPE int1 VALUE 2,
        running         TYPE int1 VALUE 3,
        successful      TYPE int1 VALUE 4,
        started_from_bo TYPE int1 VALUE 99,
      END OF bgpf_state.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA inventory_uuid TYPE ts_rap_bo_entity_key-uuid.
    CONSTANTS wait_time_in_seconds TYPE i VALUE 5.



ENDCLASS.



CLASS zbgpfcl_calc_inventory_006 IMPLEMENTATION.

  METHOD constructor.
    inventory_uuid = i_rap_bo_entity_key-uuid.
  ENDMETHOD.

  METHOD if_bgmc_op_single~execute.

    DATA update TYPE TABLE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory.

    DATA: lt_messages TYPE STANDARD TABLE OF zbgpfmess.

    WAIT UP TO wait_time_in_seconds SECONDS.

*    cl_abap_tx=>modify( ).

    READ ENTITIES OF ZBGPFR_InventoryTP_006
             ENTITY Inventory
             ALL FIELDS
             WITH VALUE #( ( %is_draft = if_abap_behv=>mk-off
                             %key-uuid = inventory_uuid
                         )  )
             RESULT DATA(entities)
             FAILED DATA(failed).

    IF entities IS NOT INITIAL.

      LOOP AT entities INTO DATA(entity).

        update_line-%is_draft = if_abap_behv=>mk-off.
        update_line-uuid = entity-uuid.
        update_line-ProcessStatus = 'Posted'.
        update_line-Remark = 'Click Display Messages to view the logs'.
        update_line-HideEdit = abap_false.
        update_line-HideButton1 = abap_false.
        update_line-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-successful.
        APPEND update_line TO update.

        APPEND INITIAL LINE TO lt_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
        <fs_message>-uuid = entity-uuid.
        <fs_message>-inventory_id = entity-InventoryID.
        <fs_message>-sequence = '001'.
        <fs_message>-message = 'Error updating record'.
        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
        <fs_message>-uuid = entity-uuid.
        <fs_message>-inventory_id = entity-InventoryID.
        <fs_message>-sequence = '002'.
        <fs_message>-message = 'Successfully updated record'.
        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
        <fs_message>-uuid = entity-uuid.
        <fs_message>-inventory_id = entity-InventoryID.
        <fs_message>-sequence = '003'.
        <fs_message>-message = 'Additional error messages'.
        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
        <fs_message>-uuid = entity-uuid.
        <fs_message>-inventory_id = entity-InventoryID.
        <fs_message>-sequence = '004'.
        <fs_message>-message = 'Error updating the record'.

      ENDLOOP.

      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006
             ENTITY Inventory
               UPDATE FIELDS ( ProcessStatus HideEdit HideButton1 Remark BgpfStatus )
               WITH update
               REPORTED DATA(reported_ready)
               FAILED DATA(failed_ready).

      SELECT * FROM zbgpfmess INTO TABLE @DATA(lt_current_messages).

      cl_abap_tx=>save( ).

*      COMMIT ENTITIES.
      DELETE zbgpfmess FROM TABLE @lt_current_messages.
      MODIFY zbgpfmess FROM TABLE @lt_messages.

    ENDIF.
  ENDMETHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
*    DATA update TYPE TABLE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory.
*    DATA update_line TYPE STRUCTURE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory.
*
*    DATA: lt_messages TYPE STANDARD TABLE OF zbgpfmess.
*
*    WAIT UP TO wait_time_in_seconds SECONDS.
*
*    READ ENTITIES OF ZBGPFR_InventoryTP_006
*             ENTITY Inventory
*             ALL FIELDS
*             WITH VALUE #( ( %is_draft = if_abap_behv=>mk-off
*                             %key-uuid = inventory_uuid
*                         )  )
*             RESULT DATA(entities)
*             FAILED DATA(failed).
*
*    IF entities IS NOT INITIAL.
*
*      LOOP AT entities INTO DATA(entity).
*
*        update_line-%is_draft = if_abap_behv=>mk-off.
*        update_line-uuid = entity-uuid.
*        update_line-ProcessStatus = 'Posted'.
*        update_line-Remark = 'Click Display Messages to view the logs'.
*        update_line-HideEdit = abap_false.
*        update_line-HideButton1 = abap_false.
*        update_line-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-successful.
*        APPEND update_line TO update.
*
*        APPEND INITIAL LINE TO lt_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
*        <fs_message>-uuid = entity-uuid.
*        <fs_message>-inventory_id = entity-InventoryID.
*        <fs_message>-sequence = '001'.
*        <fs_message>-message = 'Error updating record'.
*        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
*        <fs_message>-uuid = entity-uuid.
*        <fs_message>-inventory_id = entity-InventoryID.
*        <fs_message>-sequence = '002'.
*        <fs_message>-message = 'Successfully updated record'.
*        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
*        <fs_message>-uuid = entity-uuid.
*        <fs_message>-inventory_id = entity-InventoryID.
*        <fs_message>-sequence = '003'.
*        <fs_message>-message = 'Additional error messages'.
*        APPEND INITIAL LINE TO lt_messages ASSIGNING <fs_message>.
*        <fs_message>-uuid = entity-uuid.
*        <fs_message>-inventory_id = entity-InventoryID.
*        <fs_message>-sequence = '004'.
*        <fs_message>-message = 'Error updating the record'.
*
*      ENDLOOP.
*
*      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006
*             ENTITY Inventory
*               UPDATE FIELDS ( ProcessStatus HideEdit HideButton1 Remark BgpfStatus )
*               WITH update
*               REPORTED DATA(reported_ready)
*               FAILED DATA(failed_ready).
*
*      SELECT * FROM zbgpfmess INTO TABLE @DATA(lt_current_messages).
*      DELETE zbgpfmess FROM TABLE @lt_current_messages.
*      MODIFY zbgpfmess FROM TABLE @lt_messages.
*
*      COMMIT ENTITIES.
* ENDIF.

    DATA update TYPE TABLE FOR UPDATE zrbr_dummyrapbo\\DummyEntity.
    DATA update_line TYPE STRUCTURE FOR UPDATE zrbr_dummyrapbo\\DummyEntity.

    READ ENTITIES OF zrbr_dummyrapbo
                ENTITY DummyEntity
                ALL FIELDS
                WITH VALUE #( ( %is_draft = if_abap_behv=>mk-off
                                %key-uuid = 'E2AD113320E21FE0A4CBDC4CC92A2D3C'
                            ) )
                RESULT DATA(entities)
                FAILED DATA(failed).

    IF entities IS NOT INITIAL.
      LOOP AT entities INTO DATA(entity).
        update_line-%is_draft = if_abap_behv=>mk-off.
        update_line-uuid = entity-uuid.
        update_line-field1 = 'Change 111'.
        APPEND update_line TO update.
      ENDLOOP.

      MODIFY ENTITIES OF zrbr_dummyrapbo
                  ENTITY DummyEntity
                    UPDATE FIELDS ( Field1 Field2 Field3 )
                    WITH update
                    MAPPED DATA(mapped_ready)
                    REPORTED DATA(reported_ready)
                    FAILED DATA(failed_ready).

      SELECT * FROM zbgpfmess INTO TABLE @DATA(lt_current_messages).

      "this line is required to change the phase from modify to save phase
      "we can put our updates to database after this
      COMMIT ENTITIES RESPONSE OF zrbr_dummyrapbo
                     " TODO: variable is assigned but never used (ABAP cleaner)
                   FAILED   DATA(ls_save_failed)
                   " TODO: variable is assigned but never used (ABAP cleaner)
                   REPORTED DATA(ls_save_reported).

    ENDIF.
  ENDMETHOD.

  METHOD run_via_bgpf.
    TRY.
        DATA(process_monitor) = cl_bgmc_process_factory=>get_default( )->create(
                                              )->set_name( |Calculate inventory data|
                                              )->set_operation(  NEW zbgpfcl_calc_inventory_006( i_rap_bo_entity_key = i_rap_bo_entity_key )
                                              )->save_for_execution( ).

        r_process_monitor_string = process_monitor->to_string( ).

      CATCH cx_bgmc INTO DATA(lx_bgmc).



    ENDTRY.
  ENDMETHOD.

  METHOD run_via_bgpf_tx_uncontrolled.
    TRY.
        DATA(process_monitor) = cl_bgmc_process_factory=>get_default( )->create(
                                              )->set_name( |Calculate inventory data|
                                              )->set_operation_tx_uncontrolled(  NEW zbgpfcl_calc_inventory_006( i_rap_bo_entity_key = i_rap_bo_entity_key )
                                              )->save_for_execution( ).

        r_process_monitor_string = process_monitor->to_string( ).

      CATCH cx_bgmc INTO DATA(lx_bgmc).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
