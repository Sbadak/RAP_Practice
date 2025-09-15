CLASS lsc_zbs_travel_i DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zbs_travel_i IMPLEMENTATION.

  METHOD save_modified.

data : travel_log type STANDARD TABLE OF zbd_travel_log,
       travel_log_update type STANDARD TABLE OF zbd_travel_log,
       travel_log_create type STANDARD TABLE OF zbd_travel_log.


  if create-travel is not INITIAL.

travel_log = CORRESPONDING #( create-travel ).

loop at travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
<ls_travel_log>-changing_operation = 'Create'.
get TIME STAMP FIELD <ls_travel_log>-created_at .
try.
<ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
CATCH cx_uuid_error.

ENDTRY.
if create-travel[ 1 ]-%control-BookingFee = cl_abap_behv=>flag_changed.
<ls_travel_log>-changed_field_name = 'BookingFee'.
<ls_travel_log>-change_value = create-travel[ 1 ]-BookingFee.
<ls_travel_log>-travelid = create-travel[ 1 ]-TravelId.
endif.

if create-travel[ 1 ]-%control-AgencyId = cl_abap_behv=>flag_changed.
<ls_travel_log>-changed_field_name = 'AgencyId'.
<ls_travel_log>-change_value = create-travel[ 1 ]-AgencyId.

endif.

APPEND <ls_travel_log> to travel_log_create.


ENDLOOP.
MODIFY zbd_travel_log from table @travel_log_create.

  endif.


  if update-travel is not INITIAL.

  travel_log = CORRESPONDING #( update-travel ).

  loop at travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_update>).
  <ls_travel_update>-changing_operation = 'Update'.
  get TIME STAMP FIELD <ls_travel_update>-created_at .

  try .

  <ls_travel_update>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).

  catch cx_uuid_error.

  ENDTRY.

  if update-travel[ 1 ]-%control-BookingFee = cl_abap_behv=>flag_changed.
<ls_travel_log>-changed_field_name = 'BookingFee'.
<ls_travel_log>-change_value = update-travel[ 1 ]-BookingFee.
<ls_travel_log>-travelid = update-travel[ 1 ]-TravelId.
endif.

*if update-travel[ 1 ]-%control-AgencyId = cl_abap_behv=>flag_changed.
*<ls_travel_log>-changed_field_name = 'AgencyId'.
*<ls_travel_log>-change_value = update-travel[ 1 ]-AgencyId.

*endif.

APPEND <ls_travel_log> to travel_log_update.




  ENDLOOP.
 MODIFY zbd_travel_log from table @travel_log_update.


  endif.

   if delete-travel is not initial.

   endif .



  ENDMETHOD.

ENDCLASS.



CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS bookingsupplement FOR DETERMINE ON SAVE
      IMPORTING keys FOR Bookingsupplement~bookingsupplement.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Bookingsupplement~calculatetotalprice.

ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.

  METHOD bookingsupplement.

    DATA : max_booksuppid  TYPE /dmo/booking_supplement_id,
           booksupp        TYPE STRUCTURE FOR READ RESULT ZBS_BOOKING_SUPL_i,
           booksupp_update TYPE TABLE FOR  UPDATE zbs_travel_i\\Bookingsupplement.

    READ ENTITIES OF zbs_travel_i IN  LOCAL MODE
    ENTITY bookingsupplement BY \_Booking
    FIELDS ( bookinguuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(booking).


    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY  booking BY \_Bookingsupplements
    FIELDS ( BookingSupplementId )
    WITH CORRESPONDING #( booking )
    LINK DATA(ls_bookingsupp_links)
    RESULT DATA(Bookingsuppments).


    LOOP AT booking INTO DATA(ls_bookings).

      max_booksuppid = '00'.
      LOOP  AT ls_bookingsupp_links INTO DATA(ls_booking_link) WHERE source-%tky = ls_bookings-%tky.

        booksupp = Bookingsuppments[ KEY id
                          %tky =  ls_booking_link-target-%tky ] .

        IF booksupp-BookingSupplementId > max_booksuppid.

          max_booksuppid = booksupp-BookingSupplementId.

        ENDIF.


        LOOP  AT ls_bookingsupp_links INTO ls_booking_link WHERE source-%tky = ls_bookings-%tky.

          booksupp = Bookingsuppments[ KEY id
                            %tky =  ls_booking_link-target-%tky ] .

          IF booksupp-BookingSupplementId IS INITIAL .

            max_booksuppid += 1.
            APPEND VALUE #( %tky = booksupp-%tky
                          BookingSupplementId  = max_booksuppid
                           ) TO booksupp_update.
          ENDIF .
        ENDLOOP.
      ENDLOOP .
    ENDLOOP. .


    MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY Bookingsupplement
    UPDATE FIELDS ( BookingSupplementId )
    WITH booksupp_update.
  ENDMETHOD.


  METHOD calculatetotalprice.

    READ ENTITIES OF zbs_travel_i  IN LOCAL MODE
    ENTITY Bookingsupplement BY \_travel
    FIELDS ( TravelUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).


    MODIFY ENTITIES OF  zbs_travel_i IN LOCAL MODE
    ENTITY travel
    EXECUTE recalculatetotalprice
    FROM CORRESPONDING #( lt_travels ).





  ENDMETHOD.

