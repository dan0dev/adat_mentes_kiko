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
title %MOD_NEV% kesz - Profil mentes
if "%TESZTMOD%"=="1" goto :TESZT

rem Osszegzes fajl - az eredmeny mar a fajlnevben latszik
set "OSSZ_HELY=%TEMP%"
set "OSSZ_ELO=_LAPTOP"
if "%MOD%"=="5" set "OSSZ_ELO=_ALAPALK"
if "%MOD%"=="1" set "OSSZ_HELY=%CEL%"
if "%MOD%"=="1" set "OSSZ_ELO=_MENTES"
if "%MOD%"=="2" set "OSSZ_ELO=_EXPORT"
if "%MOD%"=="2" if "%IRHATO%"=="1" set "OSSZ_HELY=%FORRAS%"
if %DB_HIBA%==0 (
    set "OSSZ_NEV=%OSSZ_ELO%_OK_%DATUM%.txt"
) else (
    set "OSSZ_NEV=%OSSZ_ELO%_%DB_HIBA%_HIBA_%DATUM%.txt"
)
rem A korabbi futasok sajat osszegzes fajljai, hogy ne legyen ket ellentmondo
del /q "%OSSZ_HELY%\%OSSZ_ELO%_*.txt" >nul 2>&1
set "OSSZ_FAJL=%OSSZ_HELY%\%OSSZ_NEV%"
(>"%OSSZ_FAJL%" echo %MOD_NEV% osszegzes) 2>nul
if not exist "%OSSZ_FAJL%" (
    set "OSSZ_HELY=%TEMP%"
    set "OSSZ_FAJL=%TEMP%\%OSSZ_NEV%"
)
>"%OSSZ_FAJL%" echo %MOD_NEV% osszegzes - %DATUM% %time:~0,5%
>>"%OSSZ_FAJL%" echo Felhasznalo: %USERNAME%   Gep: %COMPUTERNAME%
>>"%OSSZ_FAJL%" echo.

rem Kezi teendok listaja
set "TODO="
if "%MOD%"=="1" %TEENDOK% :MENTES
if "%MOD%"=="2" %TEENDOK% :EXPORT

echo.
%UI% :CIM "OSSZEGZES - %MOD_NEV%"
for /l %%i in (1,1,%OSSZES%) do %UI% :OSSZ_SOR %%i
echo.
echo  ----------------------------------------------------------
echo    Sikeres: !C_ZOLD!%DB_OK%!C_0!    Hiba: !C_PIROS!%DB_HIBA%!C_0!    Kihagyva: !C_SARGA!%DB_KIHAGY%!C_0!
echo    Idotartam : %E_PERC% perc %E_MP% mp
echo    Helye     : %OSSZ_HELY%
echo    Osszegzes : %OSSZ_NEV%
if defined TODO echo    Teendok   : _LEFT-TO-DO.txt
echo    Log       : %LOG%
echo  ----------------------------------------------------------
>>"%OSSZ_FAJL%" echo.
>>"%OSSZ_FAJL%" echo Sikeres: %DB_OK%  Hiba: %DB_HIBA%  Kihagyva: %DB_KIHAGY%  Idotartam: %E_PERC% perc %E_MP% mp
echo.
if %DB_HIBA% GTR 0 (
    echo  !C_PIROS_HATTER!   FIGYELEM: %DB_HIBA% tetel hibaval zarult. Nezd meg a fenti listat es a logot.   !C_0!
) else if %DB_KIHAGY% GTR 0 (
    echo  !C_ZOLD_HATTER!   KESZ - minden letezo tetel rendben.   !C_0!
    echo    A kihagyott tetelek ezen a gepen nem leteztek, ez altalaban rendben van.
) else (
    echo  !C_ZOLD_HATTER!   MINDEN RENDBEN - minden tetel sikeresen lefutott.   !C_0!
)

