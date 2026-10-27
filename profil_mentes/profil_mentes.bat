@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem A futas UTF-8 kodlapon megy, igy az ekezetes szovegek es fajlnevek helyesek.
rem Az eredeti kodlapot a vegen visszaallitjuk - nyitott cmd ablakbol inditva szamit.
rem A nul bemenet kell: a chcp kulonben elnyelhetne a bemenetet.
set "PM_KODLAP="
for /f "tokens=2 delims=:." %%c in ('chcp ^<nul') do set "PM_KODLAP=%%c"
if defined PM_KODLAP set "PM_KODLAP=!PM_KODLAP: =!"
>nul chcp 65001 <nul
title Profil mentes / visszaallitas

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
set MASOLAS=call "%LIB%\masolas.cmd"
set TETELEK=call "%LIB%\tetelek.cmd"
set ELLENORZES=call "%LIB%\ellenorzes.cmd"
set OUTLOOK=call "%LIB%\outlook.cmd"
set PROGRAMLISTA=call "%LIB%\programlista.cmd"
set TALCA=call "%LIB%\talca.cmd"
set ATNEZENDO=call "%LIB%\atnezendo.cmd"
set IKONOK=call "%LIB%\ikonok.cmd"
set ALAPALK=call "%LIB%\alapalk.cmd"
set LAPTOP=call "%LIB%\laptop.cmd"
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
if not defined DATUM (
    set "DATUM=%date%"
    set "DATUM=!DATUM:/=-!"
    set "DATUM=!DATUM:.=-!"
    set "DATUM=!DATUM: =!"
    if "!DATUM:~-1!"=="-" set "DATUM=!DATUM:~0,-1!"
)
set /a OL_KINT=0
set "TESZTMOD=0"
set "MOD_NEV="
set "T_HELY="
set "FUTO="

rem ---------- Asztal valodi helye, ha at van iranyitva ----------
set "DESK="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul ^| find "REG_"') do set "DESK=%%b"
if defined DESK call set "DESK=%DESK%"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"

rem ---------- Szamlalok ----------
set /a OSSZES=0, LEPES=0, DB_OK=0, DB_HIBA=0, DB_KIHAGY=0
set /a DO_IKON=0, DO_BL=0, DO_FEDEL=0, ATN_DB=0
set "AA_MOD="
set "AA_OK=0"
set "LOG=%TEMP%\profil_mentes_log.txt"
set "IRHATO=1"
set "CEL="
set "FORRAS="
set "DRIVE="
set "OL_PST="

set "ADMIN=0"
net session >nul 2>&1 && set "ADMIN=1"

rem ==========================================================
rem  Kezdokepernyo
rem ==========================================================
cls
%UI% :CIM "ESZKOZCSERE SEGEDLET"
echo    Felhasznalo : !C_FEHER!%USERNAME%!C_0!
echo    Gep         : %COMPUTERNAME%
echo    Profil      : %USERPROFILE%
if "%ADMIN%"=="1" echo    Jogosultsag : !C_SARGA!rendszergazda!C_0!

echo.
echo    !C_FEHER!Nyomja meg a kivant lehetoseg sorszamat:!C_0!
echo.
echo      1. Adatok mentese (eszkozcsere regi)
echo      2. Adatok exportalasa (eszkozcsere uj)
echo      3. BitLocker aktivalasa, fedel beallitasa (laptop)
echo      4. Teszt futtatas - a mentes probaja, nem masol semmit
echo      5. Alapertelmezett alkalmazasok - Word, Excel, PowerPoint, PDF, Chrome
echo.
%UI% :VALASZT 12345 "   Valasztas [1/2/3/4/5]: " N
set "MOD=%errorlevel%"

rem Menupont -> nev es modul. Uj menupontnal: fenti lista, egy betu a VALASZT-ba, es egy sor ide.
set "MODUL="
if "%MOD%"=="1" set "MOD_NEV=Adatok mentese"               & set "MODUL=mentes"
if "%MOD%"=="2" set "MOD_NEV=Adatok exportalasa"           & set "MODUL=export"
if "%MOD%"=="3" set "MOD_NEV=Laptop beallitasok"           & set "MODUL=laptop"
if "%MOD%"=="4" set "MOD_NEV=Teszt futtatas"               & set "MODUL=mentes"
if "%MOD%"=="5" set "MOD_NEV=Alapertelmezett alkalmazasok" & set "MODUL=alapalk"
if "%MOD%"=="4" set "TESZTMOD=1"
if not defined MODUL goto :MEGSZAKITVA

rem A modul 0-val ter vissza, ha vegigment, 1-gyel, ha megszakitottak
call "%MODULOK%\%MODUL%.cmd"
if errorlevel 1 goto :MEGSZAKITVA

%OSSZEGZES% :OSSZEGZES
if defined PM_KODLAP >nul chcp !PM_KODLAP! <nul
exit /b 0

:MEGSZAKITVA
echo.
echo    !C_SARGA!Megszakitva. Nem tortent valtoztatas.!C_0!
echo.
pause
if defined PM_KODLAP >nul chcp !PM_KODLAP! <nul
exit /b 1
