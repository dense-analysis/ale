@echo off
REM Run tests on Windows.
REM
REM Set the VIM_EXE environment variable to the path to the Vim or Neovim
REM executable. If not set, the default path for the old AppVeyor setup will
REM be used.
REM
REM Set VIM_HEADLESS to --headless for Neovim.

set tests=test/*.vader test/*/*.vader test/*/*/*.vader test/*/*/*/*.vader

REM Use the first argument for selecting tests to run.
if not "%1"=="" set tests=%1

REM VIM_EXE can be set externally (e.g., by GitHub Actions).
if "%VIM_EXE%"=="" set VIM_EXE=C:\vim\vim\vim80\vim.exe

REM VIM_HEADLESS can be set for Neovim (--headless).
REM For Vim, --not-a-term prevents E211 and terminal warnings in CI.
if "%VIM_HEADLESS%"=="" set VIM_HEADLESS=--not-a-term

set VADER_OUTPUT_FILE=%~dp0\vader_output
REM Automatically re-run Windows tests, which can fail some times.
set tries=0

:RUN_TESTS
set /a tries=%tries%+1
type nul > "%VADER_OUTPUT_FILE%"
"%VIM_EXE%" -n -i NONE -u test/vimrc %VIM_HEADLESS% "+Vader! %tests%"
set code=%ERRORLEVEL%

IF %code% EQU 0 GOTO :SHOW_RESULTS
IF %tries%  GEQ 2 GOTO :SHOW_RESULTS
GOTO :RUN_TESTS

:SHOW_RESULTS
type "%VADER_OUTPUT_FILE%"
del "%VADER_OUTPUT_FILE%"

exit /B %code%