if defined TODO (
    echo.
    if "%MOD%"=="1" echo    !C_FEHER!Kezi teendok a regi gepen es kesobb az uj gepen: _LEFT-TO-DO.txt!C_0!
    if "%MOD%"=="2" echo    !C_FEHER!Kezi teendok az uj gepen: _LEFT-TO-DO.txt, 2. resz!C_0!
)
if "%MOD%"=="5" (
    echo.
    if "!AA_MOD!"=="beallit" if "!AA_OK!"=="1" (
        echo    !C_ZOLD!Alapertelmezett alkalmazasok: BEALLITVA.!C_0!
        echo    A felhasznalo jelentkezzen ki es be. Utana ellenorizd: script sima inditasa - 5-os menu.
    )
    if "!AA_MOD!"=="beallit" if not "!AA_OK!"=="1" if "!E_1!"=="KIHAGYVA" echo    !C_SARGA!Alapertelmezett alkalmazasok: nem modositva - a ceges beallitas marad.!C_0!
    if "!AA_MOD!"=="beallit" if not "!AA_OK!"=="1" if not "!E_1!"=="KIHAGYVA" echo    !C_PIROS!Alapertelmezett alkalmazasok: NEM SIKERULT beallitani - az okat lasd fent.!C_0!
    if "!AA_MOD!"=="ellenoriz" if "!AA_OK!"=="1" echo    !C_ZOLD!Alapertelmezett alkalmazasok: MINDEN RENDBEN - a kert programok az alapertelmezettek.!C_0!
    if "!AA_MOD!"=="ellenoriz" if not "!AA_OK!"=="1" echo    !C_PIROS!Alapertelmezett alkalmazasok: NEM MINDEN JO - lasd fent. Beallitas: rendszergazdakent, 5-os menu.!C_0!
)
if "%DO_FEDEL%"=="1" (
    echo.
    if "!FEDEL_OK!"=="1" (
        echo    !C_ZOLD!Fedel lehajtasa: BEALLITVA - lehajtaskor nem tortenik semmi.!C_0!
    ) else (
        echo    !C_PIROS!Fedel lehajtasa: NEM SIKERULT beallitani - az okat lasd fent a listaban.!C_0!
    )
)
if "%DO_BL%"=="1" (
    echo.
    echo    !C_FEHER!Teendo:!C_0! kovesd az MBAM ablakot, a titkositas utana a hatterben fut
)

echo.
if %DB_HIBA% GTR 0 (
    %UI% :VALASZT IN "   Megnyissam a logot"
    if not errorlevel 2 start "" notepad "%LOG%"
)
if defined TODO (
    %UI% :VALASZT IN "   Megnyissam a teendok listajat - _LEFT-TO-DO.txt"
    if not errorlevel 2 start "" notepad "%TODO%"
)
if "%MOD%"=="1" (
    %UI% :VALASZT IN "   Megnyissam a mentes mappat ellenorzesre"
    if not errorlevel 2 start "" explorer "%CEL%"
)
if "%MOD%"=="2" (
    %UI% :VALASZT IN "   Megnyissam a mentes mappat - outlook_lista.txt, apps.txt, talca.txt"
    if not errorlevel 2 start "" explorer "%FORRAS%"
)
echo.
echo    Kesz. Nyomj meg egy gombot a bezarashoz...
pause >nul
goto :eof

:TESZT
set "OSSZ_FAJL=nul"
echo.
%UI% :CIM "TESZT EREDMENYE - semmi nem lett masolva"
for /l %%i in (1,1,%OSSZES%) do %UI% :OSSZ_SOR %%i
echo.
echo  ----------------------------------------------------------
echo    Rendben: !C_ZOLD!%DB_OK%!C_0!    Problema: !C_PIROS!%DB_HIBA%!C_0!    Kihagyva: !C_SARGA!%DB_KIHAGY%!C_0!
echo    Idotartam : %E_PERC% perc %E_MP% mp
echo    Log       : %LOG%
echo  ----------------------------------------------------------
echo.
if %DB_HIBA% GTR 0 (
    echo  !C_PIROS_HATTER!   TESZT: %DB_HIBA% problema. Javitsd ezeket, mielott elesben mentesz.   !C_0!
) else (
    echo  !C_ZOLD_HATTER!   TESZT SIKERES - a mentes lefuthat ezen a gepen.   !C_0!
)
if defined FUTO (
    echo.
    echo    !C_SARGA!Eles mentes elott be kell majd zarni:!FUTO!!C_0!
)
echo.
echo    A teszt nem hozott letre semmit a kulso meghajton.
echo    A megnyitott programok altal zarolt fajlokat a teszt nem tudja ellenorizni.
echo.
if %DB_HIBA% GTR 0 (
    %UI% :VALASZT IN "   Megnyissam a logot"
    if not errorlevel 2 start "" notepad "%LOG%"
)
echo.
echo    Kesz. Nyomj meg egy gombot a bezarashoz...
pause >nul
goto :eof
