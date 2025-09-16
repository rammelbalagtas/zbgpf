CLASS zcl_odata_v4_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS call_odata.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_odata_v4_model IMPLEMENTATION.
  METHOD call_odata.
*    DATA:
*      lt_business_data TYPE TABLE OF znorthwind_v4_model=>tys_category,
*      lo_http_client   TYPE REF TO if_web_http_client,
*      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
*      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
*      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.
*
*
*    TRY.
    " Create http client
*        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                 comm_scenario  = 'ZNORTHWIND_COMMS'
*                                 service_id     = 'ZNORTHWIND_REST' ).
*        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( 'https://services.odata.org/v4/northwind/northwind.svc/' ).
*        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
*
*        DATA(lo_response1) = lo_http_client->execute( i_method = if_web_http_client=>get ).

*        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v4_remote_proxy(
*          EXPORTING
*             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
*                                                 proxy_model_id      = to_upper( 'ZNORTHWIND_V4_MODEL' )
*                                                 proxy_model_version = '0001' )
*            io_http_client             = lo_http_client
*            iv_relative_service_root   = '' ).
*
*        ASSERT lo_http_client IS BOUND.
*
*        lo_request = lo_client_proxy->create_resource_for_entity_set( 'CATEGORIES' )->create_request_for_read( ).
*        lo_request->set_top( 50 )->set_skip( 0 ).
*
*        " Execute the request and retrieve the business data
*        lo_response = lo_request->execute( ).
*        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
*
*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*        IF 1 = 1.
*        ENDIF.
*        " Handle remote Exception
*        " It contains details about the problems of your http(s) connection
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*        IF 1 = 1.
*        ENDIF.
*        " Handle Exception
*
*      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
*
*        " Handle Exception
*        IF 1 = 1.
*        ENDIF.
*    ENDTRY.


    TYPES:
      "! <p class="shorttext synchronized">Category</p>
      BEGIN OF tys_category,
        "! <em>Value Control Structure</em>
*        value_controls TYPE tys_value_controls_1,
        "! <em>Key property</em> CategoryID
        category_id   TYPE int4,
        "! CategoryName
        category_name TYPE string,
        "! Description
        description  TYPE string,
        "! Picture
        picture      TYPE xstring,
      END OF tys_category,
      "! <p class="shorttext synchronized">List of Category</p>
      tyt_category TYPE STANDARD TABLE OF tys_category WITH DEFAULT KEY.

TYPES:
      BEGIN OF post_s,
        user_id TYPE i,
        id      TYPE i,
        title   TYPE string,
        body    TYPE string,
      END OF post_s,

      post_tt TYPE TABLE OF post_s WITH EMPTY KEY.

    DATA:
      lt_business_data TYPE TABLE OF tys_category,
      lt_data TYPE post_tt,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    TRY.
        " Create the HTTP destination using the Northwind OData V3 service URL
        DATA(lo_destination) = cl_http_destination_provider=>create_by_url(
            'https://jsonplaceholder.typicode.com/posts'
        ).

        " Create an HTTP client to communicate with the destination
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        " Now you can use lo_http_client to make OData calls (e.g., GET, POST, PUT, DELETE)
        DATA(response) = lo_http_client->execute( if_web_http_client=>get )->get_text(  ).
        " Receive the response
        lo_http_client->close( ).

        " Convert JSON to post table
        xco_cp_json=>data->from_string( response )->apply(
          VALUE #( ( xco_cp_json=>transformation->camel_case_to_underscore ) )
          )->write_to( REF #( lt_data ) ).

*        xco_cp_json=>data->from_string( response )->apply(
*          VALUE #( ( xco_cp_json=>transformation->camel_case_to_underscore ) )
*          )->write_to( REF #( lt_business_data ) ).

        " Handle exceptions during send/receive operations
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
