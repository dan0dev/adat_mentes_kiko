@call %*
@exit /b

rem ==========================================================
rem  Ellenorzesek: felhasznalo, kulso meghajto, futo programok,
rem  szabad hely
rem  Hivas: %ELLENORZES% :CIMKE parameterek
rem ==========================================================

:FELHASZNALO
rem Mentes, visszaallitas: a felhasznalo sajat profiljaval dolgozik. Kerdes nincs: a nev
rem az elokeszito kepernyon latszik, az "Indulhat?" ezt is jovahagyja.
rem Rendszergazdakent egy masik fiokkal: a profil, az AppData es a registry a rendszergazdae
rem lenne - igy a mentes es a visszaallitas rossz adatokkal dolgozna. Ilyenkor nem engedjuk.
rem Kilepesi kod: 0 = mehet, 1 = nem
if not "%ADMIN%"=="1" exit /b 0
set "BEJ="
set "PS_FAJL=%PSDIR%\bejelentkezett.ps1"
for /f "delims=" %%u in ('%PS_FUTTAT% 2^>nul') do set "BEJ=%%u"
if defined BEJ if /I not "!BEJ!"=="%USERNAME%" (
    echo.
    echo   !C_PIROS!A segédlet most egy másik, rendszergazdai fiókkal fut.!C_0!
    echo     Rendszergazdai fiók:  !C_FEHER!%USERNAME%!C_0!
    echo     Bejelentkezve:        !C_FEHER!!BEJ!!C_0!
    echo.
    echo   Így a rendszergazda adataival dolgozna – indítsd sima dupla kattintással.
    exit /b 1
)
exit /b 0

:MEGHAJTO
rem Kulso meghajto betujel bekerese.  Kimenet: DRIVE, IRHATO, ROOT
rem %1 = KELL: csak irhato meghajto fogadhato el - mentesnel
rem Alapertek a D - Enterre azt hasznalja, de mas betu is beirhato. Ha a rendszer a D-n van,
rem nincs alapertek.
set "M_ALAP="
if /I not "%SystemDrive%"=="D:" set "M_ALAP=D"
:MEGHAJTO_BEKER
echo.
%UI% :BEKER DRIVE "A külső meghajtó betűjele:" "%M_ALAP%"
if errorlevel 255 exit /b 1
if not defined DRIVE goto :MEGHAJTO_BEKER
rem Ellenorzes pipe nelkul: pontosan egy betu, utana legfeljebb : es \
set "_d=!DRIVE:"=!"
if "!_d:~-1!"=="\" set "_d=!_d:~0,-1!"
if "!_d:~-1!"==":" set "_d=!_d:~0,-1!"
set "_jo=1"
if not defined _d set "_jo=0"
if defined _d if not "!_d:~1!"=="" set "_jo=0"
if "!_jo!"=="1" for /f "tokens=1,* delims=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" %%x in ("1!_d!") do if not "%%x%%y"=="1" set "_jo=0"
if "!_jo!"=="0" (
    echo   !C_PIROS!Csak egy betűt adj meg, pl. E.!C_0!
    goto :MEGHAJTO_BEKER
)
set "DRIVE=!_d!"
if /I "%DRIVE%:"=="%SystemDrive%" (
    echo   !C_PIROS!A rendszermeghajtó nem lehet a külső meghajtó.!C_0!
    goto :MEGHAJTO_BEKER
)
if not exist "%DRIVE%:\" (
    echo   !C_PIROS!Nincs ilyen meghajtó: !DRIVE!: – csatlakoztatva van a külső meghajtó?!C_0!
    goto :MEGHAJTO_BEKER
)

rem Irhatosag teszt - csak a sajat tesztfajljat hozza letre es torli
set "IRHATO=1"
set "TESZT=%DRIVE%:\_irasteszt_%RANDOM%.tmp"
(echo teszt) >"%TESZT%" 2>nul
if exist "%TESZT%" (del /q "%TESZT%" >nul 2>&1) else (set "IRHATO=0")
if "%IRHATO%"=="0" if /I "%~1"=="KELL" (
    echo   !C_PIROS!A kiválasztott meghajtó nem írható: !DRIVE!:!C_0!
    echo   !C_PIROS!Kapcsold ki az írásvédelmet, vagy válassz másik meghajtót.!C_0!
    goto :MEGHAJTO_BEKER
)
set "ROOT=%DRIVE%:\%MAPPA_NEV%"
exit /b 0

