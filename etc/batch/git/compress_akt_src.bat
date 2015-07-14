@REM скрипт дл€ подготовки архивов с исходниками дл€ записи на диск прилагаемый к актам выполненных работ
@REM работает только из каталога с извлеченными репозитари€ми
@REM Ќ≈ «јѕ”— ј“№ на рабочем каталоге - затирает рабочие изменени€!

@rem http://cdburnerxp.se/help/Appendices/commandlinearguments
@for /F "tokens=1,2,3  delims=/. " %%a in ('date /T') do set date_name=%%c.%%b.%%a

@SET ROOT=%~dp0

@REM доп. проверка на зпуск в рабочем каталоге!
IF EXIST %ROOT%\3050MDO.GIT\user-distr EXIT 1

CD %ROOT%\3050IDE.GIT
call git checkout -f master
call git pull -f
call git archive --format=zip HEAD > ..\%date_name%_ide.zip

CD %ROOT%\3050IDF.GIT
call git checkout -f master
call git pull -f
call git archive --format=zip HEAD > ..\%date_name%_idf.zip

CD %ROOT%\3050MDO.GIT
call git checkout -f master
call git pull -f
call git archive --format=zip HEAD > ..\%date_name%_mdo.zip


