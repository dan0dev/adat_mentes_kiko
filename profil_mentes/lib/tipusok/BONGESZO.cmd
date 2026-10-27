@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: BONGESZO - Chromium alapu bongeszo profiljai
rem  T_FORRAS = a bongeszo User Data mappaja
rem  T_P1 = bongeszo neve, T_P2 = a mentendo fajlok listajat tartalmazo valtozo
rem  A Local State nem kerul at, mert abban van a gephez kotott
rem  titkositokulcs - csak a profillista, a ps\profillista_*.ps1 segitsegevel.
rem ==========================================================

:MENT
set "B_FAJLOK=!%T_P2%!"
if not exist "%T_FORRAS%\" (
    %UI% :JELOL KIHAGYVA "a böngésző nincs ezen a gépen"
    goto :eof
)
set /a B_DB=0, B_HIBA=0
set "B_NEVEK="
for /d %%P in ("%T_FORRAS%\Default" "%T_FORRAS%\Profile *") do (
    if exist "%%~fP\Preferences" (
        set /a B_DB+=1
        if defined B_NEVEK (set "B_NEVEK=!B_NEVEK!, %%~nxP") else (set "B_NEVEK=%%~nxP")
        set "R_SRC=%%~fP"
        set "R_DST=%CEL%\%T_MAPPA%\%%~nxP"
        set "R_OPT=!B_FAJLOK!"
        set "R_PROG=0"
        %MASOLAS% :ROBO
        if not "!R_ALLAPOT!"=="OK" (
            set /a B_HIBA+=1
            echo            !C_PIROS!%%~nxP: !R_UZENET!!C_0!
        )
    )
)
if %B_DB%==0 (
    %UI% :JELOL KIHAGYVA "nincs böngészőprofil"
    goto :eof
)
%UI% :RESZLET "!B_NEVEK!"
if exist "%T_FORRAS%\Local State" call :PROFILLISTA_MENT "%T_FORRAS%\Local State" "%CEL%\%T_MAPPA%\profilok.json"
if %B_HIBA% GTR 0 (
    %UI% :JELOL HIBA "%B_HIBA% profil hibával"
) else (
    %UI% :JELOL OK "%B_DB% profil, ellenőrizve"
)
goto :eof

:VISSZA
set "B_FAJLOK=!%T_P2%!"
set "B_MENTES=%FORRAS%\%T_MAPPA%"
if not exist "%B_MENTES%\" (
    %UI% :JELOL KIHAGYVA "nincs a mentésben"
    goto :eof
)
set "VOLT_LS=0"
if exist "%T_FORRAS%\Local State" set "VOLT_LS=1"
set /a B_DB=0, B_HIBA=0
set "B_NEVEK="
for /d %%P in ("%B_MENTES%\*") do (
    set /a B_DB+=1
    if defined B_NEVEK (set "B_NEVEK=!B_NEVEK!, %%~nxP") else (set "B_NEVEK=%%~nxP")
    set "R_SRC=%%~fP"
    set "R_DST=%T_FORRAS%\%%~nxP"
    set "R_OPT=!B_FAJLOK!"
    set "R_PROG=0"
    %MASOLAS% :ROBO
    if not "!R_ALLAPOT!"=="OK" (
        set /a B_HIBA+=1
        echo            !C_PIROS!%%~nxP: !R_UZENET!!C_0!
    )
)
if %B_DB%==0 (
    %UI% :JELOL KIHAGYVA "a mentés üres"
    goto :eof
)
%UI% :RESZLET "!B_NEVEK!"
call :PROFILLISTA_VISSZA "%B_MENTES%" "%T_FORRAS%" "%T_P1%"
if %B_HIBA% GTR 0 (
    %UI% :JELOL HIBA "%B_HIBA% profil hibával"
) else (
    %UI% :JELOL OK "%B_DB% profil, ellenőrizve"
)
goto :eof

:PROFILLISTA_MENT
rem Csak a profillista kerul ki a Local State-bol, a titkositokulcs nem
rem %1 = Local State, %2 = kimeneti json
set "LS_SRC=%~1"
set "LS_DST=%~2"
if "%TESZTMOD%"=="1" set "LS_DST=%TEMP%\_teszt_profilok_%RANDOM%.json"
if "%TESZTMOD%"=="0" if not exist "%~dp2" mkdir "%~dp2" 2>nul
set "PS_FAJL=%PSDIR%\profillista_ment.ps1"
%PS_FUTTAT% >nul 2>&1
if errorlevel 1 (
    echo            !C_SARGA!a profillista nem menthető – a Default profil így is visszaáll!C_0!
) else (
    %UI% :RESZLET "profillista mentve, titkosítókulcs nélkül"
)
if "%TESZTMOD%"=="1" del /q "%LS_DST%" >nul 2>&1
goto :eof

:PROFILLISTA_VISSZA
rem Uj Local State csak a profillistaval - a bongeszo sajat, uj kulcsot general
rem %1 = mentes mappa, %2 = User Data cel, %3 = bongeszo neve
if not exist "%~1\profilok.json" goto :eof
if not exist "%~1\Profile *" goto :eof
if "%VOLT_LS%"=="1" (
    echo            !C_SARGA!%~3 ezen a gépen már futott. A többi profil megjelenítéséhez!C_0!
    echo            !C_SARGA!új profillistát írok – az itt eddig mentett böngészőjelszavak!C_0!
    echo            !C_SARGA!és sütik elveszhetnek. A régit Local State.regi néven megtartom.!C_0!
    %UI% :VALASZT IN "Átírjam a profillistát?"
    if errorlevel 2 goto :eof
    copy /Y "%~2\Local State" "%~2\Local State.regi" >nul
)
if not exist "%~2\" mkdir "%~2" 2>nul
set "LS_JSON=%~1\profilok.json"
set "LS_DST=%~2\Local State"
set "PS_FAJL=%PSDIR%\profillista_vissza.ps1"
%PS_FUTTAT% >nul 2>&1
if errorlevel 1 (
    set /a B_HIBA+=1
    echo            !C_PIROS!a profillista nem írható – a többi profilt kézzel kell hozzáadni!C_0!
) else (
    %UI% :RESZLET "profillista visszaállítva, titkosítókulcs nélkül"
)
goto :eof
