rem ==========================================================
rem  5. A segedlet frissitese a GitHubrol
rem  A repo es az ag: config\beallitasok.cmd - FR_REPO, FR_AG
rem  A munka: lib\frissites.cmd, ps\frissites.ps1, ps\frissites_csere.ps1
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva; 2 = nincs teendo
rem ==========================================================

cls
%UI% :CIM "Segédlet frissítése"
echo   A segédlet legújabb változata a GitHubról – internet kell hozzá.
echo   A program fájljai cserélődnek, a mentésekhez nem nyúl.
echo.

rem A fejlesztoi peldanyt - git-mappa - nem irjuk felul: ott a git-tel kell frissiteni
if exist "%APP%\..\.git\" (
    echo   !C_SARGA!Ez a fejlesztői példány, git-mappában – itt a git-tel frissíts.!C_0!
    goto :MEGSZAKITVA
)
rem A segedlet mappaja irhato-e - pl. halozati megosztason lehet csak olvashato
set "_ft=%APP%\_irasteszt_%RANDOM%.tmp"
(echo teszt) >"%_ft%" 2>nul
if not exist "%_ft%" (
    echo   !C_PIROS!A segédlet mappája nem írható: !APP!!C_0!
    echo   !C_PIROS!Másold a segédletet egy írható helyre, és onnan frissíts.!C_0!
    goto :MEGSZAKITVA
)
del /q "%_ft%" >nul 2>&1

set "LOG=%TEMP%\frissites_naplo.txt"
>>"%LOG%" echo ===== FRISSÍTÉS %date% %time% – %USERNAME% / %COMPUTERNAME% =====
echo   Lekérdezés a GitHubról...
%FRISSITES% :ELLENORIZ
echo.
if "%FR_ALLAPOT%"=="HIBA" (
    echo   !C_PIROS!!FR_UJ_UZENET!!C_0!
    goto :MEGSZAKITVA
)
if defined FR_HELYI (%UI% :ADAT "Ez a változat" "!FR_HELYI:~0,7!") else (%UI% :ADAT "Ez a változat" "ismeretlen – még nem frissült innen")
%UI% :ADAT "Legújabb" "!FR_UJ_SHA:~0,7! · !FR_UJ_DATUM!"
%UI% :ADAT "Utolsó változás" "!FR_UJ_UZENET!"
echo.
if "%FR_ALLAPOT%"=="AZONOS" (
    set "NINCS_TEENDO=Ez már a legújabb változat."
    exit /b 2
)
%UI% :VALASZT IN "Frissítsem?"
if errorlevel 2 goto :MEGSZAKITVA
set /a OSSZES=2

%UI% :IDO START_MP
cls
%UI% :CIM "Segédlet frissítése folyamatban"
%UI% :FEJLEC "Letöltés"
%FRISSITES% :LETOLT
%UI% :FEJLEC "Csere előkészítése"
if "%FR_LETOLTVE%"=="1" (
    %FRISSITES% :INDIT
) else (
    %UI% :JELOL KIHAGYVA "a letöltés nem sikerült"
)
exit /b 0

:MEGSZAKITVA
exit /b 1
