@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZRBDUMMYRAPBO'
}
@AccessControl.authorizationCheck: #CHECK
define root view entity ZRBC_DUMMYRAPBO
  provider contract transactional_query
  as projection on ZRBR_DUMMYRAPBO
  association [1..1] to ZRBR_DUMMYRAPBO as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  InventoryID,
  ProductID,
  Field1,
  Field2,
  Field3,
  @Semantics: {
    user.createdBy: true
  }
  Localcreatedby,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  Localcreatedat,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  Locallastchangedby,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  Locallastchangedat,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  Lastchangedat,
  _BaseEntity
}
