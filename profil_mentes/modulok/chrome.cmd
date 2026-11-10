rem ==========================================================
rem  4. Chrome telepitese - ha a Szoftverkozpont nem inditja el a letoltest
rem  A legfrissebb Chrome a Google oldalarol (ceges MSI), rendszergazdai jelszoval.
rem  Gepszintu telepites, kulso meghajto nem kell. A munka: lib\chrome.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "Chrome telepítése"
echo   Ha a Szoftverközpont nem indítja el a Chrome letöltését: a legfrissebb
echo   Chrome a Google oldaláról, a céges telepítővel – kb. 170 MB.
echo   A telepítéshez rendszergazdai jelszó kell, a Windows kérni fogja.
echo.
%CHROME% :VERZIO
if defined CH_VERZIO (%UI% :ADAT "Most fent van" "Chrome !CH_VERZIO! – a telepítő frissíti") else (%UI% :ADAT "Most fent van" "nincs Chrome")
echo.
%UI% :VALASZT IN "Indulhat?"
if errorlevel 2 goto :MEGSZAKITVA
set /a OSSZES=2

set "LOG=%TEMP%\chrome_naplo.txt"
>>"%LOG%" echo ===== CHROME TELEPÍTÉSE %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "Chrome telepítése folyamatban"
%UI% :FEJLEC "Letöltés"
%CHROME% :LETOLT
%UI% :FEJLEC "Telepítés"
if "%CH_LETOLTVE%"=="1" (
    %CHROME% :TELEPIT
) else (
    %UI% :JELOL KIHAGYVA "a letöltés nem sikerült"
)
exit /b 0

:MEGSZAKITVA
exit /b 1
