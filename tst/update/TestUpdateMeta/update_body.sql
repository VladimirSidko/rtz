CREATE TABLE TST_TestUpdateMeta (
  ID TPRIMARY
);
COMMIT;

UPDATE M_FORM_REG T SET T.ID = T.ID WHERE T.ID <> 0;
COMMIT;