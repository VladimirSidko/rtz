SET TERM ^;

CREATE OR ALTER PROCEDURE SYS_SET_STATISTICS
AS
  DECLARE VARIABLE V_NAME VARCHAR(31);
BEGIN
  FOR
    SELECT
      RDB$INDEX_NAME
    FROM RDB$INDICES
    INTO
      :V_NAME
  DO
    EXECUTE STATEMENT 'SET STATISTICS INDEX '||:V_NAME;
END
^

SET TERM ;^

COMMENT ON PROCEDURE SYS_SET_STATISTICS IS 
'�������� ���������� ���� �������� � ����';

