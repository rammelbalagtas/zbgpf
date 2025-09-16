@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forInventory'
define root view entity ZBGPFI_InventoryTP_006
  provider contract transactional_interface
  as projection on ZBGPFR_InventoryTP_006 as Inventory
{
  key UUID,
      InventoryID,
      ProductID,
      Quantity,
      QuantityUnit,
      Price,
      CurrencyCode,
      Remark,
      HideEdit,
      HideButton1,
      HideButton2,
      HideButton3,
      ExtraField1,
      ExtraField2,
      NotAvailable,
      BgpfStatus,
      ProcessStatus,
      BgpgProcessName,
      ApplLogHandle,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Messages

}
