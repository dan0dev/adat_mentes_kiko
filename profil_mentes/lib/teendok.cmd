@call %*
@exit /b

rem ==========================================================
rem  Kezi teendok listaja: _LEFT-TO-DO.txt a mentes mappaban
rem  Mentesnel keszul el az 1. es 2. resz, exportalasnal kerul
rem  hozza a 3. resz az eredmennyel.
rem  Hivas: %TEENDOK% :MENTES  vagy  %TEENDOK% :EXPORT.  Kimenet: TODO
rem  A fajl UTF-8: a teljes futas a 65001 kodlapon megy, igy az ekezetes
rem  mappanevek (Letoltesek, sajat mappa, PST utak) helyesen latszanak.
rem ==========================================================

:MENTES
set "TODO=%CEL%\_LEFT-TO-DO.txt"
(>"%TODO%" echo LEFT-TO-DO - kezi teendok az eszkozcserehez) 2>nul
if not exist "%TODO%" (
    set "TODO="
    goto :eof
)
>>"%TODO%" (
    echo Felhasznalo: %USERNAME%    Regi gep: %COMPUTERNAME%    Mentes: %DATUM%
    echo ==========================================================
    echo.
    echo 1. MENTESKOR - A REGI GEPEN
    echo    - Outlook: ird fel a tovabbi postaladakat, a Felado lista cimeit es a tovabbi fiokokat
    echo      Menuutak: outlook_lista.txt 2. pont
    echo    - Talca rogzitett ikonjai: a lista elkeszult - talca.txt. Nezd meg, minden rajta van-e
    echo    - Bongeszoben mentett jelszavak: a script nem viszi at, a felhasznalo gondoskodjon rola
)
if %ATN_DB% GTR 0 (
    >>"%TODO%" echo    - Kezzel atnezendo mappak - a script nem mentette, masold at, ami kell:
    for /l %%i in (1,1,%ATN_DB%) do >>"%TODO%" echo      !ATN_%%i!
) else (
    >>"%TODO%" echo    - C: gyokerebe mentett mappak es a felhasznalo sajat mappaja: nezd at, ami kell, masold at kezzel
    >>"%TODO%" echo    - Letoltesek: masold at kezzel, ami kell
)
for /l %%i in (1,1,%OL_KINT%) do >>"%TODO%" echo    - PST a PST mappan kivul, NINCS mentve - masold at kezzel: !OLK_%%i!
for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo    - HIBAS TETEL, ellenorizd kezzel: !NEV_%%i! - !M_%%i!
call :IMPORT_RESZ
goto :eof

:IMPORT_RESZ
>>"%TODO%" (
    echo.
    echo 2. IMPORTNAL - AZ UJ GEPEN
    echo    - Futtasd a scriptet: 2. Adatok exportalasa, laptopnal utana 3. BitLocker es fedel beallitasa
    echo    - Alapertelmezett alkalmazasok: 5. menu rendszergazdakent, ki-be jelentkezes utan 5. menu ellenorzesre
    echo    - Outlook: csatold a PST-ket - lista: outlook_lista.txt 1. pont
    echo      Fajl - Megnyitas es exportalas - Outlook-adatfajl megnyitasa
    echo    - Outlook: add hozza a felirt postaladakat, feladokat es fiokokat
    echo    - Outlook alairas: allitsd be alapertelmezettnek - Fajl - Beallitasok - Levelezes - Alairasok
    echo    - Chrome, Edge: inditsd el, nezd meg a konyvjelzoket es profilokat, jelentkezz be ujra az oldalakra
    echo    - Sticky Notes: inditsd el, nezd meg a jegyzeteket
    echo    - Programok: vesd ossze az apps.txt-vel, ami hianyzik, telepittesd
    echo    - Letoltesek es a kezzel mentett mappak: masold vissza - lista: 1. resz
    echo    - Talca ikonok: rogzitsd ujra - lista: talca.txt
    echo    - Start menu: a rogzitett programok visszaalltak, ami nem volt telepitve, azt rogzitsd kezzel
    echo    - Ha a felhasznalo mindent rendben talalt: torold a mentest a kulso meghajtorol
)
goto :eof

:EXPORT
if "%IRHATO%"=="0" (
    if exist "%FORRAS%\_LEFT-TO-DO.txt" set "TODO=%FORRAS%\_LEFT-TO-DO.txt"
    goto :eof
)
set "TODO=%FORRAS%\_LEFT-TO-DO.txt"
rem Regebbi mentesnel meg nincs ilyen fajl - ekkor az importalo reszt itt irjuk meg
if not exist "%TODO%" (
    (>"%TODO%" echo LEFT-TO-DO - kezi teendok az eszkozcserehez) 2>nul
    if exist "%TODO%" call :IMPORT_RESZ
)
if not exist "%TODO%" (
    set "TODO="
    goto :eof
)
>>"%TODO%" echo.
>>"%TODO%" echo 3. EXPORT EREDMENYE - %DATUM%, uj gep: %COMPUTERNAME%
if %DB_HIBA%==0 (
    >>"%TODO%" echo    - Minden tetel rendben
) else (
    for /l %%i in (1,1,%OSSZES%) do if "!E_%%i!"=="HIBA" >>"%TODO%" echo    - HIBAS TETEL, ellenorizd kezzel: !NEV_%%i! - !M_%%i!
)
goto :eof
