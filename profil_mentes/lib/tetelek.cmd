@call %*
@exit /b

rem ==========================================================
rem  A mentendo tetelek kezelese - a lista: config\tetelek.cmd
rem  Minden tetelt a tipusa szerinti fajl vegzi: lib\tipusok\TIPUS.cmd,
rem  abban :MENT es :VISSZA cimke. Bemenetuk: T_NEV, T_FORRAS, T_MAPPA,
rem  T_P1, T_P2, es mentesnel CEL, exportalasnal FORRAS.
rem  Hivas: %TETELEK% :CIMKE parameterek
rem ==========================================================

:BETOLT
rem A config\tetelek.cmd beolvasasa. Kimenet: T_DB es a T_*_n tombok
set /a T_DB=0
set TETEL=call "%LIB%\tetelek.cmd" :UJ
call "%CONF%\tetelek.cmd"
goto :eof

:UJ
rem %1 = tipus, %2 = nev, %3 = forras, %4 = mappa a mentesben, %5 %6 = tipus szerinti parameterek
rem A nev zarojelet is tartalmazhat, ezert a %~2 nem kerulhet ( ) blokkba.
if exist "%LIB%\tipusok\%~1.cmd" goto :UJ_OK
echo   !C_PIROS!config\tetelek.cmd: ismeretlen típus: %~1 – %~2!C_0!
goto :eof
:UJ_OK
set /a T_DB+=1
set "T_TIPUS_%T_DB%=%~1"
set "T_NEV_%T_DB%=%~2"
set "T_FORRAS_%T_DB%=%~3"
set "T_MAPPA_%T_DB%=%~4"
set "T_P1_%T_DB%=%~5"
set "T_P2_%T_DB%=%~6"
goto :eof

:FUTTAT
rem %1 = MENT vagy VISSZA - minden tetel egy-egy lepes, a lista sorrendjeben
for /l %%i in (1,1,%T_DB%) do call :EGY %%i %~1
goto :eof

:EGY
rem %1 = tetel sorszama, %2 = MENT vagy VISSZA
set "T_TIPUS=!T_TIPUS_%~1!"
set "T_NEV=!T_NEV_%~1!"
set "T_FORRAS=!T_FORRAS_%~1!"
set "T_MAPPA=!T_MAPPA_%~1!"
set "T_P1=!T_P1_%~1!"
set "T_P2=!T_P2_%~1!"
%UI% :FEJLEC "%T_NEV%"
call "%LIB%\tipusok\%T_TIPUS%.cmd" :%~2
goto :eof

:FORRASOK
rem A helyellenorzeshez: a MAPPA tipusu tetelek forrasai pontosvesszovel. Kimenet: PS_FORRASOK
set "PS_FORRASOK="
for /l %%i in (1,1,%T_DB%) do if /I "!T_TIPUS_%%i!"=="MAPPA" (
    if defined PS_FORRASOK (set "PS_FORRASOK=!PS_FORRASOK!;!T_FORRAS_%%i!") else (set "PS_FORRASOK=!T_FORRAS_%%i!")
)
goto :eof

:LISTA
rem A tetelek kiirasa ket oszlopban. Parameterek: tovabbi, nem a listabol jovo tetelek nevei.
set /a L_DB=0
for /l %%i in (1,1,%T_DB%) do (
    set /a L_DB+=1
    set "L_!L_DB!=!T_NEV_%%i!"
)
:LISTA_TOVABBI
if "%~1"=="" goto :LISTA_KIIR
set /a L_DB+=1
set "L_%L_DB%=%~1"
shift
goto :LISTA_TOVABBI
:LISTA_KIIR
set /a L_SOR=(L_DB+1)/2
for /l %%r in (1,1,%L_SOR%) do call :LISTA_SOR %%r
goto :eof

:LISTA_SOR
rem %1 = sor sorszama: bal oszlopban az %1., jobb oszlopban az %1+L_SOR. tetel
set /a _b=%~1, _j=%~1+L_SOR
set "_nb= %_b%"
set "_nj= %_j%"
set "_nb=!_nb:~-2!"
set "_nj=!_nj:~-2!"
set "_bal=!L_%_b%!"
%UI% :PAD _bal 27
if %_j% GTR %L_DB% (
    echo     !_nb!. !L_%_b%!
) else (
    echo     !_nb!. !_bal!!_nj!. !L_%_j%!
)
goto :eof
