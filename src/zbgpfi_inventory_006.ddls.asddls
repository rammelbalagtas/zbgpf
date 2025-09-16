@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Basic Interface View forInventory'
define view entity ZBGPFI_Inventory_006
  as select from zbgpf_inven_006 as Inventory
{
  key uuid                  as UUID,
      inventory_id          as InventoryID,
      product_id            as ProductID,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      quantity              as Quantity,
      quantity_unit         as QuantityUnit,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      remark                as Remark,
      not_available         as NotAvailable,
      bgpf_status           as BgpfStatus,
      process_status        as ProcessStatus,
      hideedit              as HideEdit,
      hidebutton1           as HideButton1,
      hidebutton2           as HideButton2,
      hidebutton3           as HideButton3,
      extrafield1           as ExtraField1,
      extrafield2           as ExtraField2,
      bgpg_process_name     as BgpgProcessName,
      appl_log_handle       as ApplLogHandle,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}
