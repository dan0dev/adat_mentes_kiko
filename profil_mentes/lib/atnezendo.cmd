@call %*
@exit /b

rem ==========================================================
rem  Kezzel atnezendo mappak: Letoltesek, a felhasznalo sajat mappaja...
rem  Csak megkeresi es kiirja - masolni kezzel kell. A munka: ps\atnezendo.ps1
rem  Hivas: %ATNEZENDO% :KERES.  Kimenet: ATN_DB, ATN_n - a _LEFT-TO-DO.txt-be is bekerul
rem ==========================================================

:KERES
set /a ATN_DB=0
echo.
echo    !C_FEHER!Kezzel atnezendo!C_0! - ezeket a script nem menti, keresem...
rem A PST mappan kivuli csatolt PST-k - az Outlook lista elobb fut, OLK_n-ben vannak
set "ATNEZ_PSTK="
for /l %%i in (1,1,%OL_KINT%) do set "ATNEZ_PSTK=!ATNEZ_PSTK!;!OLK_%%i!"
rem Nem for /f-ben fut: az csak a vegen irna ki mindent, igy a meres alatt latszik a haladas.
rem A listat a PowerShell kiirja, es az ATN_KI fajlba is menti - innen olvassuk vissza.
set "ATN_KI=%TEMP%\atnezendo_%RANDOM%.txt"
if exist "%ATN_KI%" del /q "%ATN_KI%"
set "PS_FAJL=%PSDIR%\atnezendo.ps1"
%PS_FUTTAT% 2>nul
if exist "%ATN_KI%" (
    for /f "usebackq delims=" %%a in ("%ATN_KI%") do (
        set /a ATN_DB+=1
        set "ATN_!ATN_DB!=%%a"
    )
    del /q "%ATN_KI%"
)
if %ATN_DB%==0 echo    !C_SARGA![i] A lista nem keszult el - a PowerShell nem elerheto.!C_0!
goto :eof
