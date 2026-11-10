@call %*
@exit /b

rem ==========================================================
rem  Tetel tipus: REG - registry-kulcsok a felhasznalo agabol (HKCU)
rem  pl. az Office legutobbi fajljai (User MRU) - Office 2016 es 365: 16.0
rem  T_FORRAS = a kulcsok pontosvesszovel; mentesnel kulcsonkent egy .reg fajl
rem  Visszaallitaskor a mentes osszes .reg fajlja visszatoltodik - a program ne
rem  fusson kozben, kulonben bezaraskor felulirja (a futo programok ellenorzese ezt kezeli).
rem  Rendszergazda nem kell: csak a felhasznalo sajat aga.
rem ==========================================================

:MENT
set "_rcel=%CEL%\%T_MAPPA%"
set /a _rdb=0, _rhiba=0
for %%k in ("%T_FORRAS:;=" "%") do (
    reg query "%%~k" >nul 2>&1 && call :EGY_MENT "%%~k"
)
if %_rdb%==0 if %_rhiba%==0 (
    %UI% :JELOL KIHAGYVA "ezen a gépen nincs ilyen"
    goto :eof
)
if %_rhiba% GTR 0 (
    %UI% :JELOL HIBA "%_rhiba% kulcs nem menthető" "Részletek a naplóban."
    goto :eof
)
%UI% :JELOL OK "%_rdb% lista, elmentve"
goto :eof

:EGY_MENT
rem %1 = a kulcs. A fajl neve a kulcs elotti utolso resz, pl. Word.reg
set "_rk=%~1"
for %%n in ("%_rk:\=" "%") do (
    if /I not "%%~n"=="User MRU" set "_rn=%%~n"
)
if not exist "%_rcel%\" mkdir "%_rcel%" 2>nul
reg export "%~1" "%_rcel%\%_rn%.reg" /y >>"%LOG%" 2>&1
if exist "%_rcel%\%_rn%.reg" (
    set /a _rdb+=1
    %UI% :RESZLET "%_rn%"
) else (
    set /a _rhiba+=1
    >>"%LOG%" echo        nem menthető: %~1
)
goto :eof

:VISSZA
set "_rfor=%FORRAS%\%T_MAPPA%"
set /a _rdb=0, _rhiba=0
if exist "%_rfor%\*.reg" for %%f in ("%_rfor%\*.reg") do call :EGY_VISSZA "%%~ff"
if %_rdb%==0 if %_rhiba%==0 (
    %UI% :JELOL KIHAGYVA "nincs a mentésben"
    goto :eof
)
if %_rhiba% GTR 0 (
    %UI% :JELOL HIBA "%_rhiba% lista nem tölthető vissza" "Részletek a naplóban."
    goto :eof
)
%UI% :JELOL OK "%_rdb% lista, visszatöltve"
goto :eof

:EGY_VISSZA
rem %1 = a .reg fajl
reg import "%~1" >>"%LOG%" 2>&1
if errorlevel 1 (
    set /a _rhiba+=1
    >>"%LOG%" echo        nem tölthető vissza: %~1
) else (
    set /a _rdb+=1
    %UI% :RESZLET "%~n1"
)
goto :eof
