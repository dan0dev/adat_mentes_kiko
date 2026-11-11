@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem A futas UTF-8 kodlapon megy, igy az ekezetes szovegek es fajlnevek helyesek.
rem Az eredeti kodlapot a vegen visszaallitjuk - nyitott cmd ablakbol inditva szamit.
rem A nul bemenet kell: a chcp kulonben elnyelhetne a bemenetet.
set "PM_KODLAP="
for /f "tokens=2 delims=:." %%c in ('chcp ^<nul') do set "PM_KODLAP=%%c"
if defined PM_KODLAP set "PM_KODLAP=!PM_KODLAP: =!"
>nul chcp 65001 <nul

rem ---------- Nev, verzio, keszito - a kepernyokon es a fajlokban ----------
rem A verziot a verzio.txt adja - a kiadas.ps1 irja at, a frissites ezt hasonlitja ossze
set "VERZIO="
if exist "%~dp0verzio.txt" set /p VERZIO=<"%~dp0verzio.txt"
if defined VERZIO set "VERZIO=!VERZIO: =!"
if not defined VERZIO set "VERZIO=?"
set "SZERZO=Kakuk Dániel"
title Eszközcsere segédlet %VERZIO%

rem ==========================================================
rem  Eszkozcsere segedlet: adatok mentese, exportalasa, BitLocker
rem  Csak beepitett Windows eszkozok: cmd, robocopy, es
rem  ellenorzesekhez powershell.
rem
rem  Ez a belepesi pont: kornyezet, menu, a menupont inditasa.
rem    config\   beallitasok es listak - bovites itt
rem    modulok\  menupontonkent egy fajl: a kepernyok es a sorrend
rem    lib\      a munkat vegzo kozos segedrutinok
rem    ps\       a PowerShell reszek
rem  Reszletek: README.md
rem ==========================================================

rem ---------- Mappak ----------
set "APP=%~dp0"
set "APP=%APP:~0,-1%"
set "CONF=%APP%\config"
set "MODULOK=%APP%\modulok"
set "LIB=%APP%\lib"
set "PSDIR=%APP%\ps"

rem ---------- Segedrutinok hivasa, pl.: %UI% :JELOL OK "uzenet" ----------
rem Idezojel nelkuli set: igy a & vagy zarojel a mappa neveben sem gond
set UI=call "%LIB%\ui.cmd"
set KEZDO=call "%LIB%\kezdokepernyo.cmd"
set MASOLAS=call "%LIB%\masolas.cmd"
set TETELEK=call "%LIB%\tetelek.cmd"
set ELLENORZES=call "%LIB%\ellenorzes.cmd"
set OUTLOOK=call "%LIB%\outlook.cmd"
set PROGRAMLISTA=call "%LIB%\programlista.cmd"
set TALCA=call "%LIB%\talca.cmd"
set NYOMTATOK=call "%LIB%\nyomtatok.cmd"
set IKONOK=call "%LIB%\ikonok.cmd"
set BITLOCKER=call "%LIB%\bitlocker.cmd"
set CHROME=call "%LIB%\chrome.cmd"
set FRISSITES=call "%LIB%\frissites.cmd"
set ESZK=call "%LIB%\eszkozok.cmd"
set TEENDOK=call "%LIB%\teendok.cmd"
set OSSZEGZES=call "%LIB%\osszegzes.cmd"

rem PowerShell resz futtatasa: set "PS_FAJL=%PSDIR%\nev.ps1", utana %PS_FUTTAT%
rem Szovegkent tolti be, igy a vegrehajtasi hazirend nem tiltja le a .ps1 fajlt
set PS_FUTTAT=powershell -NoProfile -NonInteractive -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; & ([scriptblock]::Create([IO.File]::ReadAllText($env:PS_FAJL)))"

rem ---------- Beallitasok ----------
call "%CONF%\beallitasok.cmd"
rem Teszt kornyezet: a tesztkornyezet\futtat.ps1 ezen keresztul irja felul a beallitasokat
if defined PM_TESZT_KONFIG call "%PM_TESZT_KONFIG%"

rem ---------- Szinek ----------
%UI% :SZINEK_BEALLIT

rem ---------- Datum a fajlnevekhez, pl. 2026-10-16 ----------
set "DATUM="
for /f %%d in ('powershell -NoProfile -NonInteractive -Command "Get-Date -Format yyyy-MM-dd" 2^>nul') do set "DATUM=%%d"
rem A kepernyore es a dokumentumokba: 2026. 10. 27.
if defined DATUM set "DATUM_SZEP=%DATUM:~0,4%. %DATUM:~5,2%. %DATUM:~8,2%."
if not defined DATUM (
    set "DATUM_SZEP=%date%"
    set "DATUM=%date%"
    set "DATUM=!DATUM:/=-!"
    set "DATUM=!DATUM:.=-!"
    set "DATUM=!DATUM: =!"
    if "!DATUM:~-1!"=="-" set "DATUM=!DATUM:~0,-1!"
)
set "MOD_NEV="
set "FUTO="

rem ---------- Asztal valodi helye, ha at van iranyitva ----------
set "DESK="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul ^| find "REG_"') do set "DESK=%%b"
if defined DESK call set "DESK=%DESK%"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
rem Tesztkornyezet: a hamis profil asztala - a valodi asztalhoz a teszt nem nyul
if defined PM_TESZT_DESK set "DESK=%PM_TESZT_DESK%"

