CLASS zbs_eml_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*METHODS simple_form_eml_create.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbs_eml_class IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


*-> EML CREATE

*-> Case 1 Creating Entity for Travel CDS only

* The %cid value will automatically assign the UUID for us. Any name can be given here, such as Dummy1
    MODIFY ENTITY Zbs_TRAVEL_I
    CREATE
    SET FIELDS WITH VALUE #( ( %cid = 'Dummy1'
                            AgencyId = '4'
                            CustomerId = '4'
                            TravelId = '4'
                            TotalPrice = 2000
                            CurrencyCode = 'INR'
                            OverallStatus = 'A'
                            BookingFee = 100
                            Description = 'New cusotmer travel'
                            BeginDate = cl_abap_context_info=>get_system_date( )
                            EndDate   = cl_abap_context_info=>get_system_date( ) + 2 ) )

    FAILED DATA(lt_create_failed)
    REPORTED DATA(lt_create).
    COMMIT ENTITIES
    RESPONSE OF zbs_travel_i
    FAILED DATA(lt_create_failed1)
    REPORTED DATA(lt_create1).
    out->write( 'case1 : New travel record Created successfully' ).

*-> Case 2 Creating Entity for Booking CDS with Travel
    MODIFY ENTITY zbs_travel_i
    CREATE
    FIELDS ( AgencyId CustomerId TravelId TotalPrice CurrencyCode  OverallStatus  BookingFee Description BeginDate EndDate    )
     WITH VALUE #( ( %cid = 'Dummy2'
                            AgencyId = '5'
                            CustomerId = '5'
                            TravelId = '5'
                            TotalPrice = 2000
                            CurrencyCode = 'INR'
                            OverallStatus = 'A'
                            BookingFee = 100
                            Description = 'MH TO HYD'
                            BeginDate = cl_abap_context_info=>get_system_date( )
                            EndDate   = cl_abap_context_info=>get_system_date( ) + 2 ) )
    CREATE BY \_Booking FIELDS ( BookingId BookingStatus CarrierId ConnectionId
    CurrencyCode CustomerId FlightDate FlightPrice BookingDate )
    WITH VALUE #( ( %cid_ref = 'Dummy2'
    %target = VALUE #( (   %cid = 'Dummybooking'
                       BookingId = '10'
                       CarrierId = '10'
                       ConnectionId = '10'
                            CurrencyCode = 'INR'
                            BookingStatus = 'O'
                            FlightPrice = 100
                            FlightDate = cl_abap_context_info=>get_system_date( )
                            BookingDate = cl_abap_context_info=>get_system_date(  ) + 3
                            CustomerId = '6' ) ) ) )



    FAILED FINAL(lt_create_failed2)
    REPORTED FINAL(lt_create2)
    MAPPED FINAL(lt_createmapped2).

    COMMIT ENTITIES
    RESPONSE OF zbs_travel_i
    FAILED DATA(lt_create_failed3)
    REPORTED DATA(lt_create3).
    out->write( 'case2 : New travel and booking record Created successfully' ).


*case 3 .


    MODIFY ENTITY zbs_travel_i
       CREATE
       FIELDS ( AgencyId CustomerId TravelId TotalPrice CurrencyCode  OverallStatus  BookingFee Description BeginDate EndDate    )
        WITH VALUE #( ( %cid = 'Dummy6'
                               AgencyId = '5'
                               CustomerId = '5'
                               TravelId = '5'
                               TotalPrice = 2000
                               CurrencyCode = 'INR'
                               OverallStatus = 'A'
                               BookingFee = 100
                               Description = 'MH TO HYD'
                               BeginDate = cl_abap_context_info=>get_system_date( )
                               EndDate   = cl_abap_context_info=>get_system_date( ) + 2 )

                             ( %cid = 'Dummy7'
                               AgencyId = '6'
                               CustomerId = '6'
                               TravelId = '6'
                               TotalPrice = 2000
                               CurrencyCode = 'INR'
                               OverallStatus = 'A'
                               BookingFee = 100
                               Description = 'MH TO HYD'
                               BeginDate = cl_abap_context_info=>get_system_date( )
                               EndDate   = cl_abap_context_info=>get_system_date( ) + 2 ) )



       CREATE BY \_Booking FIELDS ( BookingId BookingStatus CarrierId ConnectionId
       CurrencyCode CustomerId FlightDate FlightPrice BookingDate )
       WITH VALUE #( ( %cid_ref = 'Dummy6'
       %target = VALUE #( (   %cid = 'Dummybooking'
                          BookingId = '10'
                          CarrierId = '10'
                          ConnectionId = '10'
                               CurrencyCode = 'INR'
                               BookingStatus = 'O'
                               FlightPrice = 100
                               FlightDate = cl_abap_context_info=>get_system_date( )
                               BookingDate = cl_abap_context_info=>get_system_date(  ) + 3
                               CustomerId = '6'  )

                            ( %cid = 'Dummybooking1'
                          BookingId = '11'
                          CarrierId = '11'
                          ConnectionId = '11'
                               CurrencyCode = 'INR'
                               BookingStatus = 'O'
                               FlightPrice = 100
                               FlightDate = cl_abap_context_info=>get_system_date( )
                               BookingDate = cl_abap_context_info=>get_system_date(  ) + 3
                               CustomerId = '6' )

                                ( %cid = 'Dummybooking2'
                          BookingId = '12'
                          CarrierId = '12'
                          ConnectionId = '12'
                               CurrencyCode = 'INR'
                               BookingStatus = 'O'
                               FlightPrice = 100
                               FlightDate = cl_abap_context_info=>get_system_date( )
                               BookingDate = cl_abap_context_info=>get_system_date(  ) + 3
                               CustomerId = '6' ) ) )

      ( %cid_ref = 'Dummy7'
      %target = VALUE #( ( %cid = 'Dummybooking4'
                          BookingId = '13'
                          CarrierId = '13'
                          ConnectionId = '13'
                               CurrencyCode = 'INR'
                               BookingStatus = 'O'
                               FlightPrice = 100
                               FlightDate = cl_abap_context_info=>get_system_date( )
                               BookingDate = cl_abap_context_info=>get_system_date(  ) + 3
                               CustomerId = '6' ) ) ) )


       FAILED FINAL(lt_create_fail4)
       REPORTED FINAL(lt_create_reported4)
       MAPPED FINAL(lt_create_mappe4).

    COMMIT ENTITIES
    RESPONSE OF zdes_travel_i
    FAILED DATA(lt_commit_failed5)
    REPORTED DATA(lt_commit_reported6).

    out->write( 'Case2 v2: Trips and reservations for these trips have been created!' ).






  ENDMETHOD.
ENDCLASS.
