CLASS zcl_ce_bgpf_messages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ce_bgpf_messages IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    CASE io_request->get_entity_id( ).
      WHEN 'ZCE_BGPF_MESSAGES'.
        "filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.

        IF io_request->is_data_requested( ).
          "paging
          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                      THEN 0 ELSE lv_page_size ).
          "sorting
          DATA(sort_elements) = io_request->get_sort_elements( ).
          DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                     ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
                                                                                                                                     ELSE ` ascending` ) ) ).
          DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                           ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
          "requested elements
          DATA(lt_req_elements) = io_request->get_requested_elements( ).
          DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).

          DATA lt_data TYPE STANDARD TABLE OF ZCE_BGPF_MESSAGES.
          DATA ls_data LIKE LINE OF lt_data.
          DATA lv_tabix TYPE i.

          SELECT * FROM zbgpfmess WHERE (lv_sql_filter)
                                ORDER BY (lv_sort_string)
                                INTO TABLE @DATA(lt_messages).

          SORT lt_messages BY sequence.

          io_response->set_data( lt_messages ).

          IF io_request->is_total_numb_of_rec_requested( ).
            DATA lv_total_rows TYPE int8.
            lv_total_rows = lines( lt_messages ).
            io_response->set_total_number_of_records( lv_total_rows ).
          ENDIF.

        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
