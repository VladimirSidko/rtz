SET TERM ^;

CREATE OR ALTER PROCEDURE AP_PHOTO_DECISION$FIND(
   A_VIOLATION_DATE_FROM        TDATETIME    -- Начальная дата нарушения
  ,A_VIOLATION_DATE_TO          TDATETIME    -- Конечная дата нарушения
  ,A_DECISION_DATE_FROM         TDATETIME    -- Начальная дата решения
  ,A_DECISION_DATE_TO           TDATETIME    -- Конечная дата решения
  ,A_DNZ_NUMBER         TYPE OF TSTRING      -- ДНЗ
  ,A_LAST_NAME          TYPE OF TSTRING      -- Фамилия
  ,A_FIRST_NAME         TYPE OF TSTRING      -- Имя
  ,A_MIDDLE_NAME        TYPE OF TSTRING      -- Отчество
  )
RETURNS (
   PHOTO_DECISION_ID TINTEGER
  ,DECISION_DATE     TDATETIME
  ,INSPECTOR_NAME    TSTRING
  ,OVS_NAME          TSTRING
  ,VIOLATION_DATE    TDATETIME
  ,VIOLATION_PLACE   TSTRING
  ,MARK              TSTRING
  ,MODEL             TSTRING
  ,DNZ_NUMBER        TSTRING
  ,VIOLATOR          TSTRING
  ,ACTUAL_SPEED      TINTEGER
  ,LIMIT_SPEED       TINTEGER
  )
AS
  DECLARE V_SQL TTEXT;
BEGIN

  A_DNZ_NUMBER  = UPPER(COALESCE(:A_DNZ_NUMBER,  ''));
  A_LAST_NAME   = UPPER(COALESCE(:A_LAST_NAME,   ''));
  A_FIRST_NAME  = UPPER(COALESCE(:A_FIRST_NAME,  ''));
  A_MIDDLE_NAME = UPPER(COALESCE(:A_MIDDLE_NAME, ''));

  IF ((:A_VIOLATION_DATE_FROM IS NULL) AND
     (:A_VIOLATION_DATE_TO   IS NULL) AND
     (:A_DECISION_DATE_FROM  IS NULL) AND
     (:A_DECISION_DATE_TO    IS NULL) AND
     (:A_DNZ_NUMBER = '') AND
     (:A_LAST_NAME  = '') AND
     (:A_FIRST_NAME = '') AND
     (:A_MIDDLE_NAME = '')) THEN
    EXCEPTION EX_CUSTOM 'Ви не задали жодного параметру для пошуку';

  V_SQL = '
    SELECT
       D.ID
      ,D.DECISION_DATE
      ,D.INSPECTOR_ID
      ,OVS.NAME
      ,D.VIOLATION_DATE
      ,D.VIOLATION_PLACE
      ,D.MARK
      ,D.MODEL
      ,D.DNZ_NUMBER
      ,D.LAST_NAME || '' '' || D.FIRST_NAME || COALESCE('' '' || D.MIDDLE_NAME, '''')
      ,D.ACTUAL_SPEED
      ,D.LIMIT_SPEED
    FROM AP_PHOTO_DECISION D
      LEFT JOIN C_OVS OVS ON OVS.CODE = D.OVS_CODE
    WHERE 1 = 1
    ';
  IF (:A_VIOLATION_DATE_FROM IS NOT NULL) THEN
    V_SQL = :V_SQL || '
      AND D.VIOLATION_DATE >= ' || :A_VIOLATION_DATE_FROM;
  IF (:A_VIOLATION_DATE_TO IS NOT NULL) THEN
    V_SQL = :V_SQL || '
      AND D.VIOLATION_DATE < ' || :A_VIOLATION_DATE_TO;
  IF (:A_DECISION_DATE_FROM IS NOT NULL) THEN
    V_SQL = :V_SQL || '
      AND D.DECISION_DATE >= ' || :A_DECISION_DATE_FROM;
  IF (:A_DECISION_DATE_TO IS NOT NULL) THEN
    V_SQL = :V_SQL || '
      AND D.DECISION_DATE < ' || :A_DECISION_DATE_TO;
  IF (:A_DNZ_NUMBER <> '') THEN
    V_SQL = :V_SQL || '
      AND UPPER(D.DNZ_NUMBER) LIKE ''' || :A_DNZ_NUMBER || '''';
  IF (:A_LAST_NAME <> '') THEN
    V_SQL = :V_SQL || '
      AND UPPER(D.LAST_NAME) LIKE ''' || :A_LAST_NAME || '''';
  IF (:A_FIRST_NAME <> '') THEN
    V_SQL = :V_SQL || '
      AND UPPER(D.FIRST_NAME) LIKE ''' || :A_FIRST_NAME || '''';
  IF (:A_MIDDLE_NAME <> '') THEN
    V_SQL = :V_SQL || '
      AND UPPER(D.MIDDLE_NAME) LIKE ''' || :A_MIDDLE_NAME || '''';

  FOR
    EXECUTE STATEMENT (:V_SQL)
    INTO
       :PHOTO_DECISION_ID
      ,:DECISION_DATE
      ,:INSPECTOR_NAME
      ,:OVS_NAME
      ,:VIOLATION_DATE
      ,:VIOLATION_PLACE
      ,:MARK
      ,:MODEL
      ,:DNZ_NUMBER
      ,:VIOLATOR
      ,:ACTUAL_SPEED
      ,:LIMIT_SPEED
  DO
    SUSPEND;

END^

SET TERM ;^
