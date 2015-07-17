SET TERM ^;

CREATE OR ALTER PROCEDURE GET_SYS_GRID_EDIT(
  CODE_GRID TSTRING
  )
RETURNS (
   FIELD              TSTRING
  ,TITLE              TSTRING
  ,LABEL              TSTRING
  ,CONTROL_TYPE       TSTRING
  ,FIELD_WIDTH        TINTEGER
  ,FIELD_HEIGHT       TINTEGER
  ,FIELD_NEWL         TBOOLEAN2
  ,FIELD_NEWT         TBOOLEAN2
  ,REQUIRED           TBOOLEAN2
  ,CLONE_ABLE         TBOOLEAN2
  ,LOOKUP_FIELD_VALUE TSTRING
  ,LOOKUP_LIST_KEY    TSTRING
  ,LOOKUP_LIST_VALUE  TSTRING
  ,LOOKUP_IID         TSTRING
  ,LOOKUP_SQL         TSTRING
  ,LOOKUP_SQL_NAME    TSTRING
  ,LOOKUP_SQL_MASTER  TSTRING
  )
AS
  DECLARE ID_GRID TYPE OF TINTEGER;
BEGIN
  SELECT ID
  FROM SYS_GRID
  WHERE UPPER(IID) = UPPER(:CODE_GRID)
  INTO :ID_GRID;

  IF (:ID_GRID IS NULL) THEN
    EXCEPTION EX_CUSTOM '���� � ��������������� "' || :CODE_GRID || '" �� ������!!!';

  FOR
    SELECT
       col.FIELD
      ,col.TITLE
      ,col.LABEL
      ,edt.CONTROL_TYPE
      ,edt.FIELD_WIDTH
      ,edt.FIELD_HEIGHT
      ,edt.FIELD_NEWL
      ,edt.FIELD_NEWT
      ,edt.REQUIRED
      ,edt.CLONE_ABLE
      ,edt.LOOKUP_FIELD_VALUE
      ,edt.LOOKUP_LIST_KEY
      ,edt.LOOKUP_LIST_VALUE
      ,edt.LOOKUP_IID
      ,edt.LOOKUP_SQL
      ,edt.LOOKUP_SQL_NAME
      ,edt.LOOKUP_SQL_MASTER
    FROM SYS_COLUMN col
      JOIN SYS_GRID_EDIT edt ON edt.ID_COLUMN = col.ID
    WHERE edt.ID_GRID = :ID_GRID
    ORDER BY edt.SORT_ORDER
    INTO
       :FIELD
      ,:TITLE
      ,:LABEL
      ,:CONTROL_TYPE
      ,:FIELD_WIDTH
      ,:FIELD_HEIGHT
      ,:FIELD_NEWL
      ,:FIELD_NEWT
      ,:REQUIRED
      ,:CLONE_ABLE
      ,:LOOKUP_FIELD_VALUE
      ,:LOOKUP_LIST_KEY
      ,:LOOKUP_LIST_VALUE
      ,:LOOKUP_IID
      ,:LOOKUP_SQL
      ,:LOOKUP_SQL_NAME
      ,:LOOKUP_SQL_MASTER
  DO
    SUSPEND;
END
^

SET TERM ;^
