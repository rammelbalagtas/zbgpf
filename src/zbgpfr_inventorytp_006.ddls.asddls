@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forInventory'
@ObjectModel.sapObjectNodeType.name: 'ZBGPFInventory_006'
define root view entity ZBGPFR_InventoryTP_006
  as select from ZBGPFI_Inventory_006 as Inventory
   association [0..*] to ZCE_BGPF_MESSAGES  as _Messages on $projection.UUID = _Messages.UUID
{
  key UUID,
      InventoryID,
      ProductID,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      Quantity,
      QuantityUnit,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      Remark,
      NotAvailable,
      BgpfStatus,
      HideEdit,
      HideButton1,
      HideButton2,
      HideButton3,
      ExtraField1,
      ExtraField2,
      ProcessStatus,
      BgpgProcessName,
      ApplLogHandle,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      _Messages

}