:APPOK
rem A config\beallitasok.cmd FIGYELT_PROGRAMOK listajabol a meg futok bezarasa.  Kimenet: FUTO
rem Elobb normal bezaras - a program rakerdezhet a mentesre -, ha az nem eleg, kenyszerites.
set "APP_PROBALT=0"
:APPOK_UJRA
set "FUTO="
for %%p in (%FIGYELT_PROGRAMOK%) do (
    tasklist /FI "IMAGENAME eq %%p" 2>nul | find /I "%%p" >nul && set "FUTO=!FUTO! %%p"
)
if not defined FUTO (
    if "%APP_PROBALT%"=="1" echo   !C_ZOLD!Minden figyelt program bezárva.!C_0!
    goto :eof
)
echo.
echo   !C_SARGA!Még fut:!FUTO!!C_0!
echo   A nyitott programok zárolhatják a fájlokat. Az Edge és a Sticky Notes
echo   a háttérben is futhat.
if "%APP_PROBALT%"=="1" goto :APPOK_KENYSZER
echo   U – újraellenőrzés    B – bezárás    F – folytatás így
%UI% :VALASZT UBF "Válassz:"
if errorlevel 3 goto :eof
if errorlevel 2 goto :APPOK_BEZAR
goto :APPOK_UJRA

:APPOK_BEZAR
echo   Bezárás… Ha az Outlook, a Word vagy az Excel kérdez, válaszolj.
set "_kb= %KENYSZER_BEZARAS% "
for %%p in (!FUTO!) do (
    if not "!_kb: %%p =!"=="!_kb!" (
        taskkill /F /IM %%p >nul 2>&1
    ) else (
        taskkill /IM %%p >nul 2>&1
    )
)
set "APP_PROBALT=1"
timeout /t 3 /nobreak >nul
goto :APPOK_UJRA

:APPOK_KENYSZER
echo   Nem zárult be mind. Ha valamelyik kérdez, például
echo   mentést, válaszolj, majd U.
echo   !C_SARGA!Kényszerített bezárásnál a nem mentett munka elvész. Az Outlookot csak!C_0!
echo   !C_SARGA!végső esetben zárd be így.!C_0!
echo   U – újraellenőrzés    K – kényszerített bezárás    F – folytatás így
%UI% :VALASZT UKF "Válassz:"
if errorlevel 3 goto :eof
if errorlevel 2 (
    for %%p in (!FUTO!) do taskkill /F /IM %%p >nul 2>&1
    timeout /t 2 /nobreak >nul
)
goto :APPOK_UJRA

:HELY
rem Bemenet: PS_FORRASOK, PS_BETU.  Kimenet: HELY_STOP
set "HELY_STOP=0"
set "H_KELL="
set "H_SZABAD="
set "H_FS="
set "H_MAX="
set "H_KDB="
set "H_KMERET="
set "PS_FAJL=%PSDIR%\hely.ps1"
for /f "tokens=1-5*" %%a in ('%PS_FUTTAT% 2^>nul') do (
    set "H_KELL=%%a"
    set "H_SZABAD=%%b"
    set "H_FS=%%c"
    set "H_MAX=%%d"
    set "H_KDB=%%e"
    set "H_KMERET=%%f"
)
if not defined H_MAX (
    echo   !C_SARGA!A helyellenőrzés nem futott le, folytatom nélküle.!C_0!
    goto :eof
)
set /a H_KELL+=RAHAGYAS_MB
%UI% :MB_GB H_KELL H_KELL_TXT
%UI% :MB_GB H_SZABAD H_SZABAD_TXT
echo   Szükséges kb. !H_KELL_TXT!    Szabad: !H_SZABAD_TXT!    Fájlrendszer: !H_FS!
rem Az atugorhato tetel (C:\TEMP): mekkora - masolas kozben a K billentyuvel kihagyhato
if defined K_NEV if defined H_KDB if not "!H_KDB!"=="-" if not "!H_KDB!"=="0" (
    echo   !K_NEV!: !H_KDB! fájl, !H_KMERET! – másolás közben K-val átugorható.
)
if !H_KELL! GTR !H_SZABAD! (
    echo.
    echo   !C_PIROS!Nincs elég hely ezen a meghajtón: !PS_BETU!!C_0!
    echo   M – megszakítás    F – folytatás így
    %UI% :VALASZT MF "Válassz:"
    if errorlevel 2 goto :eof
    set "HELY_STOP=1"
    goto :eof
)
if /I "!H_FS!"=="FAT32" if !H_MAX! GEQ 4096 (
    echo.
    echo   !C_PIROS!Van 4 GB-nál nagyobb fájl – FAT32-re nem másolható.!C_0!
    echo   Formázd exFAT-ra vagy NTFS-re, vagy válassz másik meghajtót.
    echo   M – megszakítás    F – folytatás így
    %UI% :VALASZT MF "Válassz:"
    if errorlevel 2 goto :eof
    set "HELY_STOP=1"
    goto :eof
)
echo   !C_ZOLD!Hely rendben.!C_0!
goto :eof
