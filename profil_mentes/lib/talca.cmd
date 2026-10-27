@call %*
@exit /b

rem ==========================================================
rem  A talcara rogzitett ikonok listaja - talca.txt
rem  Ujra rogziteni kezzel kell: Windows 11-en script nem tud megbizhatoan rogziteni.
rem  Hivas: %TALCA% :LISTA "kimeneti fajl"
rem ==========================================================

:LISTA
rem %1 = kimeneti fajl. Elsodlegesen PowerShell - ps\talca.ps1 -, ha tiltva van, csak a parancsikonok neve.
set "TALCA_FAJL=%~1"
set "TALCA_DB="
set "PS_FAJL=%PSDIR%\talca.ps1"
for /f %%c in ('%PS_FUTTAT% 2^>nul') do set "TALCA_DB=%%c"
if defined TALCA_DB if exist "%TALCA_FAJL%" goto :KESZ
echo        PowerShell nem elerheto, csak az asztali programok kerulnek a listara...
set /a TALCA_DB=0
set "_tb=%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
>"%TALCA_FAJL%" echo TALCA ROGZITETT IKONJAI - %USERNAME% / %COMPUTERNAME%
>>"%TALCA_FAJL%" echo.
for %%f in ("%_tb%\*.lnk") do (
    >>"%TALCA_FAJL%" echo    - %%~nf
    set /a TALCA_DB+=1
)
:KESZ
if "%TALCA_DB%"=="0" (
    %UI% :JELOL KIHAGYVA "nincs rogzitett ikon a talcan"
    goto :eof
)
if "%TESZTMOD%"=="1" (
    %UI% :JELOL OK "%TALCA_DB% ikon - listazhato"
) else (
    %UI% :JELOL OK "%TALCA_DB% ikon - talca.txt"
)
goto :eof
