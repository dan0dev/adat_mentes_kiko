rem ==========================================================
rem  6. A segedlet frissitese a GitHubrol, a legutolso kiadasbol (GitHub Release)
rem  A repo: config\beallitasok.cmd - FR_REPO. Kiadast a kiadas.ps1 keszit.
rem  A munka: lib\frissites.cmd, ps\frissites.ps1, ps\frissites_csere.ps1
rem  Kilepesi kod: 4 = rovid zaras, utana kilep (a csere a bezaras utan jon); 1 = nem kertek;
rem                2 = nem indult el (az ok fent); 5 = nincs teendo
rem ==========================================================

cls
%UI% :CIM "Segédlet frissítése"
echo   A legújabb verzió a GitHubról – internet kell; a mentésekhez nem nyúl.
echo.

rem A fejlesztoi peldanyt - git-mappa - nem irjuk felul: ott a git-tel kell frissiteni
if exist "%APP%\..\.git\" (
    echo   !C_SARGA!Ez a fejlesztői példány, git-mappában – itt a git-tel frissíts.!C_0!
    goto :NEM_INDULT
)
rem A segedlet mappaja irhato-e - pl. halozati megosztason lehet csak olvashato
set "_ft=%APP%\_irasteszt_%RANDOM%.tmp"
(echo teszt) >"%_ft%" 2>nul
if not exist "%_ft%" (
    echo   !C_PIROS!A segédlet mappája nem írható: !APP!!C_0!
    echo   !C_PIROS!Másold a segédletet egy írható helyre, és onnan frissíts.!C_0!
    goto :NEM_INDULT
)
del /q "%_ft%" >nul 2>&1

set "LOG=%TEMP%\frissites_naplo.txt"
>>"%LOG%" echo ===== FRISSÍTÉS %date% %time% – %USERNAME% / %COMPUTERNAME% =====
echo   Lekérdezés a GitHubról…
%FRISSITES% :ELLENORIZ
echo.
if "%FR_ALLAPOT%"=="HIBA" (
    echo   !C_PIROS!!FR_UJ_LEIRAS!!C_0!
    goto :NEM_INDULT
)
%UI% :ADAT "Ez a változat" "%VERZIO%"
%UI% :ADAT "Legújabb" "!FR_UJ_VERZIO! · !FR_UJ_DATUM!"
if defined FR_UJ_LEIRAS %UI% :ADAT "Újdonság" "!FR_UJ_LEIRAS!"
echo.
if "%FR_ALLAPOT%"=="AZONOS" (
    set "NINCS_TEENDO=Ez már a legújabb verzió."
    exit /b 5
)
%UI% :VALASZT IN "Frissítsem az új verzióra?"
if errorlevel 2 goto :MEGSZAKITVA
set /a OSSZES=2

%UI% :IDO START_MP
%UI% :FEJLEC "Letöltés"
%FRISSITES% :LETOLT
%UI% :FEJLEC "Csere előkészítése"
if "%FR_LETOLTVE%"=="1" (
    %FRISSITES% :INDIT
) else (
    %UI% :JELOL KIHAGYVA "a letöltés nem sikerült"
)
rem Sikeres elokeszites utan a segedlet bezarul - a csere csak utana johet
if "%FR_LETOLTVE%"=="1" if %DB_HIBA%==0 (
    set "MOD_KILEP=1"
    set "ROVID_SZOVEG=A frissítéshez nyomj meg egy billentyűt – bezárul, frissül és újraindul."
)
exit /b 4

:MEGSZAKITVA
exit /b 1

:NEM_INDULT
exit /b 2
