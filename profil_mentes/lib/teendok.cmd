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
>>"%TODO%" (
    echo.
    echo RÉGI GÉP
    echo [ ] Outlook: további postaládák, Feladó címek, további fiókok – outlook_lista.txt
    echo [ ] Tálca ikonjai – talca.txt, talca.png
    echo [ ] PST-k átmásolása kézzel – outlook_lista.txt
    echo [ ] Tanúsítványok: certmgr.msc – Személyes, kézzel
    echo [ ] Böngészőben mentett jelszavak
)
for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo [ ] HIBÁS: !NEV_%%i! – !M_%%i!
call :ATUGORVA_SOROK
call :IMPORT_RESZ
goto :eof

:IMPORT_RESZ
>>"%TODO%" (
    echo.
    echo ÚJ GÉP
    echo [ ] 2 Visszaállítás, laptopnál 3 Laptop
    echo [ ] 4 Alapértelmezett alkalmazások, ki- és bejelentkezés, 4 ellenőrzés
    echo [ ] Tanúsítványok: telepítés kézzel
    echo [ ] Outlook: PST-k csatolása – outlook_lista.txt
    echo [ ] Outlook: postaládák, feladók, fiókok
    echo [ ] Outlook: alapértelmezett aláírás
    echo [ ] Chrome, Edge: profilok, könyvjelzők, újra bejelentkezés
    echo [ ] Sticky Notes
    echo [ ] Programok: apps.txt összevetése, hiányzók telepítése
    echo [ ] Tálca ikonjai újra – talca.txt, talca.png
    echo [ ] Start menü: hiányzó rögzítések kézzel
    echo [ ] Minden rendben: mentés törlése a meghajtóról
)
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
