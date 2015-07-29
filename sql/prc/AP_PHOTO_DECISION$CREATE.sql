SET TERM ^;

CREATE OR ALTER PROCEDURE AP_PHOTO_DECISION$CREATE(
  DNZ_NUMBER     TSTRING,
  ACTUAL_SPEED   TINTEGER,
  LIMIT_SPEED    TINTEGER,
  PENALTY        TMONEY,
  VIOLATION_DATE TDATETIME,
  PHOTO          TBINARY
  )
RETURNS (
  ID TYPE OF TINTEGER
   )
AS
  DECLARE NUMBER TYPE OF TSTRING;

  DECLARE DEVICE_NAME TYPE OF TSTRING;
  DECLARE DEVICE_CODE TYPE OF TSTRING;
  DECLARE DEVICE_DATE TYPE OF TDATETIME;

  DECLARE APP_ID      TYPE OF TINTEGER;
  DECLARE MARK        TYPE OF TSTRING;
  DECLARE MODEL       TYPE OF TSTRING;
  DECLARE LAST_NAME   TYPE OF TSTRING;
  DECLARE FIRST_NAME  TYPE OF TSTRING;
  DECLARE MIDDLE_NAME TYPE OF TSTRING;
  DECLARE PASS_NO     TYPE OF TSTRING;
  DECLARE BIRTHDAY    TYPE OF TDATETIME;
  DECLARE BIRTH_PLACE TYPE OF TSTRING;
  DECLARE REGION_ID   TYPE OF TSTRING;
  DECLARE STREET_NAME TYPE OF TSTRING;
  DECLARE HOUSE_NO    TYPE OF TSTRING;
  DECLARE BUILDING_NO TYPE OF TSTRING;
  DECLARE FLAT_NO     TYPE OF TSTRING;

  DECLARE ADRESS       TYPE OF TSTRING;
  DECLARE TRAFFIC_SIGN TYPE OF TSTRING;
  DECLARE ROADRULE_NO  TYPE OF TSTRING;
  DECLARE ARTICLE_NO   TYPE OF TSTRING;

  DECLARE RECIPIENT_NAME TYPE OF TSTRING;
  DECLARE RECIPIENT_OKPO TYPE OF TSTRING;
  DECLARE BANK_MFO       TYPE OF TSTRING;
  DECLARE BANK_ACCOUNT   TYPE OF TSTRING;
BEGIN
  SELECT
     ID
    ,MARK
    ,MODEL
    ,LAST_NAME
    ,FIRST_NAME
    ,MIDDLE_NAME
    ,PASS_NO
    ,BIRTHDAY
    ,BIRTH_PLACE
    ,REGION_ID
    ,STREET_NAME
    ,HOUSE_NO
    ,BUILDING_NO
    ,FLAT_NO
  FROM TR_APPLICATIONS APP
  WHERE APP.DNZ_NUMBER = :DNZ_NUMBER
  INTO
     :APP_ID
    ,:MARK
    ,:MODEL
    ,:LAST_NAME
    ,:FIRST_NAME
    ,:MIDDLE_NAME
    ,:PASS_NO
    ,:BIRTHDAY
    ,:BIRTH_PLACE
    ,:REGION_ID
    ,:STREET_NAME
    ,:HOUSE_NO
    ,:BUILDING_NO
    ,:FLAT_NO;

  IF (ROW_COUNT = 0) THEN
    EXCEPTION EX_CUSTOM '������������ ���� � ������� "' || :DNZ_NUMBER || '" �� �������� � ��� �����.';

  SELECT
     ADRESS
    ,DEVICE_NAME
    ,DEVICE_CODE
    ,DEVICE_DATE
  FROM AP_PHOTO_FOLDER
  WHERE UPPER(ID) = UPPER(CURRENT_USER)
  INTO
     :ADRESS
    ,:DEVICE_NAME
    ,:DEVICE_CODE
    ,:DEVICE_DATE;

  ID = UDF_GUID_SHA();

  TRAFFIC_SIGN   = '3.29 ��������� ����������� �������� ����';
  ROADRULE_NO    = '12.4';
  ARTICLE_NO     = '122.1 ����������� ��Ĳ��� �� ������������ �������� �������Ҳ ���� >20 ��/���';

  RECIPIENT_NAME = '��� � �.���';
  RECIPIENT_OKPO = '24262621';
  BANK_MFO       = '820019';
  BANK_ACCOUNT   = '33111336700001';

  NUMBER = '��-' || LPAD(NEXT VALUE FOR SEQ_PHOTO_DECISION, 7,'0');

  INSERT INTO AP_PHOTO_DECISION (
     ID
    ,ID_APP
    ,NUMBER
    ,PHOTO
    -- DECISION
    ,DECISION_DATE
    ,INSPECTOR_ID
    ,OVS_CODE
    -- VIOLATION
    ,VIOLATION_DATE
    ,VIOLATION_PLACE
    ,TRAFFIC_SIGN
    ,ROADRULE_NO
    ,ARTICLE_NO
    ,LIMIT_SPEED
    ,ACTUAL_SPEED
    ,PENALTY
    -- APPLICATION
    ,MARK
    ,MODEL
    ,DNZ_NUMBER
    ,LAST_NAME
    ,FIRST_NAME
    ,MIDDLE_NAME
    ,PASS_NO
    ,BIRTHDAY
    ,BIRTH_PLACE
    ,REGION_ID
    ,STREET_NAME
    ,HOUSE_NO
    ,BUILDING_NO
    ,FLAT_NO
    -- DEVICE
    ,DEVICE_NAME
    ,DEVICE_NO
    ,DEVICE_VALID_DATE
    -- PAYMENT
    ,RECIPIENT_NAME
    ,RECIPIENT_OKPO
    ,BANK_MFO
    ,BANK_ACCOUNT
  ) VALUES (
     :ID
    ,:APP_ID
    ,:NUMBER
    ,:PHOTO
    -- DECISION
    ,CURRENT_TIMESTAMP
    ,CURRENT_USER
    ,'3333'
    -- VIOLATION
    ,:VIOLATION_DATE
    ,:ADRESS
    ,:TRAFFIC_SIGN
    ,:ROADRULE_NO
    ,:ARTICLE_NO
    ,:LIMIT_SPEED
    ,:ACTUAL_SPEED
    ,:PENALTY
    -- APPLICATION
    ,:MARK
    ,:MODEL
    ,:DNZ_NUMBER
    ,:LAST_NAME
    ,:FIRST_NAME
    ,:MIDDLE_NAME
    ,:PASS_NO
    ,:BIRTHDAY
    ,:BIRTH_PLACE
    ,:REGION_ID
    ,:STREET_NAME
    ,:HOUSE_NO
    ,:BUILDING_NO
    ,:FLAT_NO
    -- DEVICE
    ,:DEVICE_NAME
    ,:DEVICE_CODE
    ,:DEVICE_DATE
    -- PAYMENT
    ,:RECIPIENT_NAME
    ,:RECIPIENT_OKPO
    ,:BANK_MFO
    ,:BANK_ACCOUNT
  );

  SUSPEND;
END^

SET TERM ;^
