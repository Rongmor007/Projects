@ECHO OFF
SET err_msg="An error occurred while generating the report... You may have entered incorrect input parameters. Please re-enter them."
SET head_of_err=ERROR
:begin
rem Проверка, что не была нажата отмена
cd "C:\avs\tgen\out"
set /P XML_file=< C:\avs\tgen\python\temp\param_out.txt

IF "%XML_file%"=="" (
	pause
	rem Переход к концу исполняемого сценария
	GoTo :eof
)
cd "C:\avs\tgen\tex"
py "C:\avs\tgen\python\generate_report.py" KPA.tex KPA.gen.tex bat | findstr "Serial Number: " > C:\avs\tgen\python\temp\serial_num.txt
set /P name=< C:\avs\tgen\python\temp\serial_num.txt
IF "%name%"=="" (
	rem ECHO An error occurred while generating the report... You may have entered incorrect input parameters. Please re-enter them.
	rem Следующее обнуление переменной нужно, так как при наличии пустой строки на входе команды SET /P XML_file значение переменной не изменяется
	rem SET "XML_file="
	CALL :show_msg %head_of_err% %err_msg% XML_file
	GoTo :eof
)
rem Вызов функции извлечения пути к папке из пути к файлу в переменную XML_dir
CALL :dir_path_from_file_path XML_dir "%XML_file%"
rem Последний обратный слеш экранирует вторую кавычку, поэтому его нужно убрать
xelatex -interaction=nonstopmode -output-directory="%XML_dir:~0,-1%" -aux-directory= -job-name=KPA KPA.gen.tex
xelatex -interaction=nonstopmode -output-directory="%XML_dir:~0,-1%" -aux-directory= -job-name=KPA KPA.gen.tex
xelatex -interaction=nonstopmode -output-directory="%XML_dir:~0,-1%" -aux-directory= -job-name=KPA KPA.gen.tex

IF NOT EXIST "%XML_dir%KPA.pdf" (
	CALL :show_msg %head_of_err% %err_msg% XML_file
	GoTo :eof
)

Setlocal EnableDelayedExpansion
set d1=2020-12-12
set t1=18:18:18
set /A i=1
@FOR /F %%x in ('findstr /B /V /C:# "C:\avs\tgen\python\temp\headers.txt"') do (
	if !i!==1 (
		set d1=%%x
	)
	if !i!==2 (
		set t1=%%x
	)
	set /A i=i+1
)
set name=Bios_%name:~15%_!d1!_!t1::=-!
echo %name%>C:\avs\tgen\python\temp\rename_file.txt
if EXIST "%XML_dir%!name!.pdf" (
	set /A i=1
	:while
	set dopName=!name!_!i!
	set /A i=i+1
	if EXIST "%XML_dir%!dopName!.pdf" (
		GoTo :while
	) ELSE set name=!dopName!
)

RENAME "%XML_dir%KPA.pdf" "!name!.pdf"
@REM move "%XML_dir%KPA.pdf" "!name!.pdf"

CALL :show_msg SUCCESS "The PDF report file has been successfully generated in the path '%XML_dir%!name!.pdf'." XML_file
py "C:\avs\tgen\python\pdf_to_doc.py"

start "" "C:\avs\tgen\out"

GoTo :eof
rem Функция извлечения пути к папке из пути к файлу
:dir_path_from_file_path <resultVar> <filePath>
(
	set %~1=%~dp2
	rem завершение работы функции с передачей 0 в качестве кода ошибки
	EXIT /B
)
rem Функция вывода сообщения с удалением переменной
:show_msg <head_of_msg> <msg> <VarToDel>
(
	ECHO --------------------"%~1"--------------------
	ECHO %~2
	ECHO -----------------------------------------------
	rem Следующее обнуление (удаление) переменной нужно, так как при пустой строке на входе команды SET /P значение XML_file не изменяется
	SET "%~3="
	EXIT /B
)
endlocal
