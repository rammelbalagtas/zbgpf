@EndUserText.label: 'BGPF Messages'
@ObjectModel.query.implementedBy:'ABAP:ZCL_CE_BGPF_MESSAGES'
@UI.headerInfo: {
    typeName: 'Message',
    typeNamePlural: 'Messages'
}

define custom entity ZCE_BGPF_MESSAGES
{
  key uuid         : sysuuid_x16;
      @UI.lineItem  : [ { position: 10, label: 'Sequence', importance: #HIGH } ]
  key sequence     : abap.numc(3);
      inventory_id : abap.numc(6);
      @UI.lineItem  : [ { position: 20, label: 'Message', importance: #HIGH } ]
      message      : abap.string(0);

}
