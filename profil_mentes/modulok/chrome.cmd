rem ==========================================================
rem  4. Chrome telepitese - ha a Szoftverkozpont nem inditja el a letoltest
rem  A legfrissebb Chrome a Google oldalarol (ceges MSI), rendszergazdai jelszoval.
rem  Gepszintu telepites, kulso meghajto nem kell. A munka: lib\chrome.cmd
rem  Kilepesi kod: 4 = vegigment, rovid zaras; 1 = nem kertek
rem ==========================================================

cls
%UI% :CIM "Chrome telepítése"
echo   A legújabb céges Chrome a Google-tól (kb. 170 MB) – a Windows jelszót kér.
echo.
%CHROME% :VERZIO
rem Ha mar van Chrome, a telepito frissiti - ezt megkerdezzuk; ha nincs, rogton indul
if defined CH_VERZIO (
    %UI% :ADAT "Telepítve" "Chrome !CH_VERZIO!"
    echo.
    %UI% :VALASZT IN "Frissítsem a legújabbra?"
    if errorlevel 2 goto :MEGSZAKITVA
)
set /a OSSZES=2

set "LOG=%TEMP%\chrome_naplo.txt"
>>"%LOG%" echo ===== CHROME TELEPÍTÉSE %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
%UI% :FEJLEC "Letöltés"
%CHROME% :LETOLT
%UI% :FEJLEC "Telepítés"
if "%CH_LETOLTVE%"=="1" (
    %CHROME% :TELEPIT
) else (
    %UI% :JELOL KIHAGYVA "a letöltés nem sikerült"
)
exit /b 4

:MEGSZAKITVA
exit /b 1
