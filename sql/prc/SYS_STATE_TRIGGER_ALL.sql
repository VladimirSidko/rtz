SET TERM ^;

CREATE OR ALTER PROCEDURE SYS_STATE_TRIGGER_ALL (
    A_STATE VARCHAR(254))
AS
  DECLARE VARIABLE V_STATE    VARCHAR(31);
  DECLARE VARIABLE V_TRIGGER  VARCHAR(31);
BEGIN
  V_STATE = UPPER(TRIM(:A_STATE));

  IF (NOT (:V_STATE = 'INACTIVE' OR :V_STATE = 'ACTIVE')) THEN
    EXCEPTION EX_CUSTOM :V_STATE||' IS NOT INACTIVE OR ACTIVE';

  FOR
    SELECT
      T.RDB$TRIGGER_NAME
    FROM RDB$TRIGGERS T
      JOIN RDB$RELATIONS R ON T.RDB$RELATION_NAME = R.RDB$RELATION_NAME
    WHERE (R.RDB$SYSTEM_FLAG IS NULL OR R.RDB$SYSTEM_FLAG <> 1) AND
           NOT EXISTS (SELECT *
                       FROM RDB$CHECK_CONSTRAINTS CHK
                       WHERE T.RDB$TRIGGER_NAME = CHK.RDB$TRIGGER_NAME)
    INTO
      :V_TRIGGER
  DO
    EXECUTE STATEMENT 'ALTER TRIGGER '||:V_TRIGGER||' '||:V_STATE||'';
END
^

SET TERM ;^

COMMENT ON PROCEDURE SYS_STATE_TRIGGER_ALL IS 
'����������/��������� ���� ��������� � ����';

