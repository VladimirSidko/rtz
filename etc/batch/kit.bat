@REM ������ ��� ���������� distr-kit ����� �������
@REM �������� �� ����� �������!

@SET CALL_ROOT=%~dp0
@SET Define=Debug

CD %CALL_ROOT%\3050IDE.GIT\cmd
call 01-distr-kit.cmd

CD %CALL_ROOT%\3050IDF.GIT\cmd
call 01-distr-kit.cmd

CD %CALL_ROOT%\3050MDO.GIT\cmd
rem ��� �� ��� ��
call 01-distr-mdo.cmd
rem call 01-distr-mds.cmd

