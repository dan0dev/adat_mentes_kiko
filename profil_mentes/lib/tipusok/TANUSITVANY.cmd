@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: TANUSITVANY - a felhasznalo tanusitvanyai (certmgr.msc)
rem  T_FORRAS = a tarolok nevei szokozzel, pl. My AddressBook
rem  T_MAPPA  = almappa a mentesben, benne taroloonkent egy mappa
rem  A kulcsos tanusitvanyok jelszoval vedett .pfx fajlba kerulnek, a tobbi .cer.
rem  A munka: ps\tanusitvany.ps1. Kimenet a teendokhoz: TAN_NEMEXP
rem ==========================================================

:MENT
set "TAN_MOD=MENT"
set "TAN_MAPPA=%CEL%\%T_MAPPA%"
if "%TESZTMOD%"=="1" (
    set "TAN_MOD=PROBA"
    set "TAN_MAPPA=%TEMP%\_tan_proba_%RANDOM%"
)
call :FUTTAT
if "%TESZTMOD%"=="1" rd /s /q "%TAN_MAPPA%" >nul 2>&1
goto :eof

:VISSZA
set "TAN_MOD=VISSZA"
set "TAN_MAPPA=%FORRAS%\%T_MAPPA%"
if not exist "%TAN_MAPPA%\" (
    %UI% :JELOL KIHAGYVA "nincs a mentésben"
    goto :eof
)
call :FUTTAT
goto :eof

:FUTTAT
set "TAN_TAROLOK=%T_FORRAS%"
set "TAN_KI=%TEMP%\_tan_%RANDOM%.txt"
if exist "%TAN_KI%" del /q "%TAN_KI%"
set "PS_FAJL=%PSDIR%\tanusitvany.ps1"
%PS_FUTTAT%
if not exist "%TAN_KI%" goto :FUTTAT_HIBA
set /a _tn=0
for /f "usebackq delims=" %%a in ("%TAN_KI%") do (
    set /a _tn+=1
    set "_t!_tn!=%%a"
)
del /q "%TAN_KI%" >nul 2>&1
if not "!_t4!"=="0" set "TAN_NEMEXP=!_t4!"
if "!_t3!"=="-" set "_t3="
%UI% :JELOL !_t1! "!_t2!" "!_t3!"
goto :eof

:FUTTAT_HIBA
%UI% :JELOL HIBA "a tanúsítványok nem kezelhetők" "A PowerShell nem futott le."
goto :eof
