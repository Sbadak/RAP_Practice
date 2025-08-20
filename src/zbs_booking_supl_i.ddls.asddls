@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking supplement interface view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED

}
@VDM.viewType: #BASIC
define view entity ZBS_BOOKING_SUPL_i
  as select from zbs_booking_supl
  association     to parent zbs_booking_i as _Booking on $projection.ParentUuid = _Booking.BookingUuid
  association [1] to zbs_travel_i         as _Travel  on $projection.RootUuid = _Travel.TravelUuid
{
  key booksuppl_uuid        as BooksupplUuid,
      root_uuid             as RootUuid,
      parent_uuid           as ParentUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Booking,
      _Travel
}
