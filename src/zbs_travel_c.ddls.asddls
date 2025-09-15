@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view top of interface view'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity zbs_travel_c
  provider contract transactional_query as projection on zbs_travel_i
{
    key TravelUuid,
    TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
  //  @Consumption.valueHelpDefinition: [{enabled: 'TotalPrice'}]
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    CreatedBy,
    CreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Booking :redirected to composition child zbs_booking_c
}
