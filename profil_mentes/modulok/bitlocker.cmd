rem ==========================================================
rem  3. BitLocker beallitasa: titkositas inditasa az MBAM klienssel
rem  Gepszintu beallitas, kulso meghajto nem kell.
rem  A munka: lib\bitlocker.cmd
rem  Kilepesi kod: 4 = vegigment, rovid zaras
rem ==========================================================

cls
%UI% :CIM "BitLocker beállítása"
set /a OSSZES=1, DO_BL=1

set "LOG=%TEMP%\bitlocker_naplo.txt"
>>"%LOG%" echo ===== BITLOCKER BEÁLLÍTÁSA %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
%UI% :FEJLEC "BitLocker (MBAM)"
%BITLOCKER% :INDIT
exit /b 4
