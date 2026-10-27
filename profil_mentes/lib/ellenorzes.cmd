@call %*
@exit /b

rem ==========================================================
rem  Ellenorzesek: felhasznalo, kulso meghajto, futo programok,
rem  szabad hely, es a teszt mod kornyezete
rem  Hivas: %ELLENORZES% :CIMKE parameterek
rem ==========================================================

:FELHASZNALO
rem Mentes, exportalas, teszt: a felhasznalo sajat profiljaval dolgozik
rem Kilepesi kod: 0 = jo felhasznalo, 1 = megszakitas
echo.
if "%ADMIN%"=="1" (
    echo    !C_SARGA!Figyelem: a script rendszergazdakent fut.!C_0!
    echo    !C_SARGA!A mentes es az exportalas annak a fioknak az adataival dolgozik, amelyik futtatja.!C_0!
    echo.
)
echo    Felhasznalo, akinek az adataival dolgozom: !C_FEHER!%USERNAME%!C_0!
%UI% :VALASZT IN "   Ez a helyes felhasznalo"
if not errorlevel 2 exit /b 0
echo.
echo    Inditsd el a scriptet a felhasznalo sajat fiokjaban, rendszergazdai jog nelkul:
echo    sima dupla kattintassal, ne Futtatas rendszergazdakent.
exit /b 1

:MEGHAJTO
rem Kulso meghajto betujel bekerese.  Kimenet: DRIVE, IRHATO, ROOT
rem %1 = KELL: csak irhato meghajto fogadhato el, JELEZ: nem irhatonal csak figyelmeztet
:MEGHAJTO_BEKER
set "DRIVE="
echo.
set /p "DRIVE=   Kulso meghajto betujele, pl. E: "
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
    echo    !C_PIROS!Csak egy betut adj meg, pl. E!C_0!
    goto :MEGHAJTO_BEKER
)
set "DRIVE=!_d!"
if /I "%DRIVE%:"=="%SystemDrive%" (
    echo    !C_PIROS!A rendszermeghajto nem lehet a celmeghajto.!C_0!
    goto :MEGHAJTO_BEKER
)
if not exist "%DRIVE%:\" (
    echo    !C_PIROS!Nem talalhato meghajto: !DRIVE!: - csatlakoztatva van a kulso meghajto?!C_0!
    goto :MEGHAJTO_BEKER
)

rem Irhatosag teszt - csak a sajat tesztfajljat hozza letre es torli
set "IRHATO=1"
set "TESZT=%DRIVE%:\_irasteszt_%RANDOM%.tmp"
(echo teszt) >"%TESZT%" 2>nul
if exist "%TESZT%" (del /q "%TESZT%" >nul 2>&1) else (set "IRHATO=0")
if "%IRHATO%"=="0" if /I "%~1"=="JELEZ" echo    !C_PIROS!A %DRIVE%: meghajto nem irhato - a teszt ezt hibakent jelzi.!C_0!
if "%IRHATO%"=="0" if /I "%~1"=="KELL" (
    echo    !C_PIROS!A !DRIVE!: meghajto nem irhato - irasvedett vagy nincs jogosultsag.!C_0!
    goto :MEGHAJTO_BEKER
)
set "ROOT=%DRIVE%:\%MAPPA_NEV%"
goto :eof

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
    if "%APP_PROBALT%"=="1" echo    !C_ZOLD!Minden figyelt program bezarva.!C_0!
    goto :eof
)
echo.
if "%TESZTMOD%"=="1" (
    echo    !C_SARGA!Meg futnak:!FUTO! - eles mentes elott ezeket be kell zarni.!C_0!
) else (
    echo    !C_SARGA!Meg futnak:!FUTO!!C_0!
    echo    A nyitott programok zarolhatjak a fajlokat. Az Edge es a Sticky Notes a hatterben is futhat.
)
if "%APP_PROBALT%"=="1" goto :APPOK_KENYSZER
%UI% :VALASZT UBF "   U = ujra ellenoriz, B = bezarom oket, F = folytatas igy is"
if errorlevel 3 goto :eof
if errorlevel 2 goto :APPOK_BEZAR
goto :APPOK_UJRA

