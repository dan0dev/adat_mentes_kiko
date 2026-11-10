@call %*
@exit /b

rem ==========================================================
rem  Osszegzes - a mentes es a visszaallitas vegen (:OSSZEGZES), az egylepeses
rem  menupontoknal rovid zaras (:ROVID)
rem  Hivas: %OSSZEGZES% :OSSZEGZES  vagy  %OSSZEGZES% :ROVID
rem ==========================================================

:OSSZEGZES
%UI% :IDO VEGE_MP
set /a ELTELT=VEGE_MP-START_MP
if %ELTELT% LSS 0 set /a ELTELT+=86400
set /a E_PERC=ELTELT/60, E_MP=ELTELT%%60
title Eszközcsere segédlet %VERZIO% – %MOD_NEV% kész

rem Osszegzes fajl - az eredmeny mar a fajlnevben latszik
set "OSSZ_HELY=%TEMP%"
set "OSSZ_ELO=_BITLOCKER"
if "%MODUL%"=="chrome" set "OSSZ_ELO=_CHROME"
if "%MODUL%"=="frissites" set "OSSZ_ELO=_FRISSITES"
set "HELY_CIMKE=Fájlok helye"
if "%MODUL%"=="mentes" set "OSSZ_HELY=%CEL%"
if "%MODUL%"=="mentes" set "OSSZ_ELO=_MENTES"
if "%MODUL%"=="mentes" set "HELY_CIMKE=Mentés helye"
if "%MODUL%"=="visszaallitas" set "OSSZ_ELO=_VISSZAALLITAS"
if "%MODUL%"=="visszaallitas" set "HELY_CIMKE=Mentés helye"
if "%MODUL%"=="visszaallitas" if "%IRHATO%"=="1" set "OSSZ_HELY=%FORRAS%"
if %DB_HIBA%==0 (
    set "OSSZ_NEV=%OSSZ_ELO%_OK_%DATUM%.txt"
    if %DB_OK%==0 set "OSSZ_NEV=%OSSZ_ELO%_URES_%DATUM%.txt"
) else (
    set "OSSZ_NEV=%OSSZ_ELO%_%DB_HIBA%_HIBA_%DATUM%.txt"
)
rem A korabbi futasok sajat osszegzes fajljai, hogy ne legyen ket ellentmondo - a regi _EXPORT nev is
del /q "%OSSZ_HELY%\%OSSZ_ELO%_*.txt" >nul 2>&1
if "%MODUL%"=="visszaallitas" del /q "%OSSZ_HELY%\_EXPORT_*.txt" >nul 2>&1
set "OSSZ_FAJL=%OSSZ_HELY%\%OSSZ_NEV%"
(>"%OSSZ_FAJL%" echo %MOD_NEV% – összegzés) 2>nul
if not exist "%OSSZ_FAJL%" (
    set "OSSZ_HELY=%TEMP%"
    set "OSSZ_FAJL=%TEMP%\%OSSZ_NEV%"
)
rem Rovid, kulcsszavas: a fajl neve megmondja, mi ez - a tartalom csak a sorok
>"%OSSZ_FAJL%" echo %USERNAME% · %COMPUTERNAME% · %DATUM_SZEP% %time:~0,5% · %MOD_NEV%
>>"%OSSZ_FAJL%" echo.

rem Kezi teendok listaja
set "TODO="
if "%MODUL%"=="mentes" %TEENDOK% :MENTES
if "%MODUL%"=="visszaallitas" %TEENDOK% :VISSZAALLITAS

echo.
%UI% :CIM "Összegzés – %MOD_NEV%"
for /l %%i in (1,1,%OSSZES%) do %UI% :OSSZ_SOR %%i
%UI% :VONAL
echo     Sikeres: %DB_OK%     Hibás: %DB_HIBA%     Kihagyva: %DB_KIHAGY%     Időtartam: %E_PERC% perc %E_MP% mp
>>"%OSSZ_FAJL%" echo.
>>"%OSSZ_FAJL%" echo Sikeres %DB_OK% · Hibás %DB_HIBA% · Kihagyva %DB_KIHAGY% · %E_PERC% perc %E_MP% mp
echo.
rem Zold sav csak akkor, ha tenyleg keszult valami: ha egy tetel sem sikerult (minden
rem kihagyva), az nem "rendben" - es az atugrott tetel is latsszon
if %DB_HIBA% GTR 0 (
    %UI% :SAV HIBA "FIGYELEM: %DB_HIBA% tétel hibával zárult – nézd át a listát és a naplót."
) else if %DB_OK%==0 (
    %UI% :SAV HIBA "FIGYELEM: egy tétel sem készült el – nézd át a listát és a naplót."
) else if %DB_ATUGORVA% GTR 0 (
    %UI% :SAV FIGYEL "KÉSZ – %DB_ATUGORVA% tétel átugorva, ezt kézzel nézd át."
) else (
    %UI% :SAV OK "KÉSZ – minden tétel rendben."
)
echo.
%UI% :ADAT "%HELY_CIMKE%" "%OSSZ_HELY%"
%UI% :ADAT "Összegzés" "%OSSZ_NEV%"
if defined TODO for %%x in ("!TODO!") do %UI% :ADAT "Teendők" "%%~nxx"
call :NAPLO_NEV
%UI% :ADAT "Napló" "!NAPLO_NEV!"

echo.
%UI% :LABLEC TELJES
>>"%OSSZ_FAJL%" echo.
>>"%OSSZ_FAJL%" echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%

rem Egyetlen kerdes a vegen: a teendok, a mentes mappaja - es hiba eseten a naplo -
rem megnyitasa. Barmelyik valasz utan vissza a menube.
echo.
set "_mit=a teendőket és a mappát"
if %DB_HIBA% GTR 0 set "_mit=a teendőket, a mappát és a naplót"
if not defined TODO set "_mit=a mappát"
%UI% :VALASZT IN "Megnyissam %_mit%?"
if errorlevel 2 goto :eof
if defined TODO start "" notepad "%TODO%"
if %DB_HIBA% GTR 0 start "" notepad "%LOG%"
if "%MODUL%"=="mentes" start "" explorer "%CEL%"
if "%MODUL%"=="visszaallitas" start "" explorer "%FORRAS%"
goto :eof

:ROVID
rem Egylepeses menupont (BitLocker, Chrome, frissites) vege: egy sav, egy billentyu.
rem ROVID_SZOVEG: a billentyu-varas szovege, ha nem a menube megy vissza
echo.
if %DB_HIBA% GTR 0 (
    %UI% :SAV HIBA "Nem sikerült – az okát fent látod."
) else (
    %UI% :SAV OK "Kész."
)
echo.
if not defined ROVID_SZOVEG set "ROVID_SZOVEG=Vissza a menübe: nyomj meg egy billentyűt…"
%UI% :BILLENTYU "!ROVID_SZOVEG!"
goto :eof

:NAPLO_NEV
rem A naplo neve: ha az osszegzes mappajaban van, csak a fajlnev, kulonben a teljes ut
set "NAPLO_NEV=%LOG%"
for %%x in ("%LOG%") do (
    set "_nd=%%~dpx"
    set "_nn=%%~nxx"
)
if /I "!_nd!"=="%OSSZ_HELY%\" set "NAPLO_NEV=!_nn!"
goto :eof
