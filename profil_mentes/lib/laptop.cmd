@call %*
@exit /b

rem ==========================================================
rem  Laptop beallitasa: fedel lehajtasa es BitLocker / MBAM
rem  Hivas: %LAPTOP% :FEDEL  vagy  %LAPTOP% :BITLOCKER
rem ==========================================================

:FEDEL
rem Fedel lehajtasakor vegzett muvelet = 0, vagyis Nincs muvelet.
rem Halozati - AC - es akkumulatoros - DC - uzemre is, az aktiv energiasemaban.
set "F_HIBA=0"
set "FEDEL_OK=0"
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0 >>"%LOG%" 2>&1
if errorlevel 1 set "F_HIBA=1"
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0 >>"%LOG%" 2>&1
if errorlevel 1 set "F_HIBA=1"
powercfg /setactive SCHEME_CURRENT >>"%LOG%" 2>&1

rem Ellenorzes: visszaolvassuk az aktiv semabol
set "F_AC="
set "F_DC="
for /f "tokens=2 delims=:" %%v in ('powercfg /query SCHEME_CURRENT SUB_BUTTONS LIDACTION 2^>nul ^| findstr /c:"0x"') do (
    if not defined F_AC (set "F_AC=%%v") else (set "F_DC=%%v")
)
if defined F_AC set "F_AC=!F_AC: =!"
if defined F_DC set "F_DC=!F_DC: =!"
>>"%LOG%" echo        Visszaolvasva: hálózat=!F_AC! akkumulátor=!F_DC!

rem Csoporthazirend: ha a ceg szabalyozza, az felulirja a helyi beallitast
set "F_POL="
set "F_PAC="
set "F_PDC="
set "F_KULCS=HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\5ca83367-6e45-459f-a27b-476b1d01c936"
reg query "%F_KULCS%" >nul 2>&1 && set "F_POL=1"
if defined F_POL (
    for /f "tokens=3" %%v in ('reg query "%F_KULCS%" /v ACSettingIndex 2^>nul ^| find "REG_"') do set "F_PAC=%%v"
    for /f "tokens=3" %%v in ('reg query "%F_KULCS%" /v DCSettingIndex 2^>nul ^| find "REG_"') do set "F_PDC=%%v"
)
set "F_POL_ROSSZ=0"
if defined F_PAC if not "!F_PAC!"=="0x0" set "F_POL_ROSSZ=1"
if defined F_PDC if not "!F_PDC!"=="0x0" set "F_POL_ROSSZ=1"

if not defined F_AC (
    %UI% :JELOL HIBA "a beállítás nem olvasható vissza" "Van fedele ennek a gépnek?"
    goto :eof
)
if "%F_POL_ROSSZ%"=="1" (
    %UI% :JELOL HIBA "csoportházirend felülírja" "hálózat=!F_PAC! akkumulátor=!F_PDC! – ezt csak az IT tudja módosítani."
    goto :eof
)
if "!F_AC!"=="0x00000000" if "!F_DC!"=="0x00000000" (
    set "FEDEL_OK=1"
    %UI% :JELOL OK "beállítva és ellenőrizve" "Hálózatról és akkumulátorról is: Nincs művelet."
    goto :eof
)
if "%F_HIBA%"=="1" (
    %UI% :JELOL HIBA "nem sikerült beállítani" "Nincs jogosultság – futtasd rendszergazdaként."
) else (
    %UI% :JELOL HIBA "a beállítás nem lett érvényes" "hálózat=!F_AC! akkumulátor=!F_DC!"
)
goto :eof

:BITLOCKER
rem MBAMAgent, 2 mp, MBAMClientUI, 2 mp, MBAMAgent ujra
if not exist "%MBAM_DIR%\MBAMAgent.exe" (
    %UI% :JELOL HIBA "MBAMAgent.exe nem található" "Telepítve van az MBAM kliens? Keresett hely: %MBAM_DIR%"
    goto :eof
)
if not exist "%MBAM_DIR%\MBAMClientUI.exe" (
    %UI% :JELOL HIBA "MBAMClientUI.exe nem található" "Telepítve van az MBAM kliens? Keresett hely: %MBAM_DIR%"
    goto :eof
)
>>"%LOG%" echo        MBAM mappa: %MBAM_DIR%

%UI% :RESZLET "1/3 MBAMAgent indítása..."
ver >nul
start "" "%MBAM_DIR%\MBAMAgent.exe"
if errorlevel 1 (
    %UI% :JELOL HIBA "az MBAMAgent nem indult el"
    goto :eof
)
timeout /t 2 /nobreak >nul

%UI% :RESZLET "2/3 MBAMClientUI indítása..."
ver >nul
start "" "%MBAM_DIR%\MBAMClientUI.exe"
if errorlevel 1 (
    %UI% :JELOL HIBA "az MBAMClientUI nem indult el"
    goto :eof
)
timeout /t 2 /nobreak >nul

%UI% :RESZLET "3/3 MBAMAgent újra..."
ver >nul
start "" "%MBAM_DIR%\MBAMAgent.exe"
if errorlevel 1 (
    %UI% :JELOL HIBA "az MBAMAgent másodszor nem indult el"
    goto :eof
)
%UI% :JELOL OK "elindítva" "Kövesd a megjelenő BitLocker ablakot."
goto :eof