rem ---------- Szamlalok ----------
set /a OSSZES=0, LEPES=0, DB_OK=0, DB_HIBA=0, DB_KIHAGY=0, DB_ATUGORVA=0
set /a DO_IKON=0, DO_BL=0
set "LOG=%TEMP%\profil_mentes_naplo.txt"
set "IRHATO=1"
set "CEL="
set "FORRAS="
set "DRIVE="
set "OL_PST="

set "ADMIN=0"
net session >nul 2>&1 && set "ADMIN=1"
rem A net session a Kiszolgalo (Server) szolgaltatast igenyli - ahol az ki van kapcsolva,
rem rendszergazdakent is hibat ad. Ilyenkor a folyamat integritasi szintje dont:
rem S-1-16-12288 = magas szint, vagyis emelt (rendszergazdai) ablak.
if "%ADMIN%"=="0" (
    whoami /groups 2>nul | find "S-1-16-12288" >nul && set "ADMIN=1"
)
rem ESZKOZOK parameter: ez mar a megnyitott rendszergazdai ablak - innen soha nem nyitunk ujat
set "ES_EMELT_ABLAK="
if /I "%~1"=="ESZKOZOK" set "ES_EMELT_ABLAK=1"
rem Tesztkornyezet: a rendszergazdai agak kiprobalasa rendszergazdai jog nelkul
if defined PM_TESZT_ADMIN set "ADMIN=%PM_TESZT_ADMIN%"

rem ==========================================================
rem  Kezdokepernyo es menu - a menupont utan ide ter vissza, X: kilepes
rem ==========================================================
rem ESZKOZOK parameterrel - a rendszergazdai ablak - rogton az eszkozok jonnek, utana kilep
:FOMENU
set "MOD="
if /I "%~1"=="ESZKOZOK" set "MOD=5"
if defined MOD goto :MENUPONT
%KEZDO% :MUTAT
%UI% :VALASZT 123456X "Válassz menüpontot [1–6], kilépés: X" N
set "MOD=%errorlevel%"
:MENUPONT
rem X (7) vagy elfogyott bemenet (255): kilepes
if %MOD% GEQ 7 goto :KILEPES

rem Menupont -> nev es modul. Uj menupontnal: lib\kezdokepernyo.cmd, egy betu a VALASZT-ba, es egy sor ide.
rem A tovabbi kod csak a MODUL valtozot nezi, a sorszamot nem.
set "MODUL="
if "%MOD%"=="1" set "MOD_NEV=Adatok mentése"               & set "MODUL=mentes"
if "%MOD%"=="2" set "MOD_NEV=Adatok visszaállítása"        & set "MODUL=visszaallitas"
if "%MOD%"=="3" set "MOD_NEV=BitLocker beállítása"         & set "MODUL=bitlocker"
if "%MOD%"=="4" set "MOD_NEV=Chrome telepítése"            & set "MODUL=chrome"
if "%MOD%"=="5" set "MOD_NEV=Rendszergazdai eszközök"      & set "MODUL=eszkozok"
if "%MOD%"=="6" set "MOD_NEV=Segédlet frissítése"          & set "MODUL=frissites"
if not defined MODUL goto :KILEPES
call :MENUPONT_FUT
if errorlevel 3 goto :KILEPES
if /I "%~1"=="ESZKOZOK" goto :KILEPES
title Eszközcsere segédlet %VERZIO%
goto :FOMENU

:MENUPONT_FUT
rem Minden menupont sajat, helyi kornyezetben fut: a szamlalok, a naplo es a tobbi
rem eredmeny a vegen magatol visszaall - a kovetkezo menupont tisztan indul.
rem A modul kilepesi kodja:
rem   0 = vegigment, teljes osszegzes   1 = a felhasznalo nem kerte - vissza a menube
rem   2 = nem indult el, az ok fent     3 = kilepes a programbol
rem   4 = vegigment, rovid zaras (egylepeses menupont)   5 = nincs teendo (NINCS_TEENDO)
setlocal
set /a OSSZES=0, LEPES=0, DB_OK=0, DB_HIBA=0, DB_KIHAGY=0, DB_ATUGORVA=0, DO_IKON=0, DO_BL=0
set "LOG=%TEMP%\profil_mentes_naplo.txt"
set "IRHATO=1"
set "CEL="
set "FORRAS="
set "DRIVE="
set "OL_PST="
set "NINCS_TEENDO="
set "MOD_KILEP="
title Eszközcsere segédlet %VERZIO% – %MOD_NEV%
call "%MODULOK%\%MODUL%.cmd"
set "_rc=%errorlevel%"
if "%_rc%"=="0" %OSSZEGZES% :OSSZEGZES
if "%_rc%"=="4" %OSSZEGZES% :ROVID
if "%_rc%"=="2" (
    echo.
    %UI% :SAV FIGYEL "Nem indult el – az okát fent látod."
    echo.
    %UI% :BILLENTYU "Vissza a menübe: nyomj meg egy billentyűt…"
)
if "%_rc%"=="5" (
    echo.
    %UI% :SAV OK "!NINCS_TEENDO!"
    echo.
    %UI% :BILLENTYU "Vissza a menübe: nyomj meg egy billentyűt…"
)
if "%_rc%"=="3" exit /b 3
if "%MOD_KILEP%"=="1" exit /b 3
exit /b 0

:KILEPES
if defined PM_KODLAP >nul chcp !PM_KODLAP! <nul
exit /b 0
