rem ==========================================================
rem  5. Rendszergazdai eszkozok: Win+R parancsok, halozat, javitas
rem  Kulon, rendszergazdai ablakban fut: a jelszot egyszer kell megadni, amikor
rem  az ablak megnyilik - utana minden eszkoz jelszo nelkul indul.
rem  Ha a segedlet mar rendszergazdakent fut, rogton a menu jon.
rem  Az eszkozok listaja: config\eszkozok.cmd. A munka: lib\eszkozok.cmd
rem  Kilepesi kod: 1 = megszakitva, 3 = kilepes osszegzes nelkul
rem ==========================================================

set "LOG=%TEMP%\eszkozok_naplo.txt"
if "%ADMIN%"=="1" goto :ES_MENU

rem ---------- Rendszergazdai ablak megnyitasa ----------
cls
%UI% :CIM "Rendszergazdai eszközök"
echo   Win+R parancsok, hálózati teszt és helyreállítás, rendszerjavítás.
echo.
echo   Ezekhez rendszergazdai jog kell. Az eszközök egy külön, rendszergazdai
echo   ablakban nyílnak meg – a jelszót csak egyszer kell beírni, utána minden
echo   eszköz jelszó nélkül indul.
echo.
%UI% :VALASZT IN "Megnyissam a rendszergazdai ablakot?"
if errorlevel 2 exit /b 1
%ESZK% :EMELES
if "%ES_EMELVE%"=="1" exit /b 3
echo.
echo   !C_SARGA!!ES_EMELES_UZENET!!C_0!
exit /b 1

rem ---------- A menu - minden muvelet utan ide ter vissza ----------
:ES_MENU
title Eszközcsere segédlet %VERZIO% – Rendszergazdai eszközök
%ESZK% :BETOLT
:ES_RAJZ
cls
%UI% :CIM "Rendszergazdai eszközök"
%UI% :SZAKASZ "WIN+R PARANCSOK"
echo.
for /l %%i in (1,1,%ES_DB%) do call :ES_SOR %%i
echo.
%UI% :SZAKASZ "HÁLÓZAT"
echo.
%UI% :MENU P "Hálózati teszt" "a Google elérése, eredmény naplóba"
%UI% :MENU H "Hálózat helyreállítása" "ipconfig, netsh – utána újraindítás"
echo.
%UI% :SZAKASZ "JAVÍTÁS"
echo.
%UI% :MENU J "Rendszerfájlok javítása" "DISM, sfc /scannow"
%UI% :MENU L "Lemezellenőrzés" "chkdsk /f /r – újraindításkor fut"
echo.
%UI% :MENU X "Kilépés" ""
%UI% :VONAL
echo.
set "_kb=!ES_BETUK!PHJLX"
%UI% :VALASZT "!_kb!" "Válassz:" N
set /a _v=%errorlevel%-1
if %_v% LSS 0 exit /b 3
if %_v% GEQ 254 exit /b 3
set "_k=!_kb:~%_v%,1!"
if /I "%_k%"=="X" exit /b 3
if /I "%_k%"=="P" (
    %ESZK% :PING
    goto :ES_RAJZ
)
if /I "%_k%"=="H" (
    %ESZK% :HALOZAT
    goto :ES_RAJZ
)
if /I "%_k%"=="J" (
    %ESZK% :JAVITAS
    goto :ES_RAJZ
)
if /I "%_k%"=="L" (
    %ESZK% :LEMEZ
    goto :ES_RAJZ
)
%ESZK% :INDIT "%_k%"
goto :ES_RAJZ

:ES_SOR
rem %1 = az eszkoz sorszama a listaban
%UI% :MENU "!ES_K_%~1!" "!ES_P_%~1!" "!ES_N_%~1!"
goto :eof
