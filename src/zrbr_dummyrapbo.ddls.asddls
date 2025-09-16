@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZRBDUMMYRAPBO'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZRBR_DUMMYRAPBO
  as select from zdummyrapbo as DummyEntity
{
  key uuid as UUID,
  inventory_id as InventoryID,
  product_id as ProductID,
  field1 as Field1,
  field2 as Field2,
  field3 as Field3,
  @Semantics.user.createdBy: true
  localcreatedby as Localcreatedby,
  @Semantics.systemDateTime.createdAt: true
  localcreatedat as Localcreatedat,
  @Semantics.user.localInstanceLastChangedBy: true
  locallastchangedby as Locallastchangedby,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as Locallastchangedat,
  @Semantics.systemDateTime.lastChangedAt: true
  lastchangedat as Lastchangedat
}
