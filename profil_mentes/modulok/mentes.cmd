rem ==========================================================
rem  1. Adatok mentese (a regi gepen)
rem
rem  A mentendo tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = a felhasznalo nem kerte; 2 = nem indult el
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :NEM_INDULT
%ELLENORZES% :MEGHAJTO KELL
if errorlevel 1 goto :MEGSZAKITVA

%TETELEK% :BETOLT
rem Lepesek: a tetelek, a programlista, a talca, az Outlook-lista, a nyomtatok es meghajtok
set /a OSSZES=T_DB+4
set "CEL=%ROOT%\%USERNAME%_%COMPUTERNAME%"

rem ---------- Elokeszites ----------
cls
%UI% :CIM "Adatok mentése – előkészítés"
%UI% :ADAT "Felhasználó" "%USERNAME%" SARGA
%UI% :ADAT "Mentés helye" "%CEL%"
echo.
echo   Mentendő tételek:
%TETELEK% :LISTA "Programlista" "Tálcaikonok listája" "Outlook-lista" "Nyomtatók, meghajtók"
echo.
echo   !C_SARGA!A tanúsítványokat és a PST-ket kézzel vidd át.!C_0!
if exist "%CEL%\" (
    echo.
    echo   !C_SARGA!Erről a gépről már van mentés – frissítem, nem törlök belőle.!C_0!
)

rem A profil mappainak elerhetonek kell lenniuk: ha pl. az atiranyitott AppData megosztasa
rem nem erheto el, a tetelek "nincs ilyen mappa" miatt kimaradnanak, es a mentes hianyos lenne
set "PROFIL_HIANY="
for %%p in ("%USERPROFILE%" "%APPDATA%" "%LOCALAPPDATA%") do if not exist "%%~p\" set "PROFIL_HIANY=%%~p"
if defined PROFIL_HIANY (
    echo.
    echo   !C_PIROS!A profil egy része most nem érhető el – a mentés hiányos lenne:!C_0!
    echo   !C_PIROS!!PROFIL_HIANY!!C_0!
    goto :NEM_INDULT
)

%OUTLOOK% :LISTA_KESZIT
if "%OL_STOP%"=="1" goto :MEGSZAKITVA

echo.
echo   Helyellenőrzés, egy pillanat…
%TETELEK% :FORRASOK
set "PS_BETU=%DRIVE%:"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
%UI% :VALASZT IN "Indulhat a mentés?"
if errorlevel 2 goto :MEGSZAKITVA

mkdir "%CEL%" 2>nul
if not exist "%CEL%\" (
    echo   !C_PIROS!A mentés mappája nem hozható létre: !CEL!!C_0!
    goto :NEM_INDULT
)
set "LOG=%CEL%\mentes_naplo.txt"
>>"%LOG%" echo ===== MENTÉS %date% %time% – %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\mentes_naplo.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "Adatok mentése folyamatban"
echo   A folyamat végéig ne húzd ki a külső meghajtót.

rem ---------- Lepesek ----------
%TETELEK% :FUTTAT MENT

%UI% :FEJLEC "Programlista"
%PROGRAMLISTA% :KESZIT "%CEL%\apps.txt"
rem A regi gep asztali Office-ikonjai - visszaallitaskor ezek is kikerulnek
%IKONOK% :MENT "%CEL%\asztal_office.txt"

%UI% :FEJLEC "Tálcaikonok listája"
%TALCA% :LISTA "%CEL%\talca.txt"

%UI% :FEJLEC "Outlook-lista"
%OUTLOOK% :LISTA_MENT

%UI% :FEJLEC "Nyomtatók, meghajtók"
%NYOMTATOK% :LISTA "%CEL%\nyomtatok_meghajtok.txt"
exit /b 0

:MEGSZAKITVA
exit /b 1

:NEM_INDULT
exit /b 2
