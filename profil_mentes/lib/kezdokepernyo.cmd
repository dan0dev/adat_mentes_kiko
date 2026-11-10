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
%UI% :MENU 2 "Adatok visszaállítása" "a külső meghajtón lévő mentésből"
%UI% :MENU 3 "BitLocker beállítása" "titkosítás indítása az MBAM klienssel"
%UI% :MENU 4 "Chrome telepítése" "ha a Szoftverközpont nem indítja el" "a letöltést"
echo.
%UI% :SZAKASZ "EGYÉB"
echo.
%UI% :MENU 5 "Segédlet frissítése" "a legújabb változat a GitHubról"
echo.
%UI% :LABLEC NYITO
echo.
goto :eof
