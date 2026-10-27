rem ==========================================================
rem  1. Adatok mentese (eszkozcsere regi)
rem  4. Teszt futtatas - TESZTMOD=1: vegigellenoriz, de nem masol
rem
rem  A mentendo tetelek: config\tetelek.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

%ELLENORZES% :FELHASZNALO
if errorlevel 1 goto :MEGSZAKITVA
if "%TESZTMOD%"=="1" (%ELLENORZES% :MEGHAJTO JELEZ) else (%ELLENORZES% :MEGHAJTO KELL)

%TETELEK% :BETOLT
rem Lepesek: a tetelek, a programlista, a talca es az Outlook lista, tesztnel a kornyezet is
set /a OSSZES=T_DB+3+TESZTMOD
set "CEL=%ROOT%\%USERNAME%_%COMPUTERNAME%"

rem ---------- Elokeszites ----------
cls
if "%TESZTMOD%"=="1" (
    %UI% :CIM "TESZT FUTTATAS - a mentes probaja"
    echo    !C_SARGA!Teszt mod: minden lepest vegigellenoriz, de semmit nem masol es nem hoz letre.!C_0!
    echo.
) else (
    %UI% :CIM "ADATOK MENTESE - ELOKESZITES"
)
echo    Cel mappa  : %CEL%
echo.
echo    Mentendo tetelek:
%TETELEK% :LISTA "Telepitett programok listaja" "Talca ikonjai - lista" "Outlook lista - csatolt PST-k"
if exist "%CEL%\" (
    echo.
    echo    !C_SARGA!Mar letezik mentes ennek a gepnek. A meglevo fajlok frissulnek, semmi nem torlodik.!C_0!
)

%OUTLOOK% :LISTA_KESZIT
if "%OL_STOP%"=="1" goto :MEGSZAKITVA

%ATNEZENDO% :KERES

echo.
echo    Hely ellenorzese, egy pillanat...
%TETELEK% :FORRASOK
set "PS_BETU=%DRIVE%:"
%ELLENORZES% :HELY
if "%HELY_STOP%"=="1" goto :MEGSZAKITVA

%ELLENORZES% :APPOK

echo.
if "%TESZTMOD%"=="1" goto :TESZT_INDUL
%UI% :VALASZT IN "   Indulhat a mentes"
if errorlevel 2 goto :MEGSZAKITVA

mkdir "%CEL%" 2>nul
if not exist "%CEL%\" (
    echo    !C_PIROS!Nem sikerult letrehozni a mentes mappat: !CEL!!C_0!
    goto :MEGSZAKITVA
)
set "LOG=%CEL%\mentes_log.txt"
>>"%LOG%" echo ===== MENTES %date% %time% - %USERNAME% / %COMPUTERNAME% ===== || set "LOG=%TEMP%\mentes_log.txt"

%UI% :IDO START_MP
cls
%UI% :CIM "ADATOK MENTESE FOLYAMATBAN"
echo    Ne huzd ki a kulso meghajtot, amig a script fut.
goto :LEPESEK

:TESZT_INDUL
%UI% :VALASZT IN "   Indulhat a teszt"
if errorlevel 2 goto :MEGSZAKITVA
set "LOG=%TEMP%\teszt_log.txt"
del /q "%LOG%" >nul 2>&1
>>"%LOG%" echo ===== TESZT %date% %time% - %USERNAME% / %COMPUTERNAME% =====
%UI% :IDO START_MP
cls
%UI% :CIM "TESZT FUTTATAS FOLYAMATBAN - semmi nem masolodik"
%UI% :FEJLEC "Kornyezet"
%ELLENORZES% :KORNYEZET

rem ---------- Lepesek ----------
:LEPESEK
%TETELEK% :FUTTAT MENT

%UI% :FEJLEC "Telepitett programok"
if "%TESZTMOD%"=="1" (
    %PROGRAMLISTA% :KESZIT "%TEMP%\_teszt_apps.txt"
    del /q "%TEMP%\_teszt_apps.txt" >nul 2>&1
) else (
    %PROGRAMLISTA% :KESZIT "%CEL%\apps.txt"
)

%UI% :FEJLEC "Talca ikonjai"
if "%TESZTMOD%"=="1" (
    %TALCA% :LISTA "%TEMP%\_teszt_talca.txt"
    del /q "%TEMP%\_teszt_talca.txt" >nul 2>&1
) else (
    %TALCA% :LISTA "%CEL%\talca.txt"
)

%UI% :FEJLEC "Outlook lista"
%OUTLOOK% :LISTA_MENT
exit /b 0

:MEGSZAKITVA
exit /b 1
