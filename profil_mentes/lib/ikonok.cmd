@call %*
@exit /b

rem ==========================================================
rem  Office parancsikonok ellenorzese es javitasa az asztalon
rem  A programok listaja: config\parancsikonok.cmd
rem  Fajlt csak a hibas - nem letezo celra mutato - parancsikonoknal torol.
rem  Hivas: %IKONOK% :JAVIT
rem ==========================================================

:JAVIT
if not exist "%DESK%\" (
    %UI% :JELOL HIBA "az asztal mappája nem található" "%DESK%"
    goto :eof
)
if not exist "%PD_START%\" (
    %UI% :JELOL HIBA "a Start menü mappája nem található" "%PD_START%"
    goto :eof
)
set /a IK_HIBA=0, IK_TELEPITVE=0
set "IK_UZ="
>>"%LOG%" echo        Asztal: %DESK%

set IKON_APP=call "%LIB%\ikonok.cmd" :APP
call "%CONF%\parancsikonok.cmd"

if %IK_TELEPITVE%==0 (
    %UI% :JELOL KIHAGYVA "egyik program sincs telepítve"
    goto :eof
)
if %IK_HIBA% GTR 0 (
    %UI% :JELOL HIBA "nem minden parancsikon rendben" "!IK_UZ!"
) else (
    %UI% :JELOL OK "%IK_TELEPITVE% program ellenőrizve" "!IK_UZ!"
)
goto :eof

:APP
rem Egy sor a config\parancsikonok.cmd-bol
rem %1 = program neve, %2 = vart exe neve, utana a parancsikon nevek
set "IK_NEV=%~1"
set "IK_EXE_VART=%~2"
set "IK_MINTA="
:APP_MINTAK
shift
if "%~2"=="" goto :APP_MINTAK_KESZ
set "IK_MINTA=!IK_MINTA! "%~2""
goto :APP_MINTAK
:APP_MINTAK_KESZ
set "IK_S="
for %%m in (%IK_MINTA%) do if not defined IK_S for /f "delims=" %%f in ('dir /b /s /a-d "%PD_START%\%%~m" 2^>nul') do if not defined IK_S set "IK_S=%%f"
if not defined IK_S (
    %UI% :RESZLET "%IK_NEV%: nincs a Start menüben, kihagyva"
    call :IK_UZ_ADD "%IK_NEV% nincs telepítve"
    goto :eof
)
set /a IK_TELEPITVE+=1
for %%x in ("!IK_S!") do set "IK_SNEV=%%~nxx"
>>"%LOG%" echo        %IK_NEV% forrás: !IK_S!
set "IK_OK=0"
set "IK_JAV=0"
call :IKON_DIR "%DESK%"
call :IKON_DIR "%PUBLIC%\Desktop"
if "!IK_OK!"=="1" (
    if "!IK_JAV!"=="1" (call :IK_UZ_ADD "%IK_NEV% javítva") else (call :IK_UZ_ADD "%IK_NEV% rendben")
    goto :eof
)
if exist "%DESK%\!IK_SNEV!" (
    echo            !C_SARGA!%IK_NEV%: az asztalon már van más célú !IK_SNEV!, meghagyom – ellenőrizd kézzel!C_0!
    call :IK_UZ_ADD "%IK_NEV% ellenőrizendő"
    goto :eof
)
copy /Y "!IK_S!" "%DESK%\" >nul 2>&1
if exist "%DESK%\!IK_SNEV!" (
    echo            !C_ZOLD!%IK_NEV%: parancsikon kirakva az asztalra!C_0!
    >>"%LOG%" echo        %IK_NEV% kirakva: %DESK%\!IK_SNEV!
    call :IK_UZ_ADD "%IK_NEV% kirakva"
) else (
    echo            !C_PIROS!%IK_NEV%: nem sikerült kirakni az asztalra!C_0!
    set /a IK_HIBA+=1
    call :IK_UZ_ADD "%IK_NEV% HIBA"
)
goto :eof

:IKON_DIR
rem %1 = asztal mappa.  A mintaknak megfelelo parancsikonokat vizsgalja.
if not exist "%~1\" goto :eof
pushd "%~1" 2>nul || goto :eof
for %%f in (%IK_MINTA%) do if exist "%%~ff" call :IKON_FAJL "%%~ff"
popd
goto :eof

:IKON_FAJL
rem %1 = vizsgalt parancsikon
set "IK_F=%~1"
set "IK_FNEV=%~nx1"
rem 1. Ha megegyezik a Start menus parancsikonnal, biztosan jo
fc /b "!IK_F!" "!IK_S!" >nul 2>&1
if not errorlevel 1 (
    set "IK_OK=1"
    %UI% :RESZLET "!IK_NEV!: !IK_FNEV! rendben"
    goto :eof
)
rem 2. Kulonben kiolvassuk, hova mutat
set "IK_LNK=!IK_F!"
set "IK_CEL="
for /f "delims=" %%t in ('powershell -NoProfile -NonInteractive -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; (New-Object -ComObject WScript.Shell).CreateShortcut($env:IK_LNK).TargetPath" 2^>nul') do set "IK_CEL=%%t"
if not defined IK_CEL (
    %UI% :RESZLET "!IK_NEV!: !IK_FNEV! célja nem olvasható, meghagyom"
    goto :eof
)
rem 3. Ha a cel nem letezik, hibas - toroljuk
if not exist "!IK_CEL!" (
    >>"%LOG%" echo        Hibás parancsikon: !IK_F! -^> !IK_CEL!
    del /q "!IK_F!" >nul 2>&1
    if exist "!IK_F!" (
        echo            !C_PIROS!!IK_NEV!: !IK_FNEV! hibás, de nem törölhető – nincs jogosultság!C_0!
        set /a IK_HIBA+=1
    ) else (
        %UI% :RESZLET "!IK_NEV!: !IK_FNEV! hibás elérési út, törölve"
        set "IK_JAV=1"
    )
    goto :eof
)
rem 4. Letezo cel: jo, ha a vart programra mutat, vagy MSI-s Office eseten
rem    a Windows\Installer ala. Kulonben nem nyulunk hozza.
for %%x in ("!IK_CEL!") do set "IK_CELNEV=%%~nxx"
set "IK_JO=0"
if /I "!IK_CELNEV!"=="!IK_EXE_VART!" set "IK_JO=1"
set "_t=!IK_CEL:%WIN_INST%=!"
if not "!_t!"=="!IK_CEL!" set "IK_JO=1"
if "!IK_JO!"=="1" (
    set "IK_OK=1"
    %UI% :RESZLET "!IK_NEV!: !IK_FNEV! rendben"
) else (
    %UI% :RESZLET "!IK_NEV!: !IK_FNEV! más programra mutat, meghagyom"
)
goto :eof

:IK_UZ_ADD
if defined IK_UZ (set "IK_UZ=!IK_UZ!, %~1") else (set "IK_UZ=%~1")
goto :eof
