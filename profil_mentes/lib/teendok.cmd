@call %*
@exit /b

rem ==========================================================
rem  Kezi teendok listaja: _TEENDOK.txt a mentes mappajaban
rem  Mentesnel keszul el az 1. es 2. resz, visszaallitasnal kerul
rem  hozza a 3. resz az eredmennyel. Regebbi mentesnel a fajl neve
rem  _LEFT-TO-DO.txt - azt folytatjuk.
rem  Hivas: %TEENDOK% :MENTES  vagy  %TEENDOK% :VISSZAALLITAS.  Kimenet: TODO
rem  A fajl UTF-8: a teljes futas a 65001 kodlapon megy, igy az ekezetes
rem  mappanevek (Letoltesek, sajat mappa, PST utak) helyesen latszanak.
rem  A keszito a fejlecben van, mert a fajl vegere kesobb meg kerul resz.
rem ==========================================================

:MENTES
set "TODO=%CEL%\_TEENDOK.txt"
(>"%TODO%" echo TEENDŐK – kézi lépések az eszközcseréhez) 2>nul
if not exist "%TODO%" (
    set "TODO="
    goto :eof
)
>>"%TODO%" (
    echo Felhasználó: %USERNAME%    Régi gép: %COMPUTERNAME%    Mentés: %DATUM_SZEP%
    echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%
    echo ======================================================================
    echo.
    echo 1. MENTÉSKOR – A RÉGI GÉPEN
    echo    [ ] Outlook: írd fel a további postaládákat, a Feladó lista címeit és
    echo        a további fiókokat. Menüutak: outlook_lista.txt, 2. pont
    echo    [ ] Tálca rögzített ikonjai: a lista elkészült – talca.txt.
    echo        Nézd meg, minden rajta van-e
    echo    [ ] Böngészőben mentett jelszavak: a segédlet nem viszi át,
    echo        erről a felhasználónak kell gondoskodnia
)
if %ATN_DB% GTR 0 (
    >>"%TODO%" echo    [ ] Kézzel átnézendő mappák – a segédlet nem mentette, másold át, ami kell:
    for /l %%i in (1,1,%ATN_DB%) do >>"%TODO%" echo          !ATN_%%i!
) else (
    >>"%TODO%" echo    [ ] A C: gyökerébe mentett mappák és a felhasználó saját mappája:
    >>"%TODO%" echo        nézd át, és másold át kézzel, ami kell
    >>"%TODO%" echo    [ ] Letöltések: másold át kézzel, ami kell
)
for /l %%i in (1,1,%OL_KINT%) do >>"%TODO%" echo    [ ] PST a PST-mappán kívül, NINCS mentve – másold át kézzel: !OLK_%%i!
for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo    [ ] HIBÁS TÉTEL, ellenőrizd kézzel: !NEV_%%i! – !M_%%i!
call :IMPORT_RESZ
goto :eof

:IMPORT_RESZ
>>"%TODO%" (
    echo.
    echo 2. VISSZAÁLLÍTÁSKOR – AZ ÚJ GÉPEN
    echo    [ ] Futtasd a segédletet: 3. Adatok visszaállítása;
    echo        laptopnál utána 4. Laptop beállítása
    echo    [ ] Alapértelmezett alkalmazások: 5. menüpont rendszergazdaként,
    echo        majd ki- és bejelentkezés után újra az 5. menüpont ellenőrzésre
    echo    [ ] Outlook: csatold a PST-ket – lista: outlook_lista.txt, 1. pont
    echo        Fájl – Megnyitás és exportálás – Outlook-adatfájl megnyitása
    echo    [ ] Outlook: add hozzá a felírt postaládákat, feladókat és fiókokat
    echo    [ ] Outlook-aláírás: állítsd be alapértelmezettnek –
    echo        Fájl – Beállítások – Levelezés – Aláírások
    echo    [ ] Chrome, Edge: indítsd el, nézd meg a könyvjelzőket és a profilokat,
    echo        jelentkezz be újra az oldalakra
    echo    [ ] Sticky Notes: indítsd el, nézd meg a jegyzeteket
    echo    [ ] Programok: vesd össze az apps.txt-vel, ami hiányzik, telepíttesd
    echo    [ ] Letöltések és a kézzel mentett mappák: másold vissza – lista: 1. rész
    echo    [ ] Tálcaikonok: rögzítsd újra – lista: talca.txt
    echo    [ ] Start menü: a rögzítések visszaálltak; ami nem volt telepítve,
    echo        azt rögzítsd kézzel
    echo    [ ] Ha a felhasználó mindent rendben talált: töröld a mentést
    echo        a külső meghajtóról
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
rem Regebbi mentesnel meg nincs ilyen fajl - ekkor a visszaallito reszt itt irjuk meg
if not exist "%TODO%" (
    (>"%TODO%" echo TEENDŐK – kézi lépések az eszközcseréhez) 2>nul
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
>>"%TODO%" echo 3. VISSZAÁLLÍTÁS EREDMÉNYE – %DATUM_SZEP%, új gép: %COMPUTERNAME%
if %DB_HIBA%==0 (
    >>"%TODO%" echo    Minden tétel rendben
) else (
    for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo    [ ] HIBÁS TÉTEL, ellenőrizd kézzel: !NEV_%%i! – !M_%%i!
)
goto :eof
