@echo off

:: Initialization
mode con cols=60 lines=30
title DynaPsPscPyPy3-Ba
color 0E
set cols=60
echo.
echo DynaPsPscPyPy3-Ba Started...
timeout /t 2 /nobreak >nul
set "scriptDir=%~dp0"

:: Artwork
set "header60====================( DynaPsPscPyPy3-Ba )===================="
set "header70==========================( DynaPsPscPyPy3-Ba )========================"
set "header50===============( DynaPsPscPyPy3-Ba )==============="

:: Error and Crash Log Initialization
if exist "Errors.Log" del "Errors.Log"
if exist "Crashes.Log" del "Crashes.Log"
set "ErrorLog=Errors.Log"
set "CrashLog=Crashes.Log"

:: Function to list scripts
:generateMenu
set i=0
setlocal EnableDelayedExpansion
for %%f in (*.ps1, *.py) do (
    set /a i+=1
    if "%%~xf"==".ps1" (
        set "scriptName[!i!]=PS: %%~nxf"
    ) else if "%%~xf"==".py" (
        set "scriptName[!i!]=PY: %%~nxf"
    )
)

if %i%==0 (
    echo.
    echo No .Ps1/.Py Scripts Found!
    timeout /t 2 /nobreak >nul
    goto end
)

:: Main Menu
:menu
cls
echo.
if "%cols%"=="60" echo %header60%
if "%cols%"=="70" echo %header70%
if "%cols%"=="50" echo %header50%
echo.
echo                      Scripts Found: %i%
echo.

for /l %%x in (1,1,%i%) do (
    echo               %%x. !scriptName[%%x]!
)
echo.
echo.

:: User choice
set /p choice=Select, Script=1-#, Admin=A, Refresh=R, Window=W, Exit=X: 
if /i "%choice%"=="x" goto end
if /i "%choice%"=="r" goto generateMenu
if /i "%choice%"=="w" goto changeWindowSize
if /i "%choice%"=="a" goto getAdmin

:: Validate choice
set "selectedScript=!scriptName[%choice%]!"
if "!selectedScript!"=="" (
    echo Invalid choice.
    echo.
	timeout /t 2 /nobreak >nul
    goto menu
)

:: Extracting script file name and type from the selection
set "scriptFile=!selectedScript:~4!"
set "scriptType=!selectedScript:~0,2!"

:: Determine script type and execute
echo.
echo Launching !scriptType! Script: !scriptFile!
echo.
timeout /t 2 /nobreak >nul
if "!scriptType!"=="PS" (
    call :launchPSScript "!scriptFile!"
) else if "!scriptType!"=="PY" (
    call :launchPythonScript "!scriptFile!"
)

:: Check for script crash
if errorlevel 1 (
    echo [%date% %time%] Script crashed with error code %errorlevel% >> "%CrashLog%"
)

:: Return to menu or exit
echo ...Script Exited.
echo.
<nul set /p "=Select, Main Menu = M, Exit Program = X: "
set /p exitChoice=
if /i "%exitChoice%"=="m" goto menu
if /i "%exitChoice%"=="x" goto end
echo Invalid choice.
echo.
timeout /t 2 /nobreak >nul
goto retryExitChoice

:: Change Window Size
:changeWindowSize
if "%cols%"=="60" (
    set cols=50
    set lines=50
) else if "%cols%"=="50" (
    set cols=70
    set lines=30
) else (
    set cols=60
    set lines=40
)
mode con cols=%cols% lines=%lines%
goto menu

:end
echo.
echo ...Launcher Script Finished.
echo.
echo Removing Garbage Files...
for %%F in ("%ErrorLog%") do if %%~zF EQU 0 del "%ErrorLog%"
echo ...Garbage Files Deleted.
echo.
pause

:: Get Admin
:getAdmin
echo Gaining Admin...
net session >nul 2>&1
if %errorlevel% == 0 (
    echo ...Admin Success.
    timeout /t 2 /nobreak >nul
    goto menu
) else (
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c cd /d %scriptDir% && %~f0 && exit' -Verb runAs" >nul 2>&1
    exit
)

:: Functions to launch scripts
:launchPSScript
where pwsh >nul 2>&1 && (
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~1" 2>> "%ErrorLog%"
) || (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~1" 2>> "%ErrorLog%"
)
exit /b %errorlevel%

:launchPythonScript
where python3 >nul 2>&1 && (
    python3 "%~1" 2>> "%ErrorLog%"
) || (
    python "%~1" 2>> "%ErrorLog%"
)
exit /b %errorlevel%
