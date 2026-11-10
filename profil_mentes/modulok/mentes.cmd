rem ==========================================================
rem  1. Adatok mentese (a regi gepen)
rem
rem  A mentendo tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :MEGSZAKITVA
%ELLENORZES% :MEGHAJTO KELL
if errorlevel 1 goto :MEGSZAKITVA

%TETELEK% :BETOLT
rem Lepesek: a tetelek, a programlista, a talca es az Outlook-lista
set /a OSSZES=T_DB+3
set "CEL=%ROOT%\%USERNAME%_%COMPUTERNAME%"

rem ---------- Elokeszites ----------
cls
%UI% :CIM "Adatok mentése – előkészítés"
%UI% :ADAT "Mentés helye" "%CEL%"
echo.
echo   Mentendő tételek:
%TETELEK% :LISTA "Programlista" "Tálcaikonok listája" "Outlook-lista"
echo.
echo   !C_SARGA!A tanúsítványokat és a PST-ket a segédlet nem menti – kézzel intézd.!C_0!
if exist "%CEL%\" (
    echo.
    echo   !C_SARGA!Ennek a gépnek már van mentése: a meglévő fájlok frissülnek,!C_0!
    echo   !C_SARGA!semmi nem törlődik.!C_0!
)

%OUTLOOK% :LISTA_KESZIT
if "%OL_STOP%"=="1" goto :MEGSZAKITVA

echo.
echo   Helyellenőrzés, egy pillanat...
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
    goto :MEGSZAKITVA
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

%UI% :FEJLEC "Tálcaikonok listája"
%TALCA% :LISTA "%CEL%\talca.txt"

%UI% :FEJLEC "Outlook-lista"
%OUTLOOK% :LISTA_MENT
exit /b 0

:MEGSZAKITVA
exit /b 1