ENDCLASS.


CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setbookingdate.

    METHODS setbookingid FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setbookingid.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculatetotalprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD setbookingdate.



* modify ENTITIES OF ZBS_TRAVEL_I IN LOCAL MODE
*ENTITY booking
*UPDATE FIELDS ( BookingDate = syst-datum )
*with booking_update.
*


  ENDMETHOD.

  METHOD setbookingid.

    DATA : max_bookingid  TYPE /dmo/booking_id,
           booking        TYPE STRUCTURE FOR READ RESULT zbs_booking_i,
           booking_update TYPE TABLE FOR  UPDATE zbs_travel_i\\Booking.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY  booking BY \_Travel
    FIELDS ( Traveluuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

* NOW read all the fields from EML .

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel BY \_Booking
    FIELDS ( BookingId )
    WITH CORRESPONDING #( travels )
    LINK DATA(booking_links)
    RESULT DATA(Bookings).

    LOOP AT travels INTO DATA(ls_travel).

      max_bookingid = '0000'.
      LOOP  AT booking_links INTO DATA(ls_booking_link) WHERE source-%tky = ls_travel-%tky.

        booking = bookings[ KEY id
                          %tky =  ls_booking_link-target-%tky ] .

        IF booking-BookingId > max_bookingid.

          max_bookingid = booking-bookingid.

        ENDIF.


        LOOP  AT booking_links INTO ls_booking_link WHERE source-%tky = ls_travel-%tky.

          booking = bookings[ KEY id
                            %tky =  ls_booking_link-target-%tky ] .

          IF booking-BookingId IS INITIAL .

            max_bookingid += 1.
            APPEND VALUE #( %tky = booking-%tky
                          bookingid = max_bookingid
                           ) TO booking_update.
          ENDIF .

        ENDLOOP.

      ENDLOOP .

    ENDLOOP. .


    MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY booking
    UPDATE FIELDS ( Bookingid )
    WITH booking_update.










  ENDMETHOD.

  METHOD calculatetotalprice.
    READ ENTITIES OF zbs_travel_i  IN LOCAL MODE
    ENTITY booking BY \_travel
    FIELDS ( TravelUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).


    MODIFY ENTITIES OF  zbs_travel_i IN LOCAL MODE
    ENTITY travel
    EXECUTE recalculatetotalprice
    FROM CORRESPONDING #( lt_travels ).




  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS savetravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~savetravelid.
    METHODS setoverallstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setoverallstatus.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejecttravel RESULT result.
    METHODS discount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~discount RESULT result.
    METHODS GetDefaultsFordeductdiscounts FOR READ
      IMPORTING keys FOR FUNCTION Travel~GetDefaultsFordeductdiscounts RESULT result.
    METHODS recalculatetotalprice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalculatetotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculatetotalprice.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validatecustomer.
    METHODS validatedate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validatedate.

    METHODS validatragency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validatragency.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD savetravelid.
    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( Travelid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DELETE lt_travel WHERE travelid IS NOT INITIAL .
    SELECT SINGLE FROM zbs_travel FIELDS MAX( travel_id ) INTO @DATA(lv_travelid_max).
*//modify eml
    MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TravelId )
    WITH VALUE #( FOR ls_travel_id IN lt_travel INDEX INTO lv_index
                     (  %tky = ls_travel_id-%tky
                       TravelId = lv_travelid_max + lv_index ) ).

  ENDMETHOD.

  METHOD setoverallstatus.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( overallstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_status).

    DELETE lt_status WHERE OverallStatus IS NOT INITIAL.

    MODIFY ENTITIES OF  zbs_travel_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR ls_status IN lt_status
                         (  %tky = ls_status-%tky
                           OverallStatus = 'O' ) ).













  ENDMETHOD.

  METHOD accepttravel.
    MODIFY ENTITIES OF  zbs_travel_i IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS ( OverallStatus )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky
          OverallStatus = 'A') ).


    READ ENTITIES OF zbs_travel_i  IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                             %param = Travel ) ) .





  ENDMETHOD.

  METHOD rejecttravel.
    MODIFY ENTITIES OF  zbs_travel_i IN LOCAL MODE
     ENTITY travel
     UPDATE FIELDS ( OverallStatus )
         WITH VALUE #( FOR key IN keys ( %tky = key-%tky
         OverallStatus = 'R') ).


    READ ENTITIES OF zbs_travel_i  IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                             %param = Travel ) ) .
  ENDMETHOD.

  METHOD discount.
    DATA : travel_for_update TYPE TABLE FOR UPDATE zbs_travel_i.

    DATA(tem_key) = keys.

    LOOP AT tem_key ASSIGNING FIELD-SYMBOL(<key_temp>) WHERE %param-Discount_percent IS INITIAL OR
                                                             %param-Discount_percent > 100 OR
                                                             %param-Discount_percent < 0.


      APPEND  VALUE #( %tky = <key_temp>-%tky ) TO failed-travel.
      APPEND  VALUE #( %tky = <key_temp>-%tky
                       %msg = new_message_with_text( text     = 'invalid discount percentage'
                                severity = if_abap_behv_message=>severity-error )
                                %element-totalprice = if_abap_behv=>mk-on
                                %action-discount  = if_abap_behv=>mk-on ) TO reported-travel.

      DELETE tem_key.
    ENDLOOP.

    CHECK tem_key IS NOT INITIAL .

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).


    DATA :lv_percentage TYPE decfloat16.
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_percentage_discount) = keys[ KEY id  %tky = <ls_travel>-%tky ]-%param-Discount_percent.
      lv_percentage = lv_percentage_discount / 100 .
      DATA(reduced_value) = <ls_travel>-TotalPrice * lv_percentage.

      reduced_value = <ls_travel>-TotalPrice - reduced_value.

      APPEND  VALUE #( %tky = <ls_travel>-%tky
                      Totalprice = reduced_value ) TO travel_for_update.



    ENDLOOP.

    MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( Totalprice )
    WITH Travel_for_update.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_travel_update).


    result = VALUE #( FOR ls_travel IN lt_travel_update ( %tky = ls_travel-%tky
                                                         %param = ls_travel ) ).

  ENDMETHOD.

  METHOD GetDefaultsFordeductdiscounts.
    READ ENTITIES OF zbs_travel_i  IN LOCAL MODE
        ENTITY travel
        FIELDS ( TotalPrice )
        WITH CORRESPONDING #( keys )
        RESULT DATA(Travels).

    LOOP AT travels INTO DATA(ls_travels).

      IF ls_travels-TotalPrice >= 4500 .

        APPEND VALUE #( %tky = ls_travels-%tky
        %param-Discount_percent = 30  ) TO result.

      ELSE.
        APPEND VALUE #( %tky = ls_travels-%tky
        %param-Discount_percent = 10  ) TO result.


      ENDIF.

    ENDLOOP .
  ENDMETHOD.

  METHOD recalculatetotalprice.

    TYPES : BEGIN OF ty_amount_per_currencycode,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currencycode.

    DATA : Amount_per_Currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).


    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( lt_Travel )
    RESULT DATA(lt_booking)
    LINK DATA(booking_link).

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY booking BY \_Bookingsupplements
    FIELDS (  Price CurrencyCode )
    WITH CORRESPONDING #( lt_booking )
    RESULT DATA(lt_supplement)
    LINK DATA(supplement_link).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      amount_per_currencycode = VALUE #( ( amount = <ls_travel>-BookingFee
                                              currency_code = <ls_travel>-CurrencyCode ) ).





      LOOP AT booking_link INTO DATA(booking_links) USING KEY id WHERE source-%tky = <ls_travel>-%tky.
        DATA(booking) = lt_booking[ KEY id %tky = booking_links-target-%tky ].

        COLLECT VALUE ty_amount_per_currencycode( amount = Booking-flightprice
                                                 currency_code = booking-CurrencyCode ) INTO amount_per_currencycode .

        LOOP AT supplement_link INTO DATA(ls_supp) USING KEY id WHERE source-%tky = booking-%tky.

          DATA(bookingsupp) = lt_supplement[ KEY id %tky = ls_supp-target-%tky ].

          COLLECT VALUE ty_amount_per_currencycode( amount = BookingSUPP-Price
                                                           currency_code = bookingsupp-CurrencyCode ) INTO amount_per_currencycode.
        ENDLOOP.



      ENDLOOP.

    ENDLOOP.

    DELETE amount_per_currencycode WHERE currency_code IS INITIAL.

    LOOP AT amount_per_currencycode INTO DATA(ls_curr).

      IF <ls_travel>-CurrencyCode  = ls_curr-Currency_code.

        <ls_travel>-TotalPrice += ls_curr-amount.

      ELSE .

        /dmo/cl_flight_amdp=>convert_currency(
          EXPORTING
            iv_amount               = ls_curr-amount
            iv_currency_code_source = ls_curr-Currency_code
            iv_currency_code_target = <ls_travel>-currencycode
            iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
        IMPORTING
           ev_amount               = DATA(total_booking_price)
        ).

        <ls_travel>-TotalPrice += total_booking_price.

      ENDIF.
      MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS ( TotalPrice )
      WITH CORRESPONDING #( lt_travel ).

    ENDLOOP.

  ENDMETHOD.

  METHOD calculatetotalprice.


    MODIFY ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    EXECUTE recalculatetotalprice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD validatecustomer.

    DATA : customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( Customerid )
   WITH CORRESPONDING #( keys )
   RESULT DATA(lt_travel).


    customer = CORRESPONDING #( lt_travel MAPPING customer_id = CustomerId EXCEPT * ).
    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @customer
    WHERE customer_id =  @customer-customer_id
    INTO TABLE @DATA(valid_customer).


    LOOP AT lt_travel INTO DATA(ls_travel).

      IF ls_travel-CustomerId IS NOT INITIAL AND NOT line_exists( valid_customer[ customer_id = ls_travel-CustomerId ] ).

        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                       %state_area = 'Validate Customer'
                       %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text = |'Not valid Customer{ ls_travel-CustomerId }| )
                     %element-customerid = if_abap_behv=>mk-on )  TO reported-travel.


      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD validatedate.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
      ENTITY travel
      FIELDS ( BeginDate EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(ls_travel).

      IF ls_travel-BeginDate IS INITIAL  .
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                 %state_area = 'Validate Date'
                       %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text = |'Begin date should not be initial | )
                     %element-begindate = if_abap_behv=>mk-on )  TO reported-travel.

      ENDIF.

      IF ls_travel-EndDate IS  INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                       %state_area = 'Validate Date'
                       %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text = |'End date should not be initial | )
                     %element-enddate = if_abap_behv=>mk-on )  TO reported-travel.

      ENDIF.

      IF ls_travel-enddate < ls_travel-begindate AND ls_travel-BeginDate IS NOT INITIAL
                                                 AND ls_travel-enddate IS NOT INITIAL.
