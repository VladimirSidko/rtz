@REM ������ ��� ��������� ��������� GIT. ����������� ���� ���. 
@REM ������� ������� ����������� ����� � email

call git config --global user.name "Nikolay Ponomarenko"
call git config --global user.email "pnv82g@gmail.com"

call git config --global alias.ch checkout
call git config --global alias.br branch
call git config --global alias.st status

call git config --global color.status auto
call git config --global color.branch auto

rem �������� ���� � �������� ����������� �� ���������� ������� �������� ��� push:
call git config --global diff.renamelimit "0"
call git config --global pack.threads "0"