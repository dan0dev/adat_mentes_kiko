@call %*
@exit /b

rem ==========================================================
rem  Rendszergazdai eszkozok - a modulok\eszkozok.cmd hivja
rem  Hivas: %ESZK% :CIMKE parameterek
rem    :EMELES   a segedlet ujrainditasa rendszergazdai ablakban, rogton az eszkozokkel
rem    :BETOLT   a config\eszkozok.cmd beolvasasa
rem    :INDIT    egy Win+R parancs inditasa
rem    :PING     halozati teszt - ps\halozat_teszt.ps1, naplo a naplok\ mappaba
rem    :HALOZAT  ipconfig, netsh - egyenkent vagy mind, utana ujrainditas
rem    :JAVITAS  DISM, sfc
rem    :LEMEZ    chkdsk /f /r a kovetkezo inditasra
rem ==========================================================

:EMELES
rem Kimenet: ES_EMELVE = 1, ha az uj ablak elindult, kulonben ES_EMELES_UZENET az ok
set "ES_EMELVE=0"
set "ES_EMELES_UZENET=A rendszergazdai ablak nem nyílt meg."
set "ES_INDITO=%APP%\..\Eszkozcsere_segedlet.bat"
if not exist "%ES_INDITO%" set "ES_INDITO=%APP%\segedlet.bat"
for %%f in ("%ES_INDITO%") do set "ES_INDITO=%%~ff"
set "PS_FAJL=%PSDIR%\emeles.ps1"
for /f "tokens=1,* delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    if "%%a"=="OK" set "ES_EMELVE=1"
    if "%%a"=="NEM" set "ES_EMELES_UZENET=%%b"
)
goto :eof

:BETOLT
set /a ES_DB=0
set "ES_BETUK="
set ESZKOZ=call "%LIB%\eszkozok.cmd" :UJ
call "%CONF%\eszkozok.cmd"
goto :eof

:UJ
rem %1 = billentyu, %2 = parancs, %3 = nev
set /a ES_DB+=1
set "ES_K_%ES_DB%=%~1"
set "ES_P_%ES_DB%=%~2"
set "ES_N_%ES_DB%=%~3"
set "ES_BETUK=!ES_BETUK!%~1"
goto :eof

:INDIT
rem %1 = a leutott billentyu - a listabol a hozza tartozo parancs indul
set "_ep="
for /l %%i in (1,1,%ES_DB%) do if /I "!ES_K_%%i!"=="%~1" (
    set "_ep=!ES_P_%%i!"
    set "_en=!ES_N_%%i!"
)
if not defined _ep goto :eof
echo.
where /q "!_ep!" 2>nul
if errorlevel 1 (
    echo   !C_PIROS!!_en! ^(!_ep!^) – ezen a gépen nincs meg.!C_0!
    >>"%LOG%" echo [%date% %time%] nincs meg: !_ep!
    timeout /t 3 >nul
    goto :eof
)
start "" "!_ep!"
>>"%LOG%" echo [%date% %time%] elinditva: !_ep!
echo   !C_ZOLD!Megnyitva:!C_0! !_en! – !_ep!
timeout /t 1 >nul
goto :eof

:PING
cls
%UI% :CIM "Hálózati teszt"
set "HT_NAPLO="
call :NAPLO_MAPPA
set "HT_NAPLO=%ES_NAPLOK%\halozat_teszt.txt"
set "PS_FAJL=%PSDIR%\halozat_teszt.ps1"
%PS_FUTTAT%
echo.
echo   Napló: !C_FEHER!!HT_NAPLO!!C_0!
call :VISSZA
goto :eof

:NAPLO_MAPPA
rem A naplok\ mappa a profil_mentes mellett - igy a frissites nem torli.
rem Ha ott nem irhato, a felhasznalo TEMP mappaja. Kimenet: ES_NAPLOK
set "ES_NAPLOK=%APP%\..\naplok"
for %%f in ("%ES_NAPLOK%") do set "ES_NAPLOK=%%~ff"
if not exist "%ES_NAPLOK%\" mkdir "%ES_NAPLOK%" 2>nul
set "_nt=%ES_NAPLOK%\_irasteszt_%RANDOM%.tmp"
(echo teszt) >"%_nt%" 2>nul
if exist "%_nt%" (del /q "%_nt%" >nul 2>&1) else (set "ES_NAPLOK=%TEMP%")
goto :eof

:HALOZAT
cls
%UI% :CIM "Hálózat helyreállítása"
echo   Ha a gép nem kap IP-címet, nem tölt be oldalakat, vagy a hálózat
echo   furcsán viselkedik. Egyenként is futtathatók, vagy mind az öt sorban.
echo.
%UI% :MENU 1 "ipconfig /release" "elengedi a gép IP-címét"
%UI% :MENU 2 "ipconfig /flushdns" "törli a névfeloldási (DNS) tárat"
%UI% :MENU 3 "ipconfig /renew" "új IP-címet kér a hálózattól"
%UI% :MENU 4 "netsh winsock reset" "alaphelyzetbe a hálózati réteget"
%UI% :MENU 5 "netsh int ip reset" "alaphelyzetbe a TCP/IP-beállításokat"
echo.
%UI% :MENU M "Mind az öt, sorban" "utána újraindítás kell"
%UI% :MENU X "Vissza" ""
%UI% :VONAL
echo   !C_SARGA!A release és a renew között pár másodpercig nincs hálózat.!C_0!
echo.
%UI% :VALASZT 12345MX "Válassz:" N
set "_hv=%errorlevel%"
if "%_hv%"=="7" goto :eof
if %_hv% GEQ 8 goto :eof
echo.
set "_ujra=0"
if "%_hv%"=="1" call :PARANCS "ipconfig /release" "ipconfig /release"
if "%_hv%"=="2" call :PARANCS "ipconfig /flushdns" "ipconfig /flushdns"
if "%_hv%"=="3" call :PARANCS "ipconfig /renew" "ipconfig /renew"
if "%_hv%"=="4" call :PARANCS "netsh winsock reset" "netsh winsock reset" & set "_ujra=1"
if "%_hv%"=="5" call :PARANCS "netsh int ip reset" "netsh int ip reset" & set "_ujra=1"
if "%_hv%"=="6" (
    call :PARANCS "ipconfig /release" "ipconfig /release"
    call :PARANCS "ipconfig /flushdns" "ipconfig /flushdns"
    call :PARANCS "ipconfig /renew" "ipconfig /renew"
    call :PARANCS "netsh winsock reset" "netsh winsock reset"
    call :PARANCS "netsh int ip reset" "netsh int ip reset"
    set "_ujra=1"
)
if "%_ujra%"=="1" (
    echo.
    echo   A winsock és a TCP/IP alaphelyzetbe állítása újraindítás után él.
    call :UJRAINDITAS "hálózat helyreállítása"
    goto :eof
)
call :VISSZA
goto :eof

:PARANCS
rem %1 = a parancs, ahogy a kepernyon latszik, %2 = a futtatott parancs. A kimenet a naplobe megy.
<nul set /p "=  !C_FEHER!%~1!C_0! ... "
>>"%LOG%" echo [%date% %time%] %~2
%~2 >>"%LOG%" 2>&1
if errorlevel 1 (
    echo !C_PIROS!hiba ^(kód: !errorlevel!^)!C_0! – részletek: %LOG%
) else (
    echo !C_ZOLD!kész!C_0!
)
goto :eof

