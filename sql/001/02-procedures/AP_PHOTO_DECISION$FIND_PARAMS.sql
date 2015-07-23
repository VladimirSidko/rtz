SET TERM ^;

CREATE OR ALTER PROCEDURE AP_PHOTO_DECISION$FIND_PARAMS
RETURNS (
   VIOLATION_DATE_FROM        TDATETIME    -- Начальная дата нарушения
  ,VIOLATION_DATE_TO          TDATETIME    -- Конечная дата нарушения
  ,DECISION_DATE_FROM         TDATETIME    -- Начальная дата решения
  ,DECISION_DATE_TO           TDATETIME    -- Конечная дата решения
  ,DNZ_NUMBER         TYPE OF TSTRING      -- ДНЗ
  ,LAST_NAME          TYPE OF TSTRING      -- Фамилия
  ,FIRST_NAME         TYPE OF TSTRING      -- Имя
  ,MIDDLE_NAME        TYPE OF TSTRING      -- Отчество
  )
AS
BEGIN

  VIOLATION_DATE_FROM = NULL;
  VIOLATION_DATE_TO   = NULL;
  DECISION_DATE_FROM  = NULL;
  DECISION_DATE_TO    = NULL;
  DNZ_NUMBER          = '';
  LAST_NAME           = '';
  FIRST_NAME          = '';
  MIDDLE_NAME         = '';

  SUSPEND;
END^

SET TERM ;^
