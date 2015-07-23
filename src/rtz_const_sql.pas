unit rtz_const_sql;

interface


resourcestring
  sql_mdo_empty_select = 'SELECT 1 FROM RDB$DATABASE;';
  //
  SSysLangResGetFullSQL = 'SELECT STRINGS FROM SYS_LANG_RES$GET_FULL';
  //
  SGET_SYS_GRID_COLUMN = 'SELECT * FROM GET_SYS_GRID_COLUMN(:CODE_GRID)';
  SGET_SYS_GRID_EDIT   = 'SELECT * FROM GET_SYS_GRID_EDIT(:CODE_GRID)';
  //
  SGET_SYS_GRID_EDIT_2 = 'SELECT * FROM GET_SYS_GRID_EDIT_2(:CODE_GRID)';

  SSYS_PREF_BINARY_SET = 'EXECUTE PROCEDURE SYS_PREF_BINARY$SET(:NAME, :PREF_VALUE)';
  SSYS_PREF_BINARY_GET = 'SELECT PREF_VALUE FROM SYS_PREF_BINARY$GET(:NAME)';

  sql_ap_photo_folder_get = 'SELECT * FROM AP_PHOTO_FOLDER$GET';
  sql_ap_photo_folder_upd = 'EXECUTE PROCEDURE AP_PHOTO_FOLDER$UPD(:FOLDER,:ADRESS,:DEVICE_NAME,:DEVICE_CODE,:DEVICE_DATE)';

  sql_ap_photo_decision_create = 'EXECUTE PROCEDURE AP_PHOTO_DECISION$CREATE(:DNZ_NUMBER, :ACTUAL_SPEED, :LIMIT_SPEED, :PENALTY, :VIOLATION_DATE, :PHOTO)';

  sql_ap_photo_find_param_get = 'SELECT * FROM AP_PHOTO_DECISION$FIND_PARAMS';
  sql_ap_photo_find_get = 'SELECT * FROM AP_PHOTO_DECISION$FIND(:VIOLATION_DATE_FROM,:VIOLATION_DATE_TO,:DECISION_DATE_FROM,:DECISION_DATE_TO,:DNZ_NUMBER,:LAST_NAME,:FIRST_NAME,:MIDDLE_NAME)';
  sql_ap_photo_find_get_row = 'SELECT * FROM AP_PHOTO_DECISION$FIND(:ID)';

implementation

end.
