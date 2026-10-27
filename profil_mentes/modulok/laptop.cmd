rem ==========================================================
rem  3. Laptop beallitasok: fedel lehajtasa, BitLocker aktivalasa
rem  Gepszintu beallitas, kulso meghajto nem kell.
rem  A munka: lib\laptop.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "LAPTOP BEALLITASOK"
echo    Valaszthato lepesek:
echo      - Fedel lehajtasa: ne tortenjen semmi - halozatrol es akkumulatorrol is
echo      - BitLocker aktivalasa: MBAMAgent, 2 mp, MBAMClientUI, 2 mp, MBAMAgent ujra
echo.
set /a DO_FEDEL=0, DO_BL=0
%UI% :VALASZT IN "   Fedel lehajtasakor ne tortenjen semmi"
if not errorlevel 2 set /a DO_FEDEL=1
%UI% :VALASZT IN "   BitLocker aktivalasa"
if not errorlevel 2 set /a DO_BL=1
set /a OSSZES=DO_FEDEL+DO_BL
if %OSSZES%==0 (
    echo.
    echo    Nem valasztottal semmit.
    goto :MEGSZAKITVA
)
echo.
%UI% :VALASZT IN "   Indulhat"
if errorlevel 2 goto :MEGSZAKITVA

set "LOG=%TEMP%\laptop_log.txt"
>>"%LOG%" echo ===== LAPTOP BEALLITASOK %date% %time% - %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "LAPTOP BEALLITASOK FOLYAMATBAN"
if "%DO_FEDEL%"=="1" (
    %UI% :FEJLEC "Fedel lehajtasa"
    %LAPTOP% :FEDEL
)
if "%DO_BL%"=="1" (
    %UI% :FEJLEC "BitLocker - MBAM"
    %LAPTOP% :BITLOCKER
)
exit /b 0

:MEGSZAKITVA
exit /b 1
