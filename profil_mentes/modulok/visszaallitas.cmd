rem ==========================================================
rem  3. Adatok visszaallitasa (az uj gepen) - a mentes visszaallitasa
rem
rem  A visszaallitando tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :MEGSZAKITVA
%ELLENORZES% :MEGHAJTO
if errorlevel 1 goto :MEGSZAKITVA

if not exist "%ROOT%\" (
    echo   !C_PIROS!Nincs mentés mappa a külső meghajtón: !ROOT!!C_0!
    goto :MEGSZAKITVA
)

rem ---------- Mentes kivalasztasa ----------
cls
%UI% :CIM "Adatok visszaállítása – mentés kiválasztása"
set /a N=0
for /d %%F in ("%ROOT%\*") do (
    set /a N+=1
    set "MENTES_!N!=%%~fF"
    echo      !N!   %%~nxF   [%%~tF]
)
if %N%==0 (
    echo   !C_PIROS!Nincs mentés a külső meghajtón.!C_0!
    goto :MEGSZAKITVA
)

:VALASZT
echo.
%UI% :BEKER SZAM "Melyik mentést állítsam vissza? Sorszám:"
if errorlevel 255 goto :MEGSZAKITVA
if not defined SZAM goto :VALASZT
rem Ellenorzes pipe nelkul: csak szamjegyek
set "_n="
for /f "tokens=1,* delims=0123456789" %%x in ("x!SZAM!") do if not "%%x%%y"=="x" set "_n=1"
if defined _n (
    echo   !C_PIROS!Csak számot adj meg.!C_0!
    goto :VALASZT
)
if not defined MENTES_%SZAM% (
    echo   !C_PIROS!Nincs ilyen sorszám.!C_0!
    goto :VALASZT
)
set "FORRAS=!MENTES_%SZAM%!"

rem Ellenorzes: a mentes ennek a felhasznalonak keszult-e
for %%x in ("!FORRAS!") do set "F_NEV=%%~nxx"
echo %F_NEV%| findstr /B /I /L /C:"%USERNAME%_" >nul
if errorlevel 1 (
    echo.
    echo   !C_PIROS!Figyelem: ez a mentés nem ennek a felhasználónak készült: !F_NEV!!C_0!
    echo   Közös külső meghajtón könnyű rossz mappát választani.
    %UI% :VALASZT IN "Biztosan ezt állítsam vissza?"
    if errorlevel 2 goto :VALASZT
)

rem ---------- Elokeszites ----------
cls
%UI% :CIM "Adatok visszaállítása – előkészítés"
%UI% :ADAT "Forrás" "%FORRAS%"
%UI% :ADAT "Cél" "%USERNAME% profilja ezen a gépen"
echo.
echo   !C_SARGA!Az azonos nevű fájlok felülíródnak, például a böngészők könyvjelzői!C_0!
echo   !C_SARGA!és beállításai.!C_0!
echo   !C_SARGA!Tipp: a Chrome-ot és az Edge-et a visszaállítás előtt még ne indítsd el!C_0!
echo   !C_SARGA!ezen a gépen.!C_0!

if "%IRHATO%"=="0" (
    echo.
    echo   !C_SARGA!A külső meghajtó nem írható, a napló ide kerül: !TEMP!!C_0!
)

echo.
echo   Az adatok után, ha kéred:
set /a DO_IKON=0
%UI% :VALASZT IN "Ellenőrizzem és javítsam az Office-parancsikonokat az asztalon?"
if not errorlevel 2 set /a DO_IKON=1

echo.
echo   Helyellenőrzés, egy pillanat...
set "PS_FORRASOK=%FORRAS%"
set "PS_BETU=%SystemDrive%"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
%UI% :VALASZT IN "Indulhat a visszaállítás?"
if errorlevel 2 goto :MEGSZAKITVA

%TETELEK% :BETOLT
set /a OSSZES=T_DB+DO_IKON
if "%IRHATO%"=="1" (set "LOG=%FORRAS%\visszaallitas_log.txt") else (set "LOG=%TEMP%\visszaallitas_log.txt")
>>"%LOG%" echo ===== VISSZAÁLLÍTÁS %date% %time% – %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\visszaallitas_log.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "Adatok visszaállítása folyamatban"
echo   A folyamat végéig ne húzd ki a külső meghajtót.

rem ---------- Lepesek ----------
%TETELEK% :FUTTAT VISSZA

if "%DO_IKON%"=="1" (
    %UI% :FEJLEC "Office-parancsikonok"
    %IKONOK% :JAVIT
)
exit /b 0

:MEGSZAKITVA
exit /b 1
