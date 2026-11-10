@call %*
@exit /b

rem ==========================================================
rem  Office-parancsikonok az asztalon - a munka: ps\office_ikonok.ps1
rem  A programok listaja: config\parancsikonok.cmd
rem  Hivas: %IKONOK% :MENT "fajl"  - mentesnel: a regi gep asztali Office-ikonjai
rem         %IKONOK% :VIZSGAL      - visszaallitaskor: IK_TEENDO = hany ikon kell / rossz
rem         %IKONOK% :JAVIT        - visszaallitaskor: kirakas, javitas - egy lepes
rem ==========================================================

:MENT
rem %1 = a mentes asztal_office.txt-je
call :BETOLT
set "IK_MOD=MENT"
set "IK_FAJL=%~1"
set "IK_NEVEK="
set "PS_FAJL=%PSDIR%\office_ikonok.ps1"
for /f "delims=" %%n in ('%PS_FUTTAT% 2^>nul') do set "IK_NEVEK=%%n"
if defined IK_NEVEK %UI% :RESZLET "asztali Office-ikonok: !IK_NEVEK!"
goto :eof

:VIZSGAL
call :BETOLT
set "IK_MOD=VIZSGAL"
set "IK_FAJL=%FORRAS%\asztal_office.txt"
set "IK_TEENDO=0"
set "PS_FAJL=%PSDIR%\office_ikonok.ps1"
for /f %%c in ('%PS_FUTTAT% 2^>nul') do set "IK_TEENDO=%%c"
goto :eof

:JAVIT
call :BETOLT
set "IK_MOD=JAVIT"
set "IK_FAJL=%FORRAS%\asztal_office.txt"
set "_i1=HIBA"
set "_i2=nem sikerült automatikusan"
set "_i3=Az Office-ikonokat tedd ki kézzel."
set "PS_FAJL=%PSDIR%\office_ikonok.ps1"
for /f "tokens=1-3 delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    set "_i1=%%a"
    set "_i2=%%b"
    set "_i3=%%c"
)
>>"%LOG%" echo        Office-ikonok: !_i1! !_i2! – !_i3!
%UI% :JELOL !_i1! "!_i2!" "!_i3!"
goto :eof

:BETOLT
rem A config\parancsikonok.cmd: IK_APPOK = nev|exe|alap|mas nevek, pontosvesszovel
set "IK_APPOK="
set IKON_APP=call "%LIB%\ikonok.cmd" :APP
call "%CONF%\parancsikonok.cmd"
set "IK_KOZOS=%PUBLIC%\Desktop"
if defined PM_TESZT_KOZOS_ASZTAL set "IK_KOZOS=%PM_TESZT_KOZOS_ASZTAL%"
goto :eof

:APP
rem %1 = nev, %2 = exe, %3 = ALAP vagy ures, 4-tol mas nevek
set "_ia=0"
if /I "%~3"=="ALAP" set "_ia=1"
set "_ie=%~1|%~2|!_ia!|"
:APP_NEVEK
if "%~4"=="" goto :APP_KESZ
set "_ie=!_ie!%~4,"
shift /4
goto :APP_NEVEK
:APP_KESZ
set "IK_APPOK=!IK_APPOK!;!_ie!"
goto :eof
