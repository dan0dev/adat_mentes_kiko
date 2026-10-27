rem ==========================================================
rem  2. Adatok exportalasa (eszkozcsere uj) - a mentes visszaallitasa
rem
rem  A visszaallitando tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :MEGSZAKITVA
%ELLENORZES% :MEGHAJTO

if not exist "%ROOT%\" (
    echo    !C_PIROS!Nincs mentes mappa a kulso meghajton: !ROOT!!C_0!
    goto :MEGSZAKITVA
)

rem ---------- Mentes kivalasztasa ----------
cls
%UI% :CIM "ADATOK EXPORTALASA - MENTES KIVALASZTASA"
set /a N=0
for /d %%F in ("%ROOT%\*") do (
    set /a N+=1
    set "MENTES_!N!=%%~fF"
    echo      !N! - %%~nxF   [%%~tF]
)
if %N%==0 (
    echo    !C_PIROS!Nincs mentes a kulso meghajton.!C_0!
    goto :MEGSZAKITVA
)

:VALASZT
set "SZAM="
echo.
set /p "SZAM=   Melyiket allitsam vissza? Szam: "
if not defined SZAM goto :VALASZT
rem Ellenorzes pipe nelkul: csak szamjegyek
set "_n="
for /f "tokens=1,* delims=0123456789" %%x in ("x!SZAM!") do if not "%%x%%y"=="x" set "_n=1"
if defined _n (
    echo    !C_PIROS!Csak szamot adj meg.!C_0!
    goto :VALASZT
)
if not defined MENTES_%SZAM% (
    echo    !C_PIROS!Nincs ilyen sorszam.!C_0!
    goto :VALASZT
)
set "FORRAS=!MENTES_%SZAM%!"

rem Ellenorzes: a mentes ennek a felhasznalonak keszult-e
for %%x in ("!FORRAS!") do set "F_NEV=%%~nxx"
echo %F_NEV%| findstr /B /I /L /C:"%USERNAME%_" >nul
if errorlevel 1 (
    echo.
    echo    !C_PIROS!FIGYELEM: ez a mentes nem %USERNAME% felhasznaloe: !F_NEV!!C_0!
    echo    Kozos kulso meghajton konnyu rossz mappat valasztani.
    %UI% :VALASZT IN "   Biztosan ezt allitsam vissza"
    if errorlevel 2 goto :VALASZT
)

rem ---------- Elokeszites ----------
cls
%UI% :CIM "ADATOK EXPORTALASA - ELOKESZITES"
echo    Forras : %FORRAS%
echo    Cel    : %USERNAME% profilja ezen a gepen
echo.
echo    !C_SARGA!Az azonos nevu fajlok felulirodnak, pl. bongeszo konyvjelzok es beallitasok.!C_0!
echo    !C_SARGA!Tipp: a Chrome-ot es az Edge-et visszaallitas elott meg ne inditsd el ezen a gepen.!C_0!

if "%IRHATO%"=="0" (
    echo.
    echo    !C_SARGA!A kulso meghajto nem irhato, a log ide kerul: !TEMP!!C_0!
)

echo.
echo    !C_FEHER!Az adatok utan, opcionalisan:!C_0!
set /a DO_IKON=0
%UI% :VALASZT IN "   Office parancsikonok ellenorzese es javitasa az asztalon"
if not errorlevel 2 set /a DO_IKON=1

echo.
echo    Hely ellenorzese, egy pillanat...
set "PS_FORRASOK=%FORRAS%"
set "PS_BETU=%SystemDrive%"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
%UI% :VALASZT IN "   Indulhat az exportalas"
if errorlevel 2 goto :MEGSZAKITVA

%TETELEK% :BETOLT
set /a OSSZES=T_DB+DO_IKON
if "%IRHATO%"=="1" (set "LOG=%FORRAS%\visszaallitas_log.txt") else (set "LOG=%TEMP%\visszaallitas_log.txt")
>>"%LOG%" echo ===== VISSZAALLITAS %date% %time% - %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\visszaallitas_log.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "ADATOK EXPORTALASA FOLYAMATBAN"
echo    Ne huzd ki a kulso meghajtot, amig a script fut.

rem ---------- Lepesek ----------
%TETELEK% :FUTTAT VISSZA

if "%DO_IKON%"=="1" (
    %UI% :FEJLEC "Office parancsikonok"
    %IKONOK% :JAVIT
)
exit /b 0

:MEGSZAKITVA
exit /b 1
