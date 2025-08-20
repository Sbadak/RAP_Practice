@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking supplement projection view'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity zbs_booking_c as projection on zbs_booking_i
{
    key BookingUuid,
    TravelUuid,
    BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _Bookingsupplements : redirected to composition child ZBS_BOOKING_SUPL_C,
    _Travel :redirected to parent zbs_travel_c
}
