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
    ,'Я, інспектор адміністративної практики капітан міліції Шарапов А.А.' ||
     ', розглянувши матеріали про адміністративне правопорушення, скоєне гр. ' ||
     Decision.LAST_NAME || ' ' || Decision.FIRST_NAME || COALESCE(' ' || Decision.MIDDLE_NAME, '') ||
     COALESCE(', ' || CAST(Decision.BIRTHDAY AS TDATE) || ' року народження', '') ||
     COALESCE(', місце народження: ' || Decision.BIRTH_PLACE, '') ||
     COALESCE(', адреса проживання: ' || Decision.REGION_ID || ', вул. ' || Decision.STREET_NAME || ' буд. ' || Decision.HOUSE_NO || ', кв. ' || Decision.FLAT_NO, '') ||
     COALESCE(', документ що засвідчує особу: Паспорт ' || Decision.PASS_NO, '')
    --
    ,CAST(Decision.VIOLATION_DATE AS TDATE) || ' року об ' || CAST(Decision.VIOLATION_DATE AS TTIME) ||
     ', за адресою ' || Decision.VIOLATION_PLACE ||
     ', водій транспортного засобу "' || COALESCE(Decision.MARK, '') || COALESCE(' ' || Decision.MODEL, '') || '"' ||
     ' номерні знаки ' || Decision.DNZ_NUMBER ||
     ', власником якого є ' || Decision.LAST_NAME || ' ' || LEFT(Decision.FIRST_NAME, 1) || '.' || COALESCE(' ' || LEFT(Decision.MIDDLE_NAME, 1) || '.', '') ||
     COALESCE(', рухався зі швидкістю ' || Decision.ACTUAL_SPEED || ' км/год', '') ||
     COALESCE(' в зоні дії дорожнього знаку ' || Decision.TRAFFIC_SIGN, '') ||
     COALESCE(' ' || Decision.LIMIT_SPEED, '') || ' км/год' ||
     COALESCE(' перевищив встановлену швидкість руху на ' || (Decision.ACTUAL_SPEED - Decision.LIMIT_SPEED) || ' км/год', '') ||
     COALESCE(', чим допустив порушення пункту ' || Decision.ROADRULE_NO || ' ПДР України', '') ||
     ', серійний номер приладу ' || Decision.DEVICE_NO || '.'
    --
    ,'Враховуючи, що гр. ' || Decision.LAST_NAME || ' ' || LEFT(Decision.FIRST_NAME, 1) || '.' || COALESCE(' ' || LEFT(Decision.MIDDLE_NAME, 1) || '.', '') ||
     ' скоїв(ла) адміністративне правопорушення, передбачене статею ' || Decision.ARTICLE_NO ||
     ' Кодексу України про адміністративні правопорушення, керуючись положеннями ст. 283 зазначенного Кодексу'
    ,Decision.DEVICE_NAME
    ,Decision.DEVICE_NO
    ,Decision.DEVICE_VALID_DATE
    ,Decision.LAST_NAME || ' ' || Decision.FIRST_NAME || COALESCE(' ' || Decision.MIDDLE_NAME, '')
    ,Decision.REGION_ID || ', вул. ' || Decision.STREET_NAME || ' буд. ' || Decision.HOUSE_NO || ', кв. ' || Decision.FLAT_NO
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
