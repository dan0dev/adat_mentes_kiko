@call %*
@exit /b

rem ==========================================================
rem  Kezdokepernyo: keret, a gep adatai, a menu es a keszito
rem  Uj menupontnal: egy %UI% :MENU sor ide, egy betu a VALASZT-ba
rem  es egy sor a menupont -> modul tablaba a segedlet.bat-ban.
rem  Hivas: %KEZDO% :MUTAT
rem ==========================================================

:MUTAT
cls
call :UJ_VERZIO
%UI% :NYITO
%UI% :ADAT "Felhasználó" "%USERNAME%"
%UI% :ADAT "Számítógép" "%COMPUTERNAME%"
%UI% :ADAT "Profil" "%USERPROFILE%"
if "%ADMIN%"=="1" (%UI% :ADAT "Jogosultság" "rendszergazda" SARGA) else (%UI% :ADAT "Jogosultság" "normál felhasználó")
echo.
%UI% :SZAKASZ "A RÉGI GÉPEN"
echo.
%UI% :MENU 1 "Adatok mentése" "a külső meghajtóra"
echo.
%UI% :SZAKASZ "AZ ÚJ GÉPEN"
echo.
%UI% :MENU 2 "Adatok visszaállítása" "a külső meghajtóról"
%UI% :MENU 3 "BitLocker beállítása" "titkosítás indítása az MBAM klienssel"
%UI% :MENU 4 "Chrome telepítése" "ha a Szoftverközpont nem indítja el" "a letöltést"
echo.
%UI% :SZAKASZ "EGYÉB"
echo.
%UI% :MENU 5 "Rendszergazdai eszközök" "Win+R parancsok, hálózat, javítás"
%UI% :MENU 6 "Segédlet frissítése" "a legújabb verzió a GitHubról"
%UI% :MENU 7 "Gép ellenőrzése – [TESZT]" "teljesítmény, hő, lemez, akku"
echo.
%UI% :LABLEC NYITO
echo.
goto :eof

:UJ_VERZIO
rem Sarga sor a legtetejen, ha van ujabb kiadas. Az inditaskori hatterkereses eredmenye:
rem segedlet.bat :FRISS_JELZES -> FR_JEL_FAJL ("UJ 1.3" vagy "NINCS"). Internet nelkul NINCS.
if not defined FR_JEL_FAJL goto :UJ_VERZIO_SOR
if defined FR_JEL_KESZ goto :UJ_VERZIO_SOR
rem Az elso kepernyonel legfeljebb 2 mp-et var a valaszra - a fajl megjelenesekor rogton tovabbmegy.
rem Ha addig nem jott meg, a kovetkezo kirajzolasnal (a menupont utan) mar csak belenez.
if not exist "%FR_JEL_FAJL%" if not defined FR_JEL_VART (
    powershell -NoProfile -NonInteractive -Command "$h=[DateTime]::Now.AddSeconds(2); while(-not [IO.File]::Exists($env:FR_JEL_FAJL) -and [DateTime]::Now -lt $h){Start-Sleep -Milliseconds 50}" <nul >nul 2>&1
)
set "FR_JEL_VART=1"
if not exist "%FR_JEL_FAJL%" goto :UJ_VERZIO_SOR
set "_jel="
set /p _jel=<"%FR_JEL_FAJL%"
del /q "%FR_JEL_FAJL%" >nul 2>&1
set "FR_JEL_KESZ=1"
if "!_jel:~0,3!"=="UJ " set "FR_JEL_VERZIO=!_jel:~3!"
:UJ_VERZIO_SOR
if not defined FR_JEL_VERZIO goto :eof
echo.
%UI% :SAV UJ "Új verzió érhető el: %FR_JEL_VERZIO% – Nyomd meg a [6]-ot a frissítéshez."
goto :eof
