rem ==========================================================
rem  1. Adatok mentese (a regi gepen)
rem  2. Probafuttatas - TESZTMOD=1: vegigellenoriz, de nem masol
rem
rem  A mentendo tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :MEGSZAKITVA
if "%TESZTMOD%"=="1" (%ELLENORZES% :MEGHAJTO JELEZ) else (%ELLENORZES% :MEGHAJTO KELL)
if errorlevel 1 goto :MEGSZAKITVA

%TETELEK% :BETOLT
rem Lepesek: a tetelek, a programlista, a talca es az Outlook-lista, probafuttatasnal a kornyezet is
set /a OSSZES=T_DB+3+TESZTMOD
set "CEL=%ROOT%\%USERNAME%_%COMPUTERNAME%"

rem ---------- Elokeszites ----------
cls
if "%TESZTMOD%"=="1" (
    %UI% :CIM "Próbafuttatás – előkészítés"
    echo   !C_SARGA!Próbafuttatás: minden lépést ellenőrzök, de nem másolok semmit,!C_0!
    echo   !C_SARGA!és a külső meghajtón sem hozok létre semmit.!C_0!
    echo.
) else (
    %UI% :CIM "Adatok mentése – előkészítés"
)
%UI% :ADAT "Mentés helye" "%CEL%"
echo.
echo   Mentendő tételek:
%TETELEK% :LISTA "Programlista" "Tálcaikonok listája" "Outlook-lista"
if exist "%CEL%\" (
    echo.
    echo   !C_SARGA!Ennek a gépnek már van mentése: a meglévő fájlok frissülnek,!C_0!
    echo   !C_SARGA!semmi nem törlődik.!C_0!
)

%OUTLOOK% :LISTA_KESZIT
if "%OL_STOP%"=="1" goto :MEGSZAKITVA

%ATNEZENDO% :KERES

echo.
echo   Helyellenőrzés, egy pillanat...
%TETELEK% :FORRASOK
set "PS_BETU=%DRIVE%:"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
if "%TESZTMOD%"=="1" goto :TESZT_INDUL
%UI% :VALASZT IN "Indulhat a mentés?"
if errorlevel 2 goto :MEGSZAKITVA

mkdir "%CEL%" 2>nul
if not exist "%CEL%\" (
    echo   !C_PIROS!A mentés mappája nem hozható létre: !CEL!!C_0!
    goto :MEGSZAKITVA
)
set "LOG=%CEL%\mentes_log.txt"
>>"%LOG%" echo ===== MENTÉS %date% %time% – %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\mentes_log.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "Adatok mentése folyamatban"
echo   A folyamat végéig ne húzd ki a külső meghajtót.
goto :LEPESEK

:TESZT_INDUL
%UI% :VALASZT IN "Indulhat a próbafuttatás?"
if errorlevel 2 goto :MEGSZAKITVA
set "LOG=%TEMP%\teszt_log.txt"
del /q "%LOG%" >nul 2>&1
>>"%LOG%" echo ===== PRÓBAFUTTATÁS %date% %time% – %USERNAME% / %COMPUTERNAME% =====
%UI% :IDO START_MP
cls
%UI% :CIM "Próbafuttatás folyamatban – semmi nem másolódik"
%UI% :FEJLEC "Környezet"
%ELLENORZES% :KORNYEZET

rem ---------- Lepesek ----------
:LEPESEK
%TETELEK% :FUTTAT MENT

%UI% :FEJLEC "Programlista"
if "%TESZTMOD%"=="1" (
    %PROGRAMLISTA% :KESZIT "%TEMP%\_teszt_apps.txt"
    del /q "%TEMP%\_teszt_apps.txt" >nul 2>&1
) else (
    %PROGRAMLISTA% :KESZIT "%CEL%\apps.txt"
)

%UI% :FEJLEC "Tálcaikonok listája"
if "%TESZTMOD%"=="1" (
    %TALCA% :LISTA "%TEMP%\_teszt_talca.txt"
    del /q "%TEMP%\_teszt_talca.txt" >nul 2>&1
) else (
    %TALCA% :LISTA "%CEL%\talca.txt"
)

%UI% :FEJLEC "Outlook-lista"
%OUTLOOK% :LISTA_MENT
exit /b 0

:MEGSZAKITVA
exit /b 1
