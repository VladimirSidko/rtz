unit rtz_const_sql;

interface


resourcestring
  sql_mdo_empty_select = 'SELECT 1 FROM RDB$DATABASE;';
  //
  SSysLangResGetFullSQL = 'SELECT STRINGS FROM SYS_LANG_RES$GET_FULL';
  //
  SDtsStateGetSQL = 'SELECT * FROM DTS_STATE_GET';
  //
  SRPLEntityAllowedSQL = 'SELECT ALLOWED FROM RPL_ENTITY_IMPORT$ALLOWED(:A_ENTITY_NAME, :A_KEY)';
  SRPLMDeleteAfterImport = 'EXECUTE PROCEDURE RPL_APPLY_REMOVAL';
  //
  SGET_SYS_GRID_COLUMN = 'SELECT * FROM GET_SYS_GRID_COLUMN(:CODE_GRID)';
  SGET_SYS_GRID_EDIT   = 'SELECT * FROM GET_SYS_GRID_EDIT(:CODE_GRID)';
  //
  SGET_SYS_GRID_EDIT_2 = 'SELECT * FROM GET_SYS_GRID_EDIT_2(:CODE_GRID)';

  SSYS_PREF_BINARY_SET = 'EXECUTE PROCEDURE SYS_PREF_BINARY$SET(:NAME, :PREF_VALUE)';
  SSYS_PREF_BINARY_GET = 'SELECT PREF_VALUE FROM SYS_PREF_BINARY$GET(:NAME)';

implementation

end.
