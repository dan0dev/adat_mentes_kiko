rem ==========================================================
rem  3. Adatok visszaallitasa (az uj gepen) - a mentes visszaallitasa
rem
rem  A visszaallitando tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = a felhasznalo nem kerte; 2 = nem indult el
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :NEM_INDULT
:MEGHAJTO_UJRA
%ELLENORZES% :MEGHAJTO
if errorlevel 1 goto :MEGSZAKITVA

rem ---------- Mentes kivalasztasa ----------
rem Ha a meghajton nincs mentes, ujra a betujelet kerdezzuk - nem lepunk ki
set /a N=0
if exist "%ROOT%\" for /d %%F in ("%ROOT%\*") do set /a N+=1
if %N%==0 (
    echo   !C_PIROS!Ezen a meghajtón nincs mentés: !DRIVE!:\%MAPPA_NEV%!C_0!
    goto :MEGHAJTO_UJRA
)
cls
%UI% :CIM "Adatok visszaállítása – mentés kiválasztása"
set /a N=0
set "M_SZAM="
rem A sajat mentes neve igy kezdodik: felhasznalo_ . Az osszevetes findstr es cso nelkul megy:
rem igy az ekezetes nev is egyezik, es a mappa neveben levo ^& sem fut le parancskent.
set "_u=%USERNAME%_"
%UI% :HOSSZ _u _uh
for /d %%F in ("%ROOT%\*") do (
    set /a N+=1
    set "MENTES_!N!=%%~fF"
    echo      !N!   %%~nxF   [%%~tF]
    rem A felhasznalo sajat mentese az alapertek - Enterrel elfogadhato
    set "_fn=%%~nxF"
    if not defined M_SZAM if /I "!_fn:~0,%_uh%!"=="!_u!" set "M_SZAM=!N!"
)
if not defined M_SZAM if %N%==1 set "M_SZAM=1"

:VALASZT
echo.
%UI% :BEKER SZAM "Melyik mentést állítsam vissza?" "%M_SZAM%"
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
if /I not "!F_NEV:~0,%_uh%!"=="!_u!" (
    echo.
    echo   !C_PIROS!Ez a mentés nem ennek a felhasználónak készült: !F_NEV!!C_0!
    %UI% :VALASZT IN "Biztosan ezt állítsam vissza?"
    if errorlevel 2 goto :VALASZT
)

%TETELEK% :BETOLT
rem ---------- Elokeszites ----------
cls
%UI% :CIM "Adatok visszaállítása – előkészítés"
%UI% :ADAT "Felhasználó" "%USERNAME%" SARGA
%UI% :ADAT "Forrás" "%FORRAS%"
echo.
echo   !C_SARGA!Az azonos nevű fájlok felülíródnak.!C_0!
if "%IRHATO%"=="0" (
    echo   !C_SARGA!A külső meghajtó nem írható, a napló ide kerül: !TEMP!!C_0!
)

rem A bongeszo mar futott ezen a gepen? Akkor a profillista atirasat most kerdezzuk -
rem a masolas kozben mar nem.
set "PROFIL_IR=0"
set "B_FUTOTT="
for /l %%i in (1,1,%T_DB%) do if /I "!T_TIPUS_%%i!"=="BONGESZO" (
    if exist "!T_FORRAS_%%i!\Local State" if exist "%FORRAS%\!T_MAPPA_%%i!\profilok.json" if exist "%FORRAS%\!T_MAPPA_%%i!\Profile *" (
        if defined B_FUTOTT (set "B_FUTOTT=!B_FUTOTT!, !T_P1_%%i!") else (set "B_FUTOTT=!T_P1_%%i!")
    )
)
if defined B_FUTOTT (
    echo.
    echo   !C_SARGA!!B_FUTOTT!: ezen a gépen már futott. A többi profilhoz új profillistát!C_0!
    echo   !C_SARGA!írok – az itt mentett jelszavak és sütik elveszhetnek, a régit megtartom.!C_0!
    %UI% :VALASZT IN "Átírjam a profillistát?"
    if not errorlevel 2 set "PROFIL_IR=1"
) else (
    echo   !C_SARGA!A Chrome-ot és az Edge-et a visszaállítás előtt ne indítsd el.!C_0!
)

echo.
echo   Helyellenőrzés, egy pillanat…
set "PS_FORRASOK=%FORRAS%"
set "PS_BETU=%SystemDrive%"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
%UI% :VALASZT IN "Indulhat a visszaállítás?"
if errorlevel 2 goto :MEGSZAKITVA

set /a OSSZES=T_DB
set "EXPLORER_UJRA=0"
if "%IRHATO%"=="1" (set "LOG=%FORRAS%\visszaallitas_naplo.txt") else (set "LOG=%TEMP%\visszaallitas_naplo.txt")
>>"%LOG%" echo ===== VISSZAÁLLÍTÁS %date% %time% – %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\visszaallitas_naplo.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "Adatok visszaállítása folyamatban"
echo   A folyamat végéig ne húzd ki a külső meghajtót.

rem ---------- Lepesek ----------
%TETELEK% :FUTTAT VISSZA

rem Office-parancsikonok: csak akkor lepes, ha van mit kirakni vagy javitani
%IKONOK% :VIZSGAL
if %IK_TEENDO% GTR 0 (
    set /a OSSZES+=1
    %UI% :FEJLEC "Office-parancsikonok"
    %IKONOK% :JAVIT
)
rem A Gyoreleres a Fajlkezelo ujrainditasakor toltodik be - a legvegen, kerdes nelkul
if "%EXPLORER_UJRA%"=="1" (
    echo.
    echo   A Fájlkezelő újraindul, egy pillanat…
    if not defined PM_TESZT_NE_INDITS_UJRA (
        taskkill /F /IM explorer.exe >nul 2>&1
        start "" explorer.exe
    )
)
exit /b 0

:MEGSZAKITVA
exit /b 1

:NEM_INDULT
exit /b 2
