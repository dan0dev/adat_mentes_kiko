@call %*
@exit /b

rem ==========================================================
rem  Masolas robocopy-val, utana ellenorzes
rem  Hivas: %MASOLAS% :ROBO
rem ==========================================================

:ROBO
rem Bemenet: R_SRC, R_DST, R_OPT, R_PROG.  Kimenet: R_ALLAPOT, R_UZENET, R_RESZLET
rem A naplo UTF-8, a robocopy viszont a /LOG+ fajlba es a kepernyore mindig a 852-es
rem kodlapon ir, a /UNILOG+ pedig hozzafuzeskor nem Unicode. Ezert minden hivas egy
rem uj Unicode fajlba naploz (/UNILOG:), amit a type UTF-8-kent fuz a naplohoz.
>>"%LOG%" echo        %R_SRC% -^> %R_DST%
set "R_LOGT=%TEMP%\_robocopy_%RANDOM%.txt"
set "R_RESZLET="
if "%TESZTMOD%"=="1" goto :ROBO_TESZT
if "%R_PROG%"=="1" goto :ROBO_PROG
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /R:1 /W:1 /NP /UNILOG:"%R_LOGT%" >nul
set "R_RC=%errorlevel%"
call :ROBO_NAPLO
goto :ROBO_ELLENORZES
:ROBO_PROG
rem Folyamatjelzovel: a robocopy Unicode kimenete a ps\folyamat.ps1-en at megy a
rem kepernyore - UTF-8, behuzva, a Log File sor nelkul. A kilepesi kod fajlbol jon,
rem mert a cso jobb oldala adna az errorlevelt.
set "R_RCF=%TEMP%\_robocopy_rc_%RANDOM%.txt"
set "PS_FAJL=%PSDIR%\folyamat.ps1"
call "%LIB%\robo_prog.cmd" | %PS_FUTTAT%
set "R_RC=16"
if exist "%R_RCF%" (
    set /p R_RC=<"%R_RCF%"
    del /q "%R_RCF%" >nul 2>&1
)
call :ROBO_NAPLO
:ROBO_ELLENORZES
rem Ellenorzes: ugyanaz a masolas csak listazva - ha lenne mit masolni, elter
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /L /R:0 /W:0 /NJH /NJS /NDL /NFL /NP >nul
set "R_VRC=%errorlevel%"
set /a "R_VBIT=R_VRC & 1"
set "R_ALLAPOT=OK"
set "R_UZENET=átmásolva, ellenőrizve"
if %R_RC% GEQ 16 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=nem másolható"
    set "R_RESZLET=Az elérési út vagy a jogosultság nem megfelelő – részletek a naplóban."
    goto :eof
)
if %R_RC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=néhány fájl nem másolható"
    set "R_RESZLET=Zárolt fájl vagy hiányzó jogosultság – részletek a naplóban."
    goto :eof
)
if %R_VRC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=az ellenőrzés nem futott le"
    set "R_RESZLET=Részletek a naplóban."
    goto :eof
)
if %R_VBIT%==1 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=a másolat eltér az eredetitől"
    set "R_RESZLET=Egy fájl másolás közben megváltozott vagy zárolt volt."
    goto :eof
)
goto :eof

:ROBO_TESZT
rem Csak listazas: a robocopy vegigolvassa a forrast, de nem masol es nem hoz letre semmit
robocopy "%R_SRC%" "%R_DST%" %R_OPT% /FFT /L /R:0 /W:0 /NP /UNILOG:"%R_LOGT%" >nul
set "R_RC=%errorlevel%"
call :ROBO_NAPLO
set "R_ALLAPOT=OK"
set "R_UZENET=elérhető, menthető"
if %R_RC% GEQ 8 (
    set "R_ALLAPOT=HIBA"
    set "R_UZENET=nem olvasható"
    set "R_RESZLET=Jogosultság vagy elérési út – részletek a naplóban."
)
goto :eof

:ROBO_NAPLO
rem A robocopy Unicode naplojat UTF-8-kent a fonaplohoz fuzi - a type ismeri a BOM-ot
if exist "%R_LOGT%" (
    type "%R_LOGT%" >>"%LOG%" 2>nul
    del /q "%R_LOGT%" >nul 2>&1
)
goto :eof
