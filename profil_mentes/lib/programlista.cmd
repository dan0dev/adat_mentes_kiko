@call %*
@exit /b

rem ==========================================================
rem  Telepitett programok listaja - apps.txt
rem  Hivas: %PROGRAMLISTA% :KESZIT "kimeneti fajl"
rem ==========================================================

:KESZIT
rem %1 = kimeneti fajl. Elsodlegesen PowerShell - ps\programlista.ps1 -, ha tiltva van, reg query.
set "APPS_FAJL=%~1"
set "PS_FAJL=%PSDIR%\programlista.ps1"
%PS_FUTTAT% >nul 2>&1
if not errorlevel 1 if exist "%APPS_FAJL%" goto :KESZ
echo        PowerShell nem elerheto, egyszerubb lista keszul...
set "APPS_TMP=%TEMP%\_apps_%RANDOM%.tmp"
(for %%k in ("HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall") do (
    for /f "tokens=2,*" %%a in ('reg query "%%~k" /s /v DisplayName 2^>nul ^| find "REG_SZ"') do echo %%b
)) >"%APPS_TMP%" 2>nul
sort "%APPS_TMP%" /o "%APPS_FAJL%" >nul 2>&1
del /q "%APPS_TMP%" >nul 2>&1
:KESZ
set "ADB=0"
if exist "%APPS_FAJL%" for /f %%c in ('type "%APPS_FAJL%" ^| find /c /v ""') do set "ADB=%%c"
if "%ADB%"=="0" (
    %UI% :JELOL HIBA "a programlista nem keszult el"
) else (
    %UI% :JELOL OK "%ADB% program - apps.txt"
)
goto :eof
