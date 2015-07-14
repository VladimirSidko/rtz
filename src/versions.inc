inc_fdb_version    = '001';
inc_sync_version   = '001';
inc_fb_version     = '2.5.2.26539';
inc_app_version    = '1.0.0.0';
inc_need_br_before = False;
inc_need_br_after  = False;

type
  TMetaVerRec = record
    MetaVer: Integer;
    SyncVer: Integer;
    BinInfo: string[8];
  end;

const
  UpdMetaSchema: array[0..0] of TMetaVerRec = (
    (MetaVer: 1; SyncVer: 1; BinInfo: '1.0.0.0')
  );
