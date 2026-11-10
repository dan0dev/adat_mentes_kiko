@call %*
@exit /b

rem ==========================================================
rem  Chrome telepitese: letoltes es telepites - a munka: ps\chrome.ps1
rem  Hivas: %CHROME% :VERZIO  vagy  %CHROME% :LETOLT  vagy  %CHROME% :TELEPIT
rem ==========================================================

:VERZIO
rem Kimenet: CH_VERZIO - a telepitett Chrome verzioja, vagy ures
set "CH_VERZIO="
set "CHROME_MOD=VERZIO"
set "PS_FAJL=%PSDIR%\chrome.ps1"
for /f "delims=" %%v in ('%PS_FUTTAT% 2^>nul') do set "CH_VERZIO=%%v"
if "%CH_VERZIO%"=="-" set "CH_VERZIO="
goto :eof

:LETOLT
rem Kimenet: CH_LETOLTVE = 1, ha a telepito letoltve es az alairasa rendben
set "CH_LETOLTVE=0"
set "CHROME_MOD=LETOLT"
call :FUTTAT
if "%CH_ALLAPOT%"=="OK" set "CH_LETOLTVE=1"
goto :eof

:TELEPIT
set "CHROME_MOD=TELEPIT"
call :FUTTAT
goto :eof

:FUTTAT
rem A PowerShell a folyamatot a kepernyore irja, az eredmenyt a CHROME_KI fajlba
set "CHROME_MSI=%TEMP%\EszkozcsereChrome\googlechromestandaloneenterprise64.msi"
set "CHROME_NAPLO=%TEMP%\chrome_telepito_naplo.txt"
set "CHROME_KI=%TEMP%\_chrome_%RANDOM%.txt"
if exist "%CHROME_KI%" del /q "%CHROME_KI%"
set "PS_FAJL=%PSDIR%\chrome.ps1"
>>"%LOG%" echo        %CHROME_MOD%: %CHROME_MSI%
%PS_FUTTAT%
set "CH_ALLAPOT=HIBA"
if not exist "%CHROME_KI%" (
    %UI% :JELOL HIBA "a PowerShell nem futott le"
    goto :eof
)
set /a _cn=0
for /f "usebackq delims=" %%a in ("%CHROME_KI%") do (
    set /a _cn+=1
    set "_c!_cn!=%%a"
)
del /q "%CHROME_KI%" >nul 2>&1
if "!_c3!"=="-" set "_c3="
set "CH_ALLAPOT=!_c1!"
%UI% :JELOL !_c1! "!_c2!" "!_c3!"
goto :eof