:JAVITAS
cls
%UI% :CIM "Rendszerfájlok javítása"
%UI% :MENU 1 "DISM /RestoreHealth" "a Windows-kép javítása a Windows" "Update-ből, internettel – 10–30 perc"
%UI% :MENU 2 "sfc /scannow" "a rendszerfájlok ellenőrzése, a" "sérültek cseréje – 10–20 perc"
echo.
%UI% :MENU M "Mindkettő" "előbb a DISM, utána az sfc"
%UI% :MENU X "Vissza" ""
%UI% :VONAL
echo.
%UI% :VALASZT 12MX "Válassz:" N
set "_jv=%errorlevel%"
if %_jv% GEQ 4 goto :eof
if "%_jv%"=="1" call :HOSSZU "DISM /Online /Cleanup-Image /RestoreHealth"
if "%_jv%"=="2" call :HOSSZU "sfc /scannow"
if "%_jv%"=="3" (
    call :HOSSZU "DISM /Online /Cleanup-Image /RestoreHealth"
    call :HOSSZU "sfc /scannow"
)
echo.
echo   Kész – az eredményt fent látod. Ha az sfc javított valamit,
echo   indítsd újra a gépet.
call :VISSZA
goto :eof

:HOSSZU
rem %1 = hosszan futo parancs - a sajat kimenete a kepernyon latszik
echo.
echo   !C_KEK!› %~1!C_0!
>>"%LOG%" echo [%date% %time%] %~1
%~1
>>"%LOG%" echo [%date% %time%] kilépési kód: %errorlevel%
goto :eof

:LEMEZ
cls
%UI% :CIM "Lemezellenőrzés"
echo   chkdsk %SystemDrive% /f /r – javítja a fájlrendszer hibáit ^(/f^), és megkeresi
echo   a hibás szektorokat ^(/r^). A rendszermeghajtót csak induláskor tudja
echo   ellenőrizni: most beütemezem, és a következő újraindításkor fut le.
echo.
echo   !C_SARGA!Induláskor a lemez méretétől függően akár 1–2 óráig is tarthat –!C_0!
echo   !C_SARGA!közben ne kapcsold ki a gépet.!C_0!
echo.
%UI% :VALASZT IN "Beütemezzem a lemezellenőrzést?"
if errorlevel 2 goto :eof
echo.
rem A chkdsk a beutemezesrol kerdez - a valasz a nyelvtol fugg, ezert I es Y is megy
>>"%LOG%" echo [%date% %time%] chkdsk %SystemDrive% /f /r
(echo I& echo Y) | chkdsk %SystemDrive% /f /r >>"%LOG%" 2>&1
set "_cb="
for /f "tokens=2,*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute 2^>nul ^| find "REG_"') do set "_cb=%%b"
set "_cr=!_cb:/r=!"
if not "!_cr!"=="!_cb!" (
    echo   !C_ZOLD!Beütemezve:!C_0! a következő indításkor lefut.
    call :UJRAINDITAS "lemezellenőrzés"
    goto :eof
)
echo   !C_PIROS!Nem sikerült beütemezni – részletek: %LOG%!C_0!
call :VISSZA
goto :eof

:UJRAINDITAS
rem %1 = mi utan - a gep ujrainditasa, ha kerik
echo.
%UI% :VALASZT IN "Újraindítsam most a gépet?"
if errorlevel 2 (
    echo.
    echo   !C_SARGA!Rendben – ne felejtsd el később újraindítani.!C_0!
    call :VISSZA
    goto :eof
)
>>"%LOG%" echo [%date% %time%] újraindítás: %~1
shutdown /r /t 5 /c "Eszközcsere segédlet: újraindítás – %~1"
echo.
echo   !C_ZOLD!A gép 5 másodperc múlva újraindul.!C_0!
timeout /t 10 >nul
goto :eof

:VISSZA
echo.
echo   Visszalépéshez nyomj meg egy billentyűt...
rem Automatikus futtatasnal pontosan egy sort olvasunk - a pause tobb valaszt is elnyelne
if "%VALASZ_SORBOL%"=="1" (set /p "_x=") else (pause >nul)
goto :eof
