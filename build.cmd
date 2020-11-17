@echo off
setlocal

set FAMILY=SourceCodePro
set ROMAN_WEIGHTS=Black Bold ExtraLight Light Medium Regular Semibold
set ITALIC_WEIGHTS=BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt

:: find makeotf
for /f %%a in ('where makeotf') do set MAKEOTF_PATH=%%a
if "%MAKEOTF_PATH%" == "" goto error_makeotf_not_found

call :GetDirectoryName PYTHON_PATH "%MAKEOTF_PATH%"
set PYTHON_PATH=%PYTHON_PATH%Python\AFDKOPython27\python.exe

set TARGET_PATH=%~dp0\target\
set TARGET_OTF_PATH=%TARGET_PATH%OTF\
set TARGET_TTF_PATH=%TARGET_PATH%TTF\

if exist "%TARGET_PATH%" rmdir /s /q "%TARGET_PATH%"
mkdir "%TARGET_OTF_PATH%"
mkdir "%TARGET_TTF_PATH%"

set x=%ROMAN_WEIGHTS%
:loop_roman
for /f "tokens=1*" %%a in ("%x%") do (
    call :build_font Roman %%a
    set x=%%b
)
if defined x goto :loop_roman

set x=%ITALIC_WEIGHTS%
:loop_italic
for /f "tokens=1*" %%a in ("%x%") do (
    call :build_font Italic %%a
    set x=%%b
)
if defined x goto :loop_italic

endlocal
goto :eof

:: Build Font
:: %1 - Roman/Italic
:: %2 - Weight
:build_font
call makeotf -f "%~dp0\%1\Instances\%2\font.ufo" -r -ci "%~dp0\uvs.txt" -o "%TARGET_OTF_PATH%\%FAMILY%-%2.otf"
call makeotf -f "%~dp0\%1\Instances\%2\font.ttf" -r -ci "%~dp0\uvs.txt" -o "%TARGET_TTF_PATH%\%FAMILY%-%2.ttf" -ff "%~dp0\%1\Instances\%2\font.ufo\features.fea"
:: "%PYTHON_PATH%" "%~dp0\addSVGtable.py" "%TARGET_OTF_PATH%\%FAMILY%-%2.otf" "%~dp0\svg"
:: "%PYTHON_PATH%" "%~dp0\addSVGtable.py" "%TARGET_TTF_PATH%\%FAMILY%-%2.ttf" "%~dp0\svg"
goto :eof

:error_makeotf_not_found
echo makeotf command not found. Install Adobe Font Development Kit for OpenType (http://www.adobe.com/devnet/opentype/afdko.html).
endlocal
exit /b 1

::
:: Get directory name from full path name.
:: Usage:
::   GetDirectoryName VARIABLE VALUE
::
:GetDirectoryName
call set %~1=%~dp2
goto :eof
