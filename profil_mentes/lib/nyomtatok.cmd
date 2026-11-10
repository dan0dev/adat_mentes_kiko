@call %*
@exit /b

rem ==========================================================
rem  Nyomtatok es halozati meghajtok listaja - a munka: ps\nyomtatok.ps1
rem  Hivas: %NYOMTATOK% :LISTA "kimeneti fajl"
rem ==========================================================

:LISTA
set "NY_FAJL=%~1"
set "_ny="
set "_mh="
set "PS_FAJL=%PSDIR%\nyomtatok.ps1"
for /f "tokens=1,2 delims=|" %%a in ('%PS_FUTTAT% 2^>nul') do (
    set "_ny=%%a"
    set "_mh=%%b"
)
if not defined _ny (
    %UI% :JELOL HIBA "a lista nem készült el" "A PowerShell nem elérhető."
    goto :eof
)
%UI% :JELOL OK "%_ny% nyomtató, %_mh% meghajtó" "nyomtatok_meghajtok.txt"
goto :eof
