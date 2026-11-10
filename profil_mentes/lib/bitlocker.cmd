@call %*
@exit /b

rem ==========================================================
rem  BitLocker: a titkositas inditasa az MBAM klienssel
rem  Hivas: %BITLOCKER% :INDIT
rem ==========================================================

:INDIT
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
