/* ******* FUNCTIONS (UDF) *************************************************** */

/* ******* TABLES ************************************************************ */

CREATE TABLE AP_PHOTO_FOLDER (
    ID           TSTRING,
    FOLDER       TSTRING,
    ADRESS       TSTRING,
    DEVICE_NAME  TSTRING,
    DEVICE_CODE  TSTRING,
    DEVICE_DATE  TDATETIME
);
COMMIT;

ALTER TABLE AP_PHOTO_FOLDER ADD CONSTRAINT AP_PHOTO_FOLDER$ID PRIMARY KEY (ID);

COMMIT;

