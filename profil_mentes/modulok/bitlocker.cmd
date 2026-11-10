rem ==========================================================
rem  3. BitLocker beallitasa: titkositas inditasa az MBAM klienssel
rem  Gepszintu beallitas, kulso meghajto nem kell.
rem  A munka: lib\bitlocker.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "BitLocker beállítása"
echo   A BitLocker titkosítást az MBAM kliens indítja: MBAMAgent, MBAMClientUI.
echo.
%UI% :VALASZT IN "Indulhat?"
if errorlevel 2 goto :MEGSZAKITVA
set /a OSSZES=1, DO_BL=1

set "LOG=%TEMP%\bitlocker_naplo.txt"
>>"%LOG%" echo ===== BITLOCKER BEÁLLÍTÁSA %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "BitLocker beállítása folyamatban"
%UI% :FEJLEC "BitLocker (MBAM)"
%BITLOCKER% :INDIT
exit /b 0

:MEGSZAKITVA
exit /b 1
