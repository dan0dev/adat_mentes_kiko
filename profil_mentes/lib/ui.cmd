@call %*
@exit /b

rem ==========================================================
rem  Kepernyo, lepesek es eredmenyek
rem  Hivas: %UI% :CIMKE parameterek
rem ==========================================================

:CIM
echo.
echo  !C_KEK!==========================================================!C_0!
echo  !C_FEHER!  %~1!C_0!
echo  !C_KEK!==========================================================!C_0!
echo.
goto :eof

:FEJLEC
rem Uj lepes kezdete: sorszam, ablakcim, log
set /a LEPES+=1
set "NEV_%LEPES%=%~1"
title [%LEPES%/%OSSZES%] %~1 - %MOD_NEV%
echo.
echo  !C_KEK![%LEPES%/%OSSZES%]!C_0! !C_FEHER!%~1!C_0!
echo        folyamatban...
>>"%LOG%" echo.
>>"%LOG%" echo [%time%] [%LEPES%/%OSSZES%] %~1
goto :eof

:JELOL
rem %1 = OK / HIBA / KIHAGYVA / NEMKERT, %2 = uzenet
set "E_%LEPES%=%~1"
set "M_%LEPES%=%~2"
if "%~1"=="OK" set /a DB_OK+=1
if "%~1"=="HIBA" set /a DB_HIBA+=1
if "%~1"=="KIHAGYVA" set /a DB_KIHAGY+=1
if "%~1"=="OK" echo        !C_ZOLD![OK]!C_0! %~2
if "%~1"=="HIBA" echo        !C_PIROS![HIBA]!C_0! %~2
if "%~1"=="KIHAGYVA" echo        !C_SARGA![KIHAGYVA]!C_0! %~2
if "%~1"=="NEMKERT" echo        !C_SZURKE![ - ]!C_0! %~2
>>"%LOG%" echo        Eredmeny: %~1 - %~2
goto :eof

:OSSZ_SOR
rem %1 = lepes sorszama - egy sor az osszegzesben, a kepernyon es a fajlban
set "_st=!E_%~1!"
set "_nv=!NEV_%~1!"
set "_ms=!M_%~1!"
set "_pad=!_nv!                              "
set "_pad=!_pad:~0,24!"
if "!_st!"=="OK" echo    !C_ZOLD![OK]      !C_0!!_pad! !_ms!
if "!_st!"=="HIBA" echo    !C_PIROS![HIBA]    !C_0!!_pad! !_ms!
if "!_st!"=="KIHAGYVA" echo    !C_SARGA![KIHAGYVA]!C_0!!_pad! !_ms!
if "!_st!"=="NEMKERT" echo    !C_SZURKE![ - ]     !C_0!!_pad! !_ms!
>>"%OSSZ_FAJL%" echo [!_st!] !_nv! - !_ms!
goto :eof

:MB_GB
rem %1 = MB erteket tartalmazo valtozo, %2 = kimeneti szoveg valtozo
set /a "_g=!%~1!/1024, _t=(!%~1! %% 1024)*10/1024"
set "%~2=!_g!,!_t! GB"
goto :eof

:VALASZT
rem Csendes valasztas a choice helyett - a choice minden rossz billentyunel sipol,
rem ez csak var tovabb. Egy billentyu, Enter nelkul, kis- es nagybetu is jo.
rem %1 = a lehetseges betuk, pl. IN, %2 = kerdes, %3 = N: ne irja utana a [I,N]? reszt
rem Kimenet: errorlevel = a valasztott betu sorszama, mint a choice-nal: I = 1, N = 2
rem VALASZ_SORBOL=1: a valaszt soronkent olvassa a bemenetrol - automatikus futtatashoz
set "_vb=%~1"
set "_vk=%~2"
if /I not "%~3"=="N" (
    set "_vl="
    for /l %%i in (0,1,9) do if not "!_vb:~%%i,1!"=="" set "_vl=!_vl!,!_vb:~%%i,1!"
    set "_vk=!_vk! [!_vl:~1!]?"
)
rem Pont, majd visszatorles - kulonben a set /p levagja a sor eleji szokozoket
if not defined _vbs for /f %%b in ('"prompt $H & for %%c in (1) do rem"') do set "_vbs=%%b"
<nul set /p "=.!_vbs!!_vk!"
if "%VALASZ_SORBOL%"=="1" goto :VALASZT_SOR
rem Az xcopy /W egy billentyut var, csendben. A sora: a sajat szovege + a leutott billentyu.
rem A szoveget egyszer, billentyu nelkul kerjuk le - igy az Enter es a hasonlok kiszurhetok.
if not defined _vszoveg for /f "delims=" %%m in ('xcopy /L /W "%ComSpec%" "%ComSpec%" 2^>nul ^<nul') do if not defined _vszoveg set "_vszoveg=%%m"
if not defined _vszoveg goto :VALASZT_SOR

