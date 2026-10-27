@call %*
@exit /b

rem ==========================================================
rem  Masolas robocopy-val, utana ellenorzes
rem  Hivas: %MASOLAS% :ROBO
rem ==========================================================

:ROBO
rem Bemenet: R_SRC, R_DST, R_OPT, R_PROG.  Kimenet: R_ALLAPOT, R_UZENET
>>"%LOG%" echo        %R_SRC% -^> %R_DST%
if "%TESZTMOD%"=="1" goto :ROBO_TESZT
if "%R_PROG%"=="1" goto :ROBO_PROG
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NP /LOG+:"%LOG%" >nul
set "R_RC=%errorlevel%"
goto :ROBO_ELLENORZES
:ROBO_PROG
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NJH /NJS /NDL /NC /NS /TEE /LOG+:"%LOG%"
set "R_RC=%errorlevel%"
:ROBO_ELLENORZES
rem Ellenorzes: ugyanaz a masolas csak listazva - ha lenne mit masolni, elter
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /L /R:0 /W:0 /NJH /NJS /NDL /NFL /NP >nul
set "R_VRC=%errorlevel%"
set /a "R_VBIT=R_VRC & 1"
set "R_ALLAPOT=OK"
set "R_UZENET=atmasolva, ellenorizve"
if %R_RC% GEQ 16 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=sulyos hiba - eleresi ut vagy jogosultsag, lasd a logot"
    goto :eof
)
if %R_RC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=nehany fajl nem masolhato - zarolt fajl vagy nincs jog, lasd a logot"
    goto :eof
)
if %R_VRC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=az ellenorzes nem futott le, lasd a logot"
    goto :eof
)
if %R_VBIT%==1 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=ellenorzes: a cel elter a forrastol - a fajl kozben valtozott vagy zarolt"
    goto :eof
)
goto :eof

:ROBO_TESZT
rem Csak listazas: a robocopy vegigolvassa a forrast, de nem masol es nem hoz letre semmit
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /L /R:0 /W:0 /NP /LOG+:"%LOG%" >nul
set "R_RC=%errorlevel%"
set "R_ALLAPOT=OK"
set "R_UZENET=elerheto, mentheto"
if %R_RC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=a forras nem olvashato - jogosultsag vagy eleresi ut, lasd a logot"
)
goto :eof
