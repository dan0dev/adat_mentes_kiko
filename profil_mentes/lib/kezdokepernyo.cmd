@call %*
@exit /b

rem ==========================================================
rem  Kezdokepernyo: keret, a gep adatai, a menu es a keszito
rem  Uj menupontnal: egy %UI% :MENU sor ide, egy betu a VALASZT-ba
rem  es egy sor a menupont -> modul tablaba a Eszkozcsere_segedlet.bat-ban.
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
goto :eof
