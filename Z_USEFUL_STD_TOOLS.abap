*&---------------------------------------------------------------------*
*& Report z_useful_std_tools
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report z_useful_std_tools.

*** iTab to JSON
data: begin of ls_structure,
        id         type i value 1,
        first_name type string value 'Victor',
        notes      type string value '',
      end of ls_structure.

* Uppercase by default
data(lv_req_json) = /ui2/cl_json=>serialize( data = ls_structure ).

write: lv_req_json. " {"ID":1,"FIRST_NAME":"Victor","NOTES":""}

* Lowercase
lv_req_json = /ui2/cl_json=>serialize(  data        = ls_structure
                                        pretty_name = /ui2/cl_json=>pretty_mode-low_case ).
write: /, lv_req_json. " {"id":1,"first_name":"Victor","notes":""}

* Translate field names to camelCase, remove empty fields
lv_req_json = /ui2/cl_json=>serialize(  data        = ls_structure
                                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                        compress    = abap_true ).
write: /, lv_req_json. " {"id":1,"firstName":"Victor"}

* Tables as well
data lt_tab like table of ls_structure.

lt_tab = value #( ( id = 1 first_name = 'Ben' notes = 'Good guy' )
                  ( id = 2 first_name = 'Bob' notes = 'Smart man' )
                  ( id = 3 first_name = 'Alex' notes = 'Crazy' ) ).

