@call %*
@exit /b

rem ==========================================================
rem  Kezi teendok listaja: _TEENDOK.txt a mentes mappajaban
rem  Rovid, kulcsszavas - a fajl neve mar megmondja, mi ez.
rem  Mentesnel keszul el a REGI GEP es az UJ GEP resz, visszaallitasnal kerul
rem  hozza a VISSZAALLITAS resz az eredmennyel. Regebbi mentesnel a fajl neve
rem  _LEFT-TO-DO.txt - azt folytatjuk.
rem  Hivas: %TEENDOK% :MENTES  vagy  %TEENDOK% :VISSZAALLITAS.  Kimenet: TODO
rem  A fajl UTF-8: a teljes futas a 65001 kodlapon megy.
rem  A keszito a fejlecben van, mert a fajl vegere kesobb meg kerul resz.
rem ==========================================================

:MENTES
set "TODO=%CEL%\_TEENDOK.txt"
(>"%TODO%" echo %USERNAME% · %COMPUTERNAME% · %DATUM_SZEP%) 2>nul
if not exist "%TODO%" (
    set "TODO="
    goto :eof
)
>>"%TODO%" echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%
rem Csak az kerul ide, amit a segedlet NEM tud megcsinalni - amit elvegzett (listak,
rem talcakep), az nem teendo. A PST-sor csak akkor, ha van csatolt PST (vagy a lista nem keszult el).
>>"%TODO%" echo.
>>"%TODO%" echo RÉGI GÉP – kézzel, a segédlet ezeket nem tudja:
>>"%TODO%" echo [ ] Outlook: további postaládák, feladócímek, fiókok – írd fel
if not "%OL_PST%"=="0" >>"%TODO%" echo [ ] PST-fájlok átmásolása – a helyük: outlook_lista.txt
>>"%TODO%" echo [ ] Tanúsítványok kimentése: certmgr.msc – Személyes
>>"%TODO%" echo [ ] Böngészőjelszavak: szinkron vagy export – nem kerülnek át
for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo [ ] HIBÁS: !NEV_%%i! – !M_%%i!
call :ATUGORVA_SOROK
call :IMPORT_RESZ
goto :eof

:IMPORT_RESZ
>>"%TODO%" echo.
>>"%TODO%" echo ÚJ GÉP
>>"%TODO%" echo [ ] Segédlet: 2 Visszaállítás, 3 BitLocker
>>"%TODO%" echo [ ] Chrome: Szoftverközpont – ha nem indul el, 4 Chrome telepítése
>>"%TODO%" echo [ ] Alapértelmezett alkalmazások: Word, Excel, PowerPoint, PDF, Chrome
>>"%TODO%" echo [ ] Tanúsítványok telepítése
if not "%OL_PST%"=="0" >>"%TODO%" echo [ ] Outlook: PST-k csatolása – outlook_lista.txt
>>"%TODO%" echo [ ] Outlook: további postaládák, feladócímek, fiókok
>>"%TODO%" echo [ ] Outlook: alapértelmezett aláírás kiválasztása
>>"%TODO%" echo [ ] Chrome, Edge: bejelentkezés, jelszavak
>>"%TODO%" echo [ ] Programok: a hiányzók telepítése – apps.txt
>>"%TODO%" echo [ ] Nyomtatók, hálózati meghajtók: ami nem jött vissza – nyomtatok_meghajtok.txt
>>"%TODO%" echo [ ] Tálcaikonok rögzítése – talca.txt, talca.png
>>"%TODO%" echo [ ] Start menü: a hiányzó rögzítések
>>"%TODO%" echo [ ] Ha minden rendben: a mentés törlése a meghajtóról
goto :eof

:VISSZAALLITAS
rem Az uj nev az elsodleges, regebbi mentesnel a _LEFT-TO-DO.txt-t folytatjuk
if "%IRHATO%"=="0" (
    if exist "%FORRAS%\_TEENDOK.txt" set "TODO=%FORRAS%\_TEENDOK.txt"
    if not defined TODO if exist "%FORRAS%\_LEFT-TO-DO.txt" set "TODO=%FORRAS%\_LEFT-TO-DO.txt"
    goto :eof
)
set "TODO=%FORRAS%\_TEENDOK.txt"
if not exist "%TODO%" if exist "%FORRAS%\_LEFT-TO-DO.txt" set "TODO=%FORRAS%\_LEFT-TO-DO.txt"
rem Regebbi mentesnel meg nincs ilyen fajl - ekkor az uj gep reszt itt irjuk meg
if not exist "%TODO%" (
    (>"%TODO%" echo %USERNAME% · %COMPUTERNAME% · %DATUM_SZEP%) 2>nul
    if exist "%TODO%" (
        >>"%TODO%" echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%
        call :IMPORT_RESZ
    )
)
if not exist "%TODO%" (
    set "TODO="
    goto :eof
)
>>"%TODO%" echo.
>>"%TODO%" echo VISSZAÁLLÍTÁS – %DATUM_SZEP% · %COMPUTERNAME%
set /a _gond=DB_HIBA+DB_ATUGORVA
if %_gond%==0 (
    >>"%TODO%" echo Minden tétel rendben
) else (
    for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo [ ] HIBÁS: !NEV_%%i! – !M_%%i!
    call :ATUGORVA_SOROK
)
goto :eof

:ATUGORVA_SOROK
rem A masolas kozben atugrott tetelek (K billentyu) - ezeket kezzel kell atnezni
if "%DB_ATUGORVA%"=="0" goto :eof
for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="KIHAGYVA" if "!M_%%i!"=="átugorva" >>"%TODO%" echo [ ] ÁTUGORVA: !NEV_%%i! – kézzel nézd át
goto :eof
