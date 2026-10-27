@call %*
@exit /b

rem ==========================================================
rem  Osszegzes es vegso megerosites - minden menupont vegen
rem  Hivas: %OSSZEGZES% :OSSZEGZES
rem ==========================================================

:OSSZEGZES
%UI% :IDO VEGE_MP
set /a ELTELT=VEGE_MP-START_MP
if %ELTELT% LSS 0 set /a ELTELT+=86400
set /a E_PERC=ELTELT/60, E_MP=ELTELT%%60
title Eszközcsere segédlet – %MOD_NEV% kész
if "%TESZTMOD%"=="1" goto :TESZT

rem Osszegzes fajl - az eredmeny mar a fajlnevben latszik
set "OSSZ_HELY=%TEMP%"
set "OSSZ_ELO=_LAPTOP"
set "HELY_CIMKE=Fájlok helye"
if "%MODUL%"=="alapalk" set "OSSZ_ELO=_ALAPALK"
if "%MODUL%"=="mentes" set "OSSZ_HELY=%CEL%"
if "%MODUL%"=="mentes" set "OSSZ_ELO=_MENTES"
if "%MODUL%"=="mentes" set "HELY_CIMKE=Mentés helye"
if "%MODUL%"=="visszaallitas" set "OSSZ_ELO=_VISSZAALLITAS"
if "%MODUL%"=="visszaallitas" set "HELY_CIMKE=Mentés helye"
if "%MODUL%"=="visszaallitas" if "%IRHATO%"=="1" set "OSSZ_HELY=%FORRAS%"
if %DB_HIBA%==0 (
    set "OSSZ_NEV=%OSSZ_ELO%_OK_%DATUM%.txt"
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
if %DB_HIBA% GTR 0 (
    %UI% :SAV HIBA "FIGYELEM: %DB_HIBA% tétel hibával zárult – nézd át a listát és a naplót."
) else if %DB_KIHAGY% GTR 0 (
    %UI% :SAV OK "KÉSZ – minden elérhető tétel rendben."
    echo   !C_SZURKE!A kihagyott tételek ezen a gépen nem léteztek; ez általában rendben van.!C_0!
) else (
    %UI% :SAV OK "KÉSZ – minden tétel sikeresen lefutott."
)
echo.
%UI% :ADAT "%HELY_CIMKE%" "%OSSZ_HELY%"
%UI% :ADAT "Összegzés" "%OSSZ_NEV%"
if defined TODO for %%x in ("!TODO!") do %UI% :ADAT "Teendők" "%%~nxx"
call :NAPLO_NEV
%UI% :ADAT "Napló" "!NAPLO_NEV!"

if "%MODUL%"=="alapalk" (
    echo.
    if "!AA_MOD!"=="beallit" if "!AA_OK!"=="1" (
        echo   !C_ZOLD!Alapértelmezett alkalmazások: BEÁLLÍTVA.!C_0!
        echo   A felhasználónak ki és be kell jelentkeznie. Utána ellenőrizd: a segédlet
        echo   sima indításával, 5. menüpont.
    )
    if "!AA_MOD!"=="beallit" if not "!AA_OK!"=="1" if "!E_1!"=="KIHAGYVA" echo   !C_SARGA!Alapértelmezett alkalmazások: nem módosítva – a céges beállítás marad.!C_0!
    if "!AA_MOD!"=="beallit" if not "!AA_OK!"=="1" if not "!E_1!"=="KIHAGYVA" echo   !C_PIROS!Alapértelmezett alkalmazások: NEM SIKERÜLT beállítani – az okát lásd fent.!C_0!
    if "!AA_MOD!"=="ellenoriz" if "!AA_OK!"=="1" echo   !C_ZOLD!Alapértelmezett alkalmazások: MINDEN RENDBEN – a kért programok az!C_0!
    if "!AA_MOD!"=="ellenoriz" if "!AA_OK!"=="1" echo   !C_ZOLD!alapértelmezettek.!C_0!
    if "!AA_MOD!"=="ellenoriz" if not "!AA_OK!"=="1" echo   !C_PIROS!Alapértelmezett alkalmazások: NEM MINDEN JÓ – lásd fent.!C_0!
    if "!AA_MOD!"=="ellenoriz" if not "!AA_OK!"=="1" echo   !C_PIROS!Beállítás: rendszergazdaként, 5. menüpont.!C_0!
)
if "%DO_FEDEL%"=="1" (
    echo.
    if "!FEDEL_OK!"=="1" (
        echo   !C_ZOLD!Fedél lehajtása: BEÁLLÍTVA – lehajtáskor nem történik semmi.!C_0!
    ) else (
        echo   !C_PIROS!Fedél lehajtása: NEM SIKERÜLT beállítani – az okát lásd fent a listában.!C_0!
    )
)
if "%DO_BL%"=="1" (
    echo.
    echo   !C_FEHER!Teendő:!C_0! kövesd az MBAM ablakot, a titkosítás utána a háttérben fut.
)

echo.
%UI% :LABLEC TELJES
>>"%OSSZ_FAJL%" echo.
>>"%OSSZ_FAJL%" echo Eszközcsere segédlet %VERZIO% · Készítette: %SZERZO%

echo.
if %DB_HIBA% GTR 0 (
    %UI% :VALASZT IN "Megnyissam a naplót?"
    if not errorlevel 2 start "" notepad "%LOG%"
)
if defined TODO (
    %UI% :VALASZT IN "Megnyissam a teendők listáját?"
    if not errorlevel 2 start "" notepad "%TODO%"
)
if "%MODUL%"=="mentes" (
    %UI% :VALASZT IN "Megnyissam a mentés mappáját ellenőrzésre?"
    if not errorlevel 2 start "" explorer "%CEL%"
)
if "%MODUL%"=="visszaallitas" (
    %UI% :VALASZT IN "Megnyissam a mentés mappáját a listákkal?"
    if not errorlevel 2 start "" explorer "%FORRAS%"
)
echo.
echo   Kész. Kilépéshez nyomj meg egy billentyűt...
pause >nul
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

:TESZT
set "OSSZ_FAJL=nul"
echo.
%UI% :CIM "Próbafuttatás eredménye – semmi nem lett másolva"
for /l %%i in (1,1,%OSSZES%) do %UI% :OSSZ_SOR %%i
%UI% :VONAL
echo     Rendben: %DB_OK%     Probléma: %DB_HIBA%     Kihagyva: %DB_KIHAGY%     Időtartam: %E_PERC% perc %E_MP% mp
echo.
if %DB_HIBA% GTR 0 (
    %UI% :SAV HIBA "PRÓBAFUTTATÁS: %DB_HIBA% probléma – javítsd ezeket az éles mentés előtt."
) else (
    %UI% :SAV OK "PRÓBAFUTTATÁS SIKERES – a mentés ezen a gépen lefuttatható."
)
if defined FUTO (
    echo.
    echo   !C_SARGA!Éles mentés előtt be kell zárni:!FUTO!!C_0!
)
echo.
echo   !C_SZURKE!A próbafuttatás semmit nem hozott létre a külső meghajtón.!C_0!
echo   !C_SZURKE!A megnyitott programok által zárolt fájlokat nem tudja ellenőrizni.!C_0!
echo.
%UI% :ADAT "Napló" "%LOG%"
echo.
%UI% :LABLEC TELJES
echo.
if %DB_HIBA% GTR 0 (
    %UI% :VALASZT IN "Megnyissam a naplót?"
    if not errorlevel 2 start "" notepad "%LOG%"
)
echo.
echo   Kész. Kilépéshez nyomj meg egy billentyűt...
pause >nul
goto :eof
