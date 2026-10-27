@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem ==========================================================
rem  Képernyőgaléria: a lib\ui.cmd minden rutinja mintaadatokkal.
rem  Futtatás: kepernyok.ps1, vagy dupla kattintással, hogy szemre
rem  összevethető legyen a specifikáció mintáival.
rem ==========================================================
>nul chcp 65001 <nul
set "APP=%~dp0..\profil_mentes"
for %%a in ("%APP%") do set "APP=%%~fa"
set "LIB=%APP%\lib"
set UI=call "%LIB%\ui.cmd"
set "VERZIO=1.0"
set "SZERZO=Kakuk Dániel"
set "LOG=%TEMP%\kepernyok_naplo.txt"
set "OSSZ_FAJL=nul"
set "MOD_NEV=Adatok mentése"
if not defined VALASZ_SORBOL set "VALASZ_SORBOL=0"
set /a OSSZES=16, LEPES=0, DB_OK=0, DB_HIBA=0, DB_KIHAGY=0
%UI% :SZINEK_BEALLIT

rem ---------- Kezdőképernyő ----------
cls
%UI% :NYITO
%UI% :ADAT "Felhasználó" "kakuk"
%UI% :ADAT "Számítógép" "DESKTOP-1234"
%UI% :ADAT "Profil" "C:\Users\kakuk"
%UI% :ADAT "Jogosultság" "rendszergazda" SARGA
echo.
%UI% :SZAKASZ "A RÉGI GÉPEN"
echo.
%UI% :MENU 1 "Adatok mentése" "a külső meghajtóra"
%UI% :MENU 2 "Próbafuttatás" "a mentés ellenőrzése másolás nélkül"
echo.
%UI% :SZAKASZ "AZ ÚJ GÉPEN"
echo.
%UI% :MENU 3 "Adatok visszaállítása" "a külső meghajtón lévő mentésből"
%UI% :MENU 4 "Laptop beállítása" "fedél lehajtása, BitLocker"
%UI% :MENU 5 "Alapértelmezett alkalmazások" "Word, Excel, PowerPoint, PDF, Chrome"
echo.
%UI% :LABLEC NYITO
echo.
%UI% :VALASZT 12345 "Válassz menüpontot [1–5]:" N

rem ---------- Futás ----------
%UI% :CIM "Adatok mentése folyamatban"
echo   A folyamat végéig ne húzd ki a külső meghajtót.
%UI% :FEJLEC "Outlook-aláírások"
%UI% :JELOL OK "3 fájl, ellenőrizve"
%UI% :FEJLEC "Office-sablonok"
%UI% :JELOL KIHAGYVA "ezen a gépen nincs ilyen mappa"
%UI% :FEJLEC "Chrome-profilok"
%UI% :RESZLET "Default, Profile 1"
%UI% :JELOL OK "2 profil, ellenőrizve"
%UI% :FEJLEC "PST-mappa (Outlook)"
%UI% :JELOL HIBA "néhány fájl nem másolható" "Zárolt fájl vagy hiányzó jogosultság – részletek a naplóban."
%UI% :FEJLEC "Office-parancsikonok"
%UI% :JELOL NEMKERT "nem kérted"
%UI% :FEJLEC "Harminckét karakteres lépésnév"
%UI% :JELOL OK "ez az üzenet szándékosan túl hosszú, levágva"

rem ---------- Összegzés ----------
%UI% :CIM "Összegzés – Adatok mentése"
for /l %%i in (1,1,6) do %UI% :OSSZ_SOR %%i
%UI% :VONAL
echo     Sikeres: 3     Hibás: 1     Kihagyva: 1     Időtartam: 3 perc 12 mp
echo.
%UI% :SAV HIBA "FIGYELEM: 1 tétel hibával zárult – nézd át a listát és a naplót."
%UI% :SAV OK "KÉSZ – minden tétel sikeresen lefutott."
%UI% :SAV FIGYEL "Megszakítva – nem történt változtatás."
echo.
%UI% :LABLEC TELJES
echo.
%UI% :VALASZT IN "Megnyissam a naplót?"
echo.
echo   Galéria vége.
