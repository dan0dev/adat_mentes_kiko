@call %*
@exit /b

rem ==========================================================
rem  A segedlet frissitese a GitHubrol - a munka: ps\frissites.ps1
rem  Hivas: %FRISSITES% :ELLENORIZ  vagy  :LETOLT  vagy  :INDIT
rem ==========================================================

:ELLENORIZ
rem Kimenet: FR_ALLAPOT (UJ, AZONOS, HIBA), FR_HELYI, FR_UJ_SHA, FR_UJ_DATUM, FR_UJ_UZENET
set "FR_MOD=ELLENORIZ"
call :FUTTAT
set "FR_ALLAPOT=!_f1!"
set "FR_HELYI=!_f2!"
set "FR_UJ_SHA=!_f3!"
set "FR_UJ_DATUM=!_f4!"
set "FR_UJ_UZENET=!_f5!"
goto :eof

:LETOLT
set "FR_MOD=LETOLT"
call :FUTTAT
set "FR_LETOLTVE=0"
if "!_f1!"=="OK" set "FR_LETOLTVE=1"
%UI% :JELOL !_f1! "!_f2!" "!_f3!"
goto :eof

:INDIT
set "FR_MOD=INDIT"
call :FUTTAT
%UI% :JELOL !_f1! "!_f2!" "!_f3!"
goto :eof

:FUTTAT
rem A PowerShell eredmenye soronkent az FR_KI fajlban - a - ures erteket jelent
set "FR_APP=%APP%"
set "FR_MUNKA=%TEMP%\EszkozcsereFrissites"
set "FR_KI=%TEMP%\_frissites_%RANDOM%.txt"
for /l %%i in (1,1,5) do set "_f%%i="
if exist "%FR_KI%" del /q "%FR_KI%"
set "PS_FAJL=%PSDIR%\frissites.ps1"
>>"%LOG%" echo        %FR_MOD%: %FR_REPO% %FR_AG%
%PS_FUTTAT%
if not exist "%FR_KI%" (
    set "_f1=HIBA"
    set "_f2=a PowerShell nem futott le"
    goto :eof
)
set /a _fn=0
for /f "usebackq delims=" %%a in ("%FR_KI%") do (
    set /a _fn+=1
    set "_f!_fn!=%%a"
)
del /q "%FR_KI%" >nul 2>&1
for /l %%i in (1,1,5) do if "!_f%%i!"=="-" set "_f%%i="
>>"%LOG%" echo        Eredmény: !_f1! !_f2! !_f3!
goto :eof
