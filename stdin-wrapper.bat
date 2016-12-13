@echo off

REM Get a unique directory name in the temporary directory
:loop
set "directory=%tmp%\ale_%RANDOM%"
if exist "%directory%" goto :loop

REM Use a filename with the same file extension
mkdir "%directory%"
set filename="%directory%\file%1"

REM Get all arguments after the first to run as a command
for /f "tokens=1,* delims= " %%a in ("%*") do set command_args=%%b

REM Read all stdin data to the filename
more > "%filename%"

REM Run the command on the file
%command_args% "%filename%"

REM Delete the temporary directory
rmdir "%directory%" /s /q