lv_req_json = /ui2/cl_json=>serialize(  data        = lt_tab
                                        pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

write: /, lv_req_json.
*[
*    {"id":1,"first_name":"Ben","notes":"Good guy"},
*    {"id":2,"first_name":"Bob","notes":"Smart man"},
*    {"id":3,"first_name":"Alex","notes":"Crazy"}
*]

*** JSON to iTab
data(lr_parser) = new /ui5/cl_json_parser(  ).
lr_parser->parse( lv_req_json ).
loop at lr_parser->m_entries assigning field-symbol(<s_entry>).
  data(lv_line) = |{ <s_entry>-type }--->{ <s_entry>-subtype }--->{ <s_entry>-parent }--->{ <s_entry>-name }--->{ <s_entry>-value }|.
  write: /, lv_line. "Ugly
endloop.
cl_demo_output=>display_data( lr_parser->m_entries ). "Pretty


*** XML to iTab
data(lv_xml) = '<?xml version="1.0"?><Outer a="attr"><One>data1</One><Two>data2</Two><Three>data3</Three></Outer>'.

data: lv_xml_x    type xstring,
      lt_xml_data type table of smum_xmltb,
      lt_return   type bapiret2_t.

call function 'SCMS_STRING_TO_XSTRING'
  exporting
    text   = conv string( lv_xml )
  importing
    buffer = lv_xml_x.

call function 'SMUM_XML_PARSE'
  exporting
    xml_input = lv_xml_x
  tables
    xml_table = lt_xml_data
    return    = lt_return.

cl_demo_output=>display_data( lt_xml_data ). "Pretty

*** Generating random values (for example, integers)
data(lr_rnd) = cl_abap_random_int=>create(
  seed = conv i( sy-uzeit ) min = 1 max = 100 ).
do 5 times.
  write: /,  'random int: ', lr_rnd->get_next(  ).
enddo.

*** Create Java timestamp
cl_pco_utility=>convert_abap_timestamp_to_java( exporting iv_date = sy-datum
                                                          iv_time = sy-timlo
                                                          iv_msec = 0
                                                importing ev_timestamp = data(lv_timestamp) ).
write: /, lv_timestamp.

* Another way:
data lv_diff type i.

cl_abap_tstmp=>td_subtract(
  exporting
    date1                      = sy-datum
    time1                      = sy-timlo
    date2                      = '19700101'
    time2                      = '000000'
  importing
    res_secs                   = lv_diff
).
write: /, |{ lv_diff }000|.

*** Add header to http request (SOAP service call)
*&  zwsco_ichecking_service is an existing proxy-class for SOAP service

try .

    data(lr_ref) = new zwsco_ichecking_service( logical_port_name = 'STD' ). "inheriting from CL_PROXY_CLIENT

    data lr_header type ref to if_wsprotocol_ws_header.

    lr_header ?= lr_ref->get_protocol( protocol_name = 'IF_WSPROTOCOL_WS_HEADER' ).

    data: lr_ixml         type ref to if_ixml,
          lr_xml_document type ref to if_ixml_document,
          lr_xml_root     type ref to if_ixml_element,
          lr_xml_element  type ref to if_ixml_element,
          lr_xml_node     type ref to if_ixml_node,
          lv_xstring      type xstring,
          lv_string       type string,
          lv_name         type string,
          lv_namespace    type string,
          lv_passwd       type string.

    lv_passwd = 'Hohoho'.

*   Escaping &-s
    replace all occurrences of '&' in lv_passwd with '&amp;'.

    lv_string = |<soapenv:Header xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/1999/XMLSchema">| &&
    |<Authentication xmlns:ccs="http://schemas.datacontract.org/2004/07/CCS.Wcf.Service.Models">| &&
    |<ccs:Login>SAPCRM</ccs:Login>| &&
    |<ccs:Password>{ lv_passwd }</ccs:Password>| &&
    |<ccs:Token></ccs:Token>| &&
    |</Authentication>| &&
    |</soapenv:Header>| .

*   convert to xstring
    lv_xstring = cl_proxy_service=>cstring2xstring( lv_string ).
    if not lv_string is initial.
*   create ixml dom document from xml xstring
      call function 'SDIXML_XML_TO_DOM'
        exporting
          xml           = lv_xstring
        importing
          document      = lr_xml_document
        exceptions
          invalid_input = 1
          others        = 2.
      if sy-subrc = 0 and not lr_xml_document is initial.
        lr_xml_root = lr_xml_document->get_root_element( ).
        lr_xml_element ?= lr_xml_root->get_first_child( ).
*       add header element by element to soap header
        while not lr_xml_element is initial.
          lv_name = lr_xml_element->get_name( ).
          lv_namespace = lr_xml_element->get_namespace_uri( ).
          lr_header->set_request_header( name = lv_name namespace = lv_namespace dom = lr_xml_element ).
          lr_xml_element ?= lr_xml_element->get_next( ).
        endwhile.
      endif.
    endif.

  catch cx_root into data(lx_root).
    write lx_root->get_text( ).
endtry.

*** Send POST request
data(lv_url) = 'http://example.com'.

cl_http_client=>create_by_url( exporting url = conv #( lv_url )
                               importing client = data(lr_http_client)
                               exceptions argument_not_found = 1
                                          plugin_not_active = 2
                                          internal_error    = 3
                                          others            = 4 ).
if sy-subrc <> 0.
  return.
endif.

data: begin of ls_params,
        p1 type i         value 123,
        p2 type string    value 'something good',
      end of ls_params.

data(lv_json_params) = /ui2/cl_json=>serialize( data       = ls_params
                                                compress   = abap_true
                                                pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

lr_http_client->request->set_method( 'POST' ).
lr_http_client->request->set_content_type( 'application/json' ).
lr_http_client->request->set_cdata( lv_json_params ).
lr_http_client->propertytype_logon_popup = if_http_client=>co_disabled.

lr_http_client->authenticate(
  exporting
    username             = 'user'
    password             = 'password' ).

lr_http_client->send( exceptions http_communication_failure = 1
                                 http_invalid_state = 2
                                 others = 3 ).

if sy-subrc = 0.
  lr_http_client->receive( exceptions http_communication_failure = 1
                                      http_invalid_state        = 2
                                      http_processing_failed    = 3 ).
  check sy-subrc = 0.
  data(lv_response) = lr_http_client->response->get_cdata( ).

  call method lr_http_client->response->get_status
    importing
      code   = data(lv_http_code)
      reason = data(lv_http_reason).

endif.