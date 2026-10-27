rem ==========================================================
rem  4. Laptop beallitasa: fedel lehajtasa, BitLocker aktivalasa
rem  Gepszintu beallitas, kulso meghajto nem kell.
rem  A munka: lib\laptop.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "Laptop beállítása"
echo   Választható lépések:
echo     – Fedél lehajtásakor: Nincs művelet – hálózatról és akkumulátorról is
echo     – BitLocker aktiválása az MBAM klienssel: MBAMAgent, MBAMClientUI
echo.
set /a DO_FEDEL=0, DO_BL=0
%UI% :VALASZT IN "Fedél lehajtásakor ne történjen semmi – beállítsam?"
if not errorlevel 2 set /a DO_FEDEL=1
%UI% :VALASZT IN "BitLocker aktiválása – indítsam?"
if not errorlevel 2 set /a DO_BL=1
set /a OSSZES=DO_FEDEL+DO_BL
if %OSSZES%==0 (
    echo.
    echo   Nem választottál semmit.
    goto :MEGSZAKITVA
)
echo.
%UI% :VALASZT IN "Indulhat?"
if errorlevel 2 goto :MEGSZAKITVA

set "LOG=%TEMP%\laptop_naplo.txt"
>>"%LOG%" echo ===== LAPTOP BEÁLLÍTÁSA %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "Laptop beállítása folyamatban"
if "%DO_FEDEL%"=="1" (
    %UI% :FEJLEC "Fedél lehajtása"
    %LAPTOP% :FEDEL
)
if "%DO_BL%"=="1" (
    %UI% :FEJLEC "BitLocker (MBAM)"
    %LAPTOP% :BITLOCKER
)
exit /b 0

:MEGSZAKITVA
exit /b 1
