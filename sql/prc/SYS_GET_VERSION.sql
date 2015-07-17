SET TERM ^ ;

CREATE OR ALTER PROCEDURE SYS_GET_VERSION
RETURNS (
    META_VER TINTEGER,
    SYNC_VER TINTEGER)
AS
BEGIN
  SELECT FIRST 1
    sv.ID, sv.ID_VER_SYNC
  FROM SYS_VER SV
  ORDER BY SV.ID DESC
  INTO :META_VER, :SYNC_VER;

  META_VER = COALESCE(META_VER, -1);
  SYNC_VER = COALESCE(SYNC_VER, -1);

  SUSPEND;
END
^

SET TERM ; ^