:VALASZT_BILL
set "_vs="
for /f "delims=" %%k in ('xcopy /L /W "%ComSpec%" "%ComSpec%" 2^>nul') do if not defined _vs set "_vs=%%k"
if not defined _vs goto :VALASZT_SOR
if "!_vs!"=="!_vszoveg!" goto :VALASZT_BILL
set "_vc=!_vs:~-1!"
call :VALASZT_KERES
if "!_vn!"=="0" goto :VALASZT_BILL
goto :VALASZT_VEGE

:VALASZT_SOR
set "_vc="
set /p "_vc="
if not defined _vc (
    if "%VALASZ_SORBOL%"=="1" (
        echo.
        exit /b 255
    )
    goto :VALASZT_SOR
)
set "_vc=!_vc:~0,1!"
call :VALASZT_KERES
if "!_vn!"=="0" goto :VALASZT_SOR

:VALASZT_VEGE
set /a _vi=_vn-1
for %%i in (!_vi!) do echo !_vb:~%%i,1!
exit /b !_vn!

:VALASZT_KERES
rem _vc betu helye a _vb-ben, 1-tol - 0, ha nincs benne
set "_vn=0"
for /l %%i in (0,1,9) do if "!_vn!"=="0" if not "!_vb:~%%i,1!"=="" if /I "!_vb:~%%i,1!"=="!_vc!" set /a "_vn=%%i+1"
goto :eof

:IDO
rem %1 = kimeneti valtozo, masodpercben az ejfel ota
set "_t=%time: =0%"
for /f "tokens=1-3 delims=:.," %%a in ("%_t%") do set /a "%~1=(1%%a-100)*3600+(1%%b-100)*60+(1%%c-100)"
goto :eof

:SZINEK_BEALLIT
rem Szines kiiras Windows 10 1511 vagy ujabb eseten, kulonben sima szoveg
set "C_0="
set "C_ZOLD="
set "C_PIROS="
set "C_SARGA="
set "C_KEK="
set "C_FEHER="
set "C_SZURKE="
set "C_ZOLD_HATTER="
set "C_PIROS_HATTER="
set "_ver="
set "V_MAJ="
set "V_BLD="
for /f "tokens=2 delims=[]" %%v in ('ver') do set "_ver=%%v"
if not defined _ver goto :eof
for /f "tokens=2-4 delims=. " %%a in ("%_ver%") do (
    set "V_MAJ=%%a"
    set "V_BLD=%%c"
)
if not defined V_BLD goto :eof
if %V_MAJ% LSS 10 goto :eof
if %V_BLD% LSS 10586 goto :eof
set "ESC="
for /f %%e in ('echo prompt $E ^| cmd') do set "ESC=%%e"
if not defined ESC goto :eof
set "C_0=%ESC%[0m"
set "C_ZOLD=%ESC%[92m"
set "C_PIROS=%ESC%[91m"
set "C_SARGA=%ESC%[93m"
set "C_KEK=%ESC%[96m"
set "C_FEHER=%ESC%[97m"
set "C_SZURKE=%ESC%[90m"
set "C_ZOLD_HATTER=%ESC%[42;30m"
set "C_PIROS_HATTER=%ESC%[41;97m"
goto :eof
