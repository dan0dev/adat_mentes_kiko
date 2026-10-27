@call %*
@exit /b

rem ==========================================================
rem  Masolas robocopy-val, utana ellenorzes
rem  Hivas: %MASOLAS% :ROBO
rem ==========================================================

:ROBO
rem Bemenet: R_SRC, R_DST, R_OPT, R_PROG.  Kimenet: R_ALLAPOT, R_UZENET
rem A naplo UTF-8, a robocopy viszont a /LOG+ fajlba es a kepernyore mindig a 852-es
rem kodlapon ir, a /UNILOG+ pedig hozzafuzeskor nem Unicode. Ezert minden hivas egy
rem uj Unicode fajlba naploz (/UNILOG:), amit a type UTF-8-kent fuz a naplohoz.
>>"%LOG%" echo        %R_SRC% -^> %R_DST%
set "R_LOGT=%TEMP%\_robocopy_%RANDOM%.txt"
if "%TESZTMOD%"=="1" goto :ROBO_TESZT
if "%R_PROG%"=="1" goto :ROBO_PROG
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NP /UNILOG:"%R_LOGT%" >nul
set "R_RC=%errorlevel%"
call :ROBO_NAPLO
goto :ROBO_ELLENORZES
:ROBO_PROG
rem Folyamatjelzovel: a kepernyore a robocopy 852-es kodlapon ir, ezert a kijelzes
rem idejere a konzol is 852-re valt, igy az ekezetes fajlnevek helyesen latszanak.
>nul chcp 852 <nul
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NJH /NJS /NDL /NC /NS /TEE /UNILOG:"%R_LOGT%"
set "R_RC=%errorlevel%"
>nul chcp 65001 <nul
call :ROBO_NAPLO
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
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /L /R:0 /W:0 /NP /UNILOG:"%R_LOGT%" >nul
set "R_RC=%errorlevel%"
call :ROBO_NAPLO
set "R_ALLAPOT=OK"
set "R_UZENET=elerheto, mentheto"
if %R_RC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=a forras nem olvashato - jogosultsag vagy eleresi ut, lasd a logot"
)
goto :eof

:ROBO_NAPLO
rem A robocopy Unicode naplojat UTF-8-kent a fonaplohoz fuzi - a type ismeri a BOM-ot
if exist "%R_LOGT%" (
    type "%R_LOGT%" >>"%LOG%" 2>nul
    del /q "%R_LOGT%" >nul 2>&1
)
goto :eof
