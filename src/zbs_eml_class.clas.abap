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
                        Description = 'New cusotmer travel'
                        BeginDate = cl_abap_context_info=>get_system_date( )
                        EndDate   = cl_abap_context_info=>get_system_date( ) + 2 ) )

FAILED DATA(lt_create_failed)
REPORTED data(lt_create).
commit ENTITIES
RESPONSE OF zbs_travel_i
FAILED data(lt_create_failed1)
REPORTED data(lt_create1).
out->write( 'case1 : New travel record Created successfully' ).

*-> Case 2 Creating Entity for Booking CDS with Travel

  ENDMETHOD.
ENDCLASS.