* if state area is added then pop up will not come
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %state_area = 'Validate Date'
                       %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text = |'End date should not be less than begin date| )
                     %element-begindate = if_abap_behv=>mk-on
                     %element-Enddate = if_abap_behv=>mk-on )  TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatragency.

    DATA : Agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId )
   WITH CORRESPONDING #( keys )
   RESULT DATA(lt_travel).


    Agency = CORRESPONDING #( lt_travel MAPPING Agency_id = AgencyId EXCEPT * ).
    SELECT FROM /dmo/Agency FIELDS Agency_id
    FOR ALL ENTRIES IN @Agency
    WHERE Agency_id =  @Agency-Agency_id
    INTO TABLE @DATA(valid_Agency).


    LOOP AT lt_travel INTO DATA(ls_travel).


      IF ls_travel-AgencyId IS NOT INITIAL AND NOT line_exists( valid_Agency[ Agency_id = ls_travel-AgencyId ] ).

        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                       %state_area = 'Validate Agency'
                       %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text = |'Not valid Agency{ ls_travel-AgencyId }| )
                     %element-Agencyid = if_abap_behv=>mk-on )  TO reported-travel.


      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zbs_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                           (  %tky = ls_travel-%tky
                             %field-bookingfee = COND #( WHEN ls_travel-overallstatus = 'A'
                             THEN IF_abap_behv=>fc-f-read_only
                             ELSE IF_abap_behv=>fc-f-unrestricted )

                       %action-accepttravel =  COND #( WHEN ls_travel-overallstatus = 'A'
                             THEN IF_abap_behv=>fc-o-disabled
                             ELSE IF_abap_behv=>fc-o-enabled )

                        %action-rejecttravel =  COND #( WHEN ls_travel-overallstatus = 'R'
                             THEN IF_abap_behv=>fc-o-disabled
                             ELSE IF_abap_behv=>fc-o-enabled )

                              %action-discount =  COND #( WHEN ls_travel-overallstatus = 'A'
                             THEN IF_abap_behv=>fc-o-disabled
                             ELSE IF_abap_behv=>fc-o-enabled )
                             ) ).


  ENDMETHOD.

ENDCLASS.
