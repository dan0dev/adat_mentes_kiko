rem ==========================================================
rem  5. Alapertelmezett alkalmazasok
rem  Rendszergazdakent beallit, felhasznalokent csak ellenoriz.
rem  A programok listaja: config\alapertelmezett_alk.cmd, a munka: lib\alapalk.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "Alapértelmezett alkalmazások"
echo   Word, Excel, PowerPoint, Adobe Acrobat Reader – PDF, Chrome – böngésző
echo.
echo   A Windows nem engedi, hogy egy program közvetlenül átírja a felhasználó
echo   alapértelmezett alkalmazásait. A Microsoft által támogatott mód: egy
echo   beállítófájlt rögzítünk, amelyet a Windows bejelentkezéskor maga alkalmaz.
echo.
if "%ADMIN%"=="1" (
    set "AA_MOD=beallit"
    echo   !C_ZOLD!Rendszergazdaként fut:!C_0! a beállítófájl elkészül és rögzítésre kerül.
    echo   Utána a felhasználónak ki és be kell jelentkeznie, majd ellenőrizd ugyanitt,
    echo   a segédlet sima indításával, az 5. menüponttal.
) else (
    set "AA_MOD=ellenoriz"
    echo   !C_SARGA!Felhasználóként fut:!C_0! most csak ellenőrzöm a jelenlegi beállításokat.
    echo   A beállításhoz: jobb kattintás a segédleten – Futtatás rendszergazdaként –
    echo   5. menüpont.
)
echo.
%UI% :VALASZT IN "Indulhat?"
if errorlevel 2 goto :MEGSZAKITVA

set /a OSSZES=1
set "LOG=%TEMP%\alapertelmezett_alk_naplo.txt"
>>"%LOG%" echo ===== ALAPÉRTELMEZETT ALKALMAZÁSOK %date% %time% – %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "Alapértelmezett alkalmazások folyamatban"
if "%AA_MOD%"=="beallit" (
    %UI% :FEJLEC "Társítások beállítása"
    %ALAPALK% :BEALLIT
) else (
    %UI% :FEJLEC "Társítások ellenőrzése"
    %ALAPALK% :ELLENORIZ
)
exit /b 0

:MEGSZAKITVA
exit /b 1
