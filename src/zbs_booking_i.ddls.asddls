@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view booking'
@VDM.viewType: #BASIC
define view entity zbs_booking_i
  as select from zbs_booking
  composition [0..*] of ZBS_BOOKING_SUPL_i as _Bookingsupplements
  association to parent zbs_travel_i       as _Travel on $projection.TravelUuid = _Travel.TravelUuid
{
  key booking_uuid    as BookingUuid,
      parent_uuid     as TravelUuid,
      booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      _Bookingsupplements,
      _Travel
      //_Travel // Make association public
}
