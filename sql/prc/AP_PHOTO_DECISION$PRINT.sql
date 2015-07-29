SET TERM ^;

CREATE OR ALTER PROCEDURE AP_PHOTO_DECISION$PRINT(
   A_ID TINTEGER
  )
RETURNS (
   DECISIONNUMBER  TSTRING
  ,DECISIONDATE    TDATE
  ,OVSNAME         TSTRING
  ,HEADER          TSTRING4K
  ,DETERMINE1      TSTRING4K
  ,DETERMINE2      TSTRING4K
  ,DEVICENAME      TSTRING
  ,DEVICENO        TSTRING
  ,DEVICEVALIDDATE TDATE
  ,VIOLATOR        TSTRING4K
  ,VIOLATORADDRESS TSTRING4K
  ,VIOLATIONPLACE  TSTRING
  ,PHOTO           TBINARY
  ,DNZNUMBER       TSTRING
  ,PENALTY         TINTEGER
  ,PENALTYSTR      TSTRING
  ,BANKMFO         TSTRING
  ,BANKACCOUNT     TSTRING
  ,RECIPIENTOKPO   TSTRING
  ,RECIPIENTNAME   TSTRING
  )
AS
BEGIN

  SELECT
     Decision.NUMBER
    ,Decision.DECISION_DATE
    ,Ovs.NAME
    ,'�, ��������� ������������� �������� ������ ����� ������� �.�.' ||
     ', ����������� �������� ��� ������������� ��������������, ����� ��. ' ||
     Decision.LAST_NAME || ' ' || Decision.FIRST_NAME || COALESCE(' ' || Decision.MIDDLE_NAME, '') ||
     COALESCE(', ' || CAST(Decision.BIRTHDAY AS TDATE) || ' ���� ����������', '') ||
     COALESCE(', ���� ����������: ' || Decision.BIRTH_PLACE, '') ||
     COALESCE(', ������ ����������: ' || Decision.REGION_ID || ', ���. ' || Decision.STREET_NAME || ' ���. ' || Decision.HOUSE_NO || ', ��. ' || Decision.FLAT_NO, '') ||
     COALESCE(', �������� �� ������� �����: ������� ' || Decision.PASS_NO, '')
    --
    ,CAST(Decision.VIOLATION_DATE AS TDATE) || ' ���� �� ' || CAST(Decision.VIOLATION_DATE AS TTIME) ||
     ', �� ������� ' || Decision.VIOLATION_PLACE ||
     ', ���� ������������� ������ "' || COALESCE(Decision.MARK, '') || COALESCE(' ' || Decision.MODEL, '') || '"' ||
     ' ������ ����� ' || Decision.DNZ_NUMBER ||
     ', ��������� ����� � ' || Decision.LAST_NAME || ' ' || LEFT(Decision.FIRST_NAME, 1) || '.' || COALESCE(' ' || LEFT(Decision.MIDDLE_NAME, 1) || '.', '') ||
     COALESCE(', ������� � �������� ' || Decision.ACTUAL_SPEED || ' ��/���', '') ||
     COALESCE(' � ��� 䳿 ���������� ����� ' || Decision.TRAFFIC_SIGN, '') ||
     COALESCE(' ' || Decision.LIMIT_SPEED, '') || ' ��/���' ||
     COALESCE(' ��������� ����������� �������� ���� �� ' || (Decision.ACTUAL_SPEED - Decision.LIMIT_SPEED) || ' ��/���', '') ||
     COALESCE(', ��� �������� ��������� ������ ' || Decision.ROADRULE_NO || ' ��� ������', '') ||
     ', ������� ����� ������� ' || Decision.DEVICE_NO || '.'
    --
    ,'����������, �� ��. ' || Decision.LAST_NAME || ' ' || LEFT(Decision.FIRST_NAME, 1) || '.' || COALESCE(' ' || LEFT(Decision.MIDDLE_NAME, 1) || '.', '') ||
     ' ����(��) ������������� ��������������, ����������� ������ ' || Decision.ARTICLE_NO ||
     ' ������� ������ ��� ������������ ��������������, ��������� ����������� ��. 283 ������������ �������'
    ,Decision.DEVICE_NAME
    ,Decision.DEVICE_NO
    ,Decision.DEVICE_VALID_DATE
    ,Decision.LAST_NAME || ' ' || Decision.FIRST_NAME || COALESCE(' ' || Decision.MIDDLE_NAME, '')
    ,Decision.REGION_ID || ', ���. ' || Decision.STREET_NAME || ' ���. ' || Decision.HOUSE_NO || ', ��. ' || Decision.FLAT_NO
    ,Decision.VIOLATION_PLACE
    ,Decision.PHOTO
    ,Decision.DNZ_NUMBER
    ,Decision.PENALTY
    ,UDF_UAHTOSTR(Decision.PENALTY)
    ,Decision.BANK_MFO
    ,Decision.BANK_ACCOUNT
    ,Decision.RECIPIENT_OKPO
    ,Decision.RECIPIENT_NAME
  FROM AP_PHOTO_DECISION Decision
    JOIN C_OVS Ovs on Decision.OVS_CODE = Ovs.CODE
  WHERE Decision.ID = :A_ID
  INTO
     :DECISIONNUMBER
    ,:DECISIONDATE
    ,:OVSNAME
    ,:HEADER
    ,:DETERMINE1
    ,:DETERMINE2
    ,:DEVICENAME
    ,:DEVICENO
    ,:DEVICEVALIDDATE
    ,:VIOLATOR
    ,:VIOLATORADDRESS
    ,:VIOLATIONPLACE
    ,:PHOTO
    ,:DNZNUMBER
    ,:PENALTY
    ,:PENALTYSTR
    ,:BANKMFO
    ,:BANKACCOUNT
    ,:RECIPIENTOKPO
    ,:RECIPIENTNAME;

  SUSPEND;

END^

SET TERM ;^
