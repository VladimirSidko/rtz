SET TERM ^;

CREATE OR ALTER PROCEDURE GET_SYS_GRID_COLUMN(
  IID_GRID TSTRING
)
RETURNS (
   FIELD      TSTRING
  ,TITLE      TSTRING
  ,LABEL      TSTRING
  ,WIDTH      TINTEGER
  ,CHECKBOX   TBOOLEAN2
  ,CHECKFLD   TBOOLEAN2
  ,VISIBLE    TBOOLEAN2
  ,FOOT_FNC   TINTEGER -- Non = 0, Sum = 1, Avg = 2, Count = 3, FieldValue = 4, StaticText = 5
  )
AS
  DECLARE ID_GRID TYPE OF TINTEGER;
BEGIN
  SELECT ID
  FROM SYS_GRID
  WHERE UPPER(IID) = UPPER(:IID_GRID)
  INTO :ID_GRID;

  IF (:ID_GRID IS NULL) THEN
    EXCEPTION EX_CUSTOM 'Грид с идентификатором "' || :IID_GRID || '" не найден!!!';

  FOR
    SELECT
       col.FIELD
      ,col.TITLE
      ,col.LABEL
      ,grd.WIDTH
      ,col.CHECKBOX
      ,1 AS CHECKFLD
      ,grd.VISIBLE
      ,grd.FOOT_FNC
    FROM SYS_COLUMN col
      JOIN SYS_GRID_COLUMN grd ON grd.ID_COLUMN = col.ID
    WHERE grd.ID_GRID = :ID_GRID
    ORDER BY grd.SORT_ORDER
    INTO
       :FIELD
      ,:TITLE
      ,:LABEL
      ,:WIDTH
      ,:CHECKBOX
      ,:CHECKFLD
      ,:VISIBLE
      ,:FOOT_FNC
  DO
    SUSPEND;
END
^

SET TERM ;^
