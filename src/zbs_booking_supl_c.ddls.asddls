@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking supplement projection view'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZBS_BOOKING_SUPL_C as projection on ZBS_BOOKING_SUPL_i
{
    key BooksupplUuid,
    RootUuid,
    ParentUuid,
    BookingSupplementId,
    SupplementId,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking :redirected to parent zbs_booking_c,
    _Travel : redirected to zbs_travel_c
}
