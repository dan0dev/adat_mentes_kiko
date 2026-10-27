rem ==========================================================
rem  5. Alapertelmezett alkalmazasok
rem  Rendszergazdakent beallit, felhasznalokent csak ellenoriz.
rem  A programok listaja: config\alapertelmezett_alk.cmd, a munka: lib\alapalk.cmd
rem  Kilepesi kod: 0 = vegigment, osszegzes jon; 1 = megszakitva
rem ==========================================================

cls
%UI% :CIM "ALAPERTELMEZETT ALKALMAZASOK"
echo    Word, Excel, PowerPoint, Adobe Acrobat Reader - PDF, Chrome - bongeszo
echo.
echo    A Windows nem engedi, hogy egy script kozvetlenul atirja a felhasznalo
echo    alapertelmezett alkalmazasait. A Microsoft altal tamogatott mod: egy
echo    beallitofajlt rogzitunk, amit a Windows a bejelentkezeskor maga alkalmaz.
echo.
if "%ADMIN%"=="1" (
    set "AA_MOD=beallit"
    echo    !C_ZOLD!Rendszergazdakent fut:!C_0! a beallitofajl elkeszul es rogzitesre kerul.
    echo    Utana a felhasznalo jelentkezzen ki es be, majd ellenorizd ugyanitt,
    echo    a script sima inditasaval, az 5-os menuponttal.
) else (
    set "AA_MOD=ellenoriz"
    echo    !C_SARGA!Felhasznalokent fut:!C_0! most csak ellenorzom a jelenlegi beallitasokat.
    echo    A beallitashoz: jobb klikk a scripten - Futtatas rendszergazdakent - 5-os menu.
)
echo.
%UI% :VALASZT IN "   Indulhat"
if errorlevel 2 goto :MEGSZAKITVA

set /a OSSZES=1
set "LOG=%TEMP%\alapertelmezett_alk_log.txt"
>>"%LOG%" echo ===== ALAPERTELMEZETT ALKALMAZASOK %date% %time% - %USERNAME% / %COMPUTERNAME% =====

%UI% :IDO START_MP
cls
%UI% :CIM "ALAPERTELMEZETT ALKALMAZASOK"
if "%AA_MOD%"=="beallit" (
    %UI% :FEJLEC "Alapertelmezett alkalmazasok beallitasa"
    %ALAPALK% :BEALLIT
) else (
    %UI% :FEJLEC "Alapertelmezett alkalmazasok ellenorzese"
    %ALAPALK% :ELLENORIZ
)
exit /b 0

:MEGSZAKITVA
exit /b 1