:APPOK_BEZAR
echo    Bezaras... az Outlook, Word es Excel normalisan zar be, ha mentest kernek, valaszolj.
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
echo    Normal bezaras utan is futnak. Ha a program kerdez valamit, pl. mentest, valaszolj, utana U.
echo    !C_SARGA!Kenyszeritesnel a nem mentett munka elveszik. Az Outlookot csak vegso esetben.!C_0!
%UI% :VALASZT UKF "   U = ujra ellenoriz, K = kenyszeritve bezarom, F = folytatas igy is"
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
set "PS_FAJL=%PSDIR%\hely.ps1"
for /f "tokens=1-4" %%a in ('%PS_FUTTAT% 2^>nul') do (
    set "H_KELL=%%a"
    set "H_SZABAD=%%b"
    set "H_FS=%%c"
    set "H_MAX=%%d"
)
if not defined H_MAX (
    echo    !C_SARGA![i] A helyellenorzes nem futott le, folytatom nelkule.!C_0!
    goto :eof
)
set /a H_KELL+=RAHAGYAS_MB
%UI% :MB_GB H_KELL H_KELL_TXT
%UI% :MB_GB H_SZABAD H_SZABAD_TXT
echo    Szukseges kb.: !H_KELL_TXT!    Szabad: !H_SZABAD_TXT!    Fajlrendszer: !H_FS!
if !H_KELL! GTR !H_SZABAD! (
    echo.
    echo    !C_PIROS![HIBA] Nincs eleg hely a celmeghajton.!C_0!
    if "%TESZTMOD%"=="1" (
        set "T_HELY=nincs eleg hely a kulso meghajton"
        goto :eof
    )
    %UI% :VALASZT MF "   M = megszakitas, F = folytatas igy is"
    if errorlevel 2 goto :eof
    set "HELY_STOP=1"
    goto :eof
)
if /I "!H_FS!"=="FAT32" if !H_MAX! GEQ 4096 (
    echo.
    echo    !C_PIROS![HIBA] Van 4 GB-nal nagyobb fajl, ez nem fer el FAT32 fajlrendszeru meghajton.!C_0!
    echo    Formazd a kulso meghajtot exFAT vagy NTFS fajlrendszerre, vagy hasznalj masikat.
    if "%TESZTMOD%"=="1" (
        set "T_HELY=4 GB-nal nagyobb fajl FAT32 meghajton"
        goto :eof
    )
    %UI% :VALASZT MF "   M = megszakitas, F = folytatas igy is"
    if errorlevel 2 goto :eof
    set "HELY_STOP=1"
    goto :eof
)
echo    !C_ZOLD!Hely rendben.!C_0!
goto :eof

:KORNYEZET
rem Csak a teszt modban: a futtatashoz szukseges eszkozok ellenorzese
set "K_HIBA="
set "K_OK="
where robocopy >nul 2>&1
if errorlevel 1 (set "K_HIBA=!K_HIBA! robocopy hianyzik;") else (set "K_OK=!K_OK! robocopy,")
powershell -NoProfile -NonInteractive -Command "exit 0" >nul 2>&1
if errorlevel 1 (set "K_HIBA=!K_HIBA! PowerShell tiltva - listak es ellenorzesek kimaradnak;") else (set "K_OK=!K_OK! PowerShell,")
if "%IRHATO%"=="0" (set "K_HIBA=!K_HIBA! a kulso meghajto nem irhato;") else (set "K_OK=!K_OK! irhato celmeghajto,")
if defined T_HELY (set "K_HIBA=!K_HIBA! !T_HELY!;") else (set "K_OK=!K_OK! hely rendben")
if "%ADMIN%"=="1" echo        !C_SARGA!- rendszergazdakent fut: biztos, hogy ez a felhasznalo profilja?!C_0!
if defined K_HIBA (
    %UI% :JELOL HIBA "!K_HIBA!"
) else (
    %UI% :JELOL OK "!K_OK!"
)
goto :eof
