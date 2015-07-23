SET TERM ^;

CREATE OR ALTER PROCEDURE AP_PHOTO_DECISION$FIND_PARAMS
RETURNS (
   VIOLATION_DATE_FROM        TDATETIME    -- ��������� ���� ���������
  ,VIOLATION_DATE_TO          TDATETIME    -- �������� ���� ���������
  ,DECISION_DATE_FROM         TDATETIME    -- ��������� ���� �������
  ,DECISION_DATE_TO           TDATETIME    -- �������� ���� �������
  ,DNZ_NUMBER         TYPE OF TSTRING      -- ���
  ,LAST_NAME          TYPE OF TSTRING      -- �������
  ,FIRST_NAME         TYPE OF TSTRING      -- ���
  ,MIDDLE_NAME        TYPE OF TSTRING      -- ��������
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
