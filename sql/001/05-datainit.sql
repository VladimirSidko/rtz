INSERT INTO C_OVS (ID, CODE, NAME) VALUES (1, '1111', '���� ������������ �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (2, '2222', '���� �Ͳ���������� �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (3, '3333', '���� ����������� �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (4, '4444', '���� ������������ �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (5, '5555', '���� ������ȯ������ �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (6, '6666', '���� �������������� �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (7, '7777', '���� ���Ͳ������ �-��');
INSERT INTO C_OVS (ID, CODE, NAME) VALUES (8, '8888', '���� ����̲������� �-��');
COMMIT;

EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0010��', '������', '�����', '������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0011��', '������', '�����', '������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0012��', '������', '�����', '�����������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0013��', '������', '�������', '��������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0014��', '������', '���4', '�������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0015��', '����', 'A1', '��������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0016��', '����', 'A2', '�������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0017��', '����', 'A3', '����', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0018��', '����', 'A4', '�������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0019��', '����', 'A5', '����������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0020��', '����', 'A6', '������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0021��', '����', 'A8', '������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0022��', '����', 'Q3', '�������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0023��', '����', 'Q5', '������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
EXECUTE PROCEDURE TR_APPLICATIONS$CREATE('��0024��', '����', 'Q7', '��������', '����', '��������', '��010203', '01.03.1999', '����', '�.����', '���������', '21', '', '123');
COMMIT;

EXECUTE PROCEDURE SYS_LANG_RESOURCE$INS('SSearch', '�����', '�����', '�����');
EXECUTE PROCEDURE SYS_LANG_RESOURCE$INS('str_mdo_save_settings', '�������� ������������', '��������� ���������', '��������� ���������');
COMMIT
