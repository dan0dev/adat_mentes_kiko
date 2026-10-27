@call %*
@exit /b

rem ==========================================================
rem  Kepernyo, lepesek es eredmenyek - minden rajzolas itt tortenik,
rem  a modulok csak a szoveget adjak.
rem  Hivas: %UI% :CIMKE parameterek
rem
rem  Elrendezes: 2 szokoz behuzas, a keretek es vonalak 70 oszlop szelesek,
rem  egy sor sem hosszabb 76 oszlopnal. Az allapotjelek mindig 10 karakteresek.
rem  A fajl UTF-8: a futas a 65001 kodlapon megy.
rem ==========================================================

:NYITO
rem A kezdokepernyo kerete: nev, verzio, egy soros leiras
set "_l=   ESZKÖZCSERE SEGÉDLET"
set "_r=Verzió: %VERZIO%  "
call :HOSSZ _r _rh
set /a _lh=68-_rh
call :PAD _l %_lh%
echo.
echo   !C_KEK!╔════════════════════════════════════════════════════════════════════╗!C_0!
echo   !C_KEK!║!C_0!                                                                    !C_KEK!║!C_0!
echo   !C_KEK!║!C_0!!C_FEHER!!_l!!C_0!!_r!!C_KEK!║!C_0!
echo   !C_KEK!║!C_0!   Felhasználói adatok mentése és visszaállítása eszközcseréhez     !C_KEK!║!C_0!
echo   !C_KEK!║!C_0!                                                                    !C_KEK!║!C_0!
echo   !C_KEK!╚════════════════════════════════════════════════════════════════════╝!C_0!
echo.
set "UI_BEHUZAS=  "
goto :eof

:CIM
rem %1 = a kepernyo cime - minden kepernyo teteje a kezdokepernyon kivul
echo.
echo   !C_FEHER!ESZKÖZCSERE SEGÉDLET!C_0!  ›  !C_FEHER!%~1!C_0!
echo   !C_KEK!══════════════════════════════════════════════════════════════════════!C_0!
echo.
set "UI_BEHUZAS=  "
goto :eof

:SZAKASZ
rem %1 = szakaszcim - vonal a cimmel, 70 oszlop
set "_s=── %~1 ──────────────────────────────────────────────────────────────────────"
set "_s=!_s:~0,70!"
echo   !C_KEK!!_s!!C_0!
goto :eof

:VONAL
echo   !C_KEK!──────────────────────────────────────────────────────────────────────!C_0!
goto :eof

:ADAT
rem %1 = cimke, %2 = ertek, %3 = SARGA: az ertek sargan
set "_c=%~1"
set "_e=%~2"
call :PAD _c 16
if /I "%~3"=="SARGA" (echo      !_c!!C_SARGA!!_e!!C_0!) else (echo      !_c!!C_FEHER!!_e!!C_0!)
goto :eof

:MENU
rem %1 = billentyu, %2 = menupont neve, %3 = rovid leiras
set "_m=%~2"
call :PAD _m 30
echo      !C_FEHER!%~1!C_0!   !_m!!C_SZURKE!%~3!C_0!
goto :eof

:LABLEC
rem %1 = NYITO: csak a keszito; TELJES: nev, verzio es keszito
call :VONAL
if /I "%~1"=="TELJES" (
    echo      !C_SZURKE!Eszközcsere segédlet %VERZIO%  ·  Készítette: %SZERZO%!C_0!
) else (
    echo      !C_SZURKE!Készítette: %SZERZO%!C_0!
)
goto :eof

:FEJLEC
rem Uj lepes kezdete: sorszam, ablakcim, naplo
set /a LEPES+=1
set "NEV_%LEPES%=%~1"
set "_n= %LEPES%"
set "_n=!_n:~-2!"
title [%LEPES%/%OSSZES%] %~1 – %MOD_NEV%
echo.
echo   !C_KEK![!_n!/%OSSZES%]!C_0!  !C_FEHER!%~1!C_0!
set "UI_BEHUZAS=           "
>>"%LOG%" echo.
>>"%LOG%" echo [%time%] [%LEPES%/%OSSZES%] %~1
goto :eof

:RESZLET
rem %1 = reszletezo sor a lepes alatt, szurken - a naploba is
echo !UI_BEHUZAS!!C_SZURKE!%~1!C_0!
>>"%LOG%" echo        %~1
goto :eof

:JELOL
rem %1 = OK / HIBA / KIHAGYVA / NEMKERT, %2 = uzenet, %3 = reszlet, kulon sorban
set "E_%LEPES%=%~1"
set "M_%LEPES%=%~2"
set "D_%LEPES%=%~3"
if "%~1"=="OK" set /a DB_OK+=1
if "%~1"=="HIBA" set /a DB_HIBA+=1
if "%~1"=="KIHAGYVA" set /a DB_KIHAGY+=1
call :JEL "%~1"
echo            !_jel!  %~2
if not "%~3"=="" call :RESZLET "%~3"
>>"%LOG%" echo        Eredmény: %~1 – %~2
if not "%~3"=="" >>"%LOG%" echo        %~3
goto :eof

:JEL
rem %1 = allapot. Kimenet: _jel - a 10 karakteres, szines allapotjel
set "_jel=!C_SZURKE![   –    ]!C_0!"
if "%~1"=="OK" set "_jel=!C_ZOLD![   OK   ]!C_0!"
if "%~1"=="HIBA" set "_jel=!C_PIROS![  HIBA  ]!C_0!"
if "%~1"=="KIHAGYVA" set "_jel=!C_SARGA![KIHAGYVA]!C_0!"
goto :eof

:OSSZ_SOR
rem %1 = lepes sorszama - egy sor az osszegzesben, a kepernyon es a fajlban
set "_st=!E_%~1!"
set "_nv=!NEV_%~1!"
set "_ms=!M_%~1!"
set "_dt=!D_%~1!"
call :JEL "!_st!"
call :VAG _nv 26
call :PAD _nv 26
call :VAG _ms 33
echo     !_jel!  !_nv! !_ms!
if defined _dt (
    >>"%OSSZ_FAJL%" echo [!_st!] !NEV_%~1! – !M_%~1! – !_dt!
) else (
    >>"%OSSZ_FAJL%" echo [!_st!] !NEV_%~1! – !M_%~1!
)
goto :eof

:SAV
rem %1 = OK / HIBA / FIGYEL, %2 = szoveg. OK es HIBA: 70 oszlopos szines sav,
rem FIGYEL: sarga sor. Szinek nelkul sima szoveg.
set "_t=   %~2"
if /I "%~1"=="FIGYEL" (
    echo   !C_SARGA!!_t!!C_0!
    goto :eof
)
call :VAG _t 70
call :PAD _t 70
if /I "%~1"=="OK" (echo   !C_ZOLD_HATTER!!_t!!C_0!) else (echo   !C_PIROS_HATTER!!_t!!C_0!)
goto :eof

:BEKER
rem %1 = valtozo neve, %2 = kerdes - szabad szoveges valasz Enterrel, pl. meghajto betuje
set "%~1="
if not defined _vbs for /f %%b in ('"prompt $H & for %%c in (1) do rem"') do set "_vbs=%%b"
<nul set /p "=.!_vbs!!UI_BEHUZAS!› %~2 "
set /p "%~1="
rem Automatikus futtatasnal a valasz nem latszik - kiirjuk, hogy az atirat olvashato legyen.
rem Ha elfogytak a valaszok, 255-tel ter vissza, hogy a hivo ne kerdezzen a vegtelensegig.
if "%VALASZ_SORBOL%"=="1" (
    if not defined %~1 exit /b 255
    echo !%~1!
)
exit /b 0

:PAD
rem %1 = valtozo neve, %2 = hossz - szokozokkel feltolti, ha rovidebb
set "_p=!%~1!                                                                                "
set "%~1=!_p:~0,%~2!"
goto :eof

:VAG
rem %1 = valtozo neve, %2 = hossz - ha hosszabb, levagja, a vegen ... jellel
set "_v=!%~1!"
if "!_v:~%~2!"=="" goto :eof
set /a _vn=%~2-1
set "_v=!_v:~0,%_vn%!…"
set "%~1=!_v!"
goto :eof

:HOSSZ
rem %1 = valtozo neve, %2 = kimeneti valtozo - a szoveg hossza karakterben
set "_h=!%~1!"
set "%~2=0"
for /l %%i in (0,1,199) do if not "!_h:~%%i,1!"=="" set /a %~2=%%i+1
goto :eof

:MB_GB
rem %1 = MB erteket tartalmazo valtozo, %2 = kimeneti szoveg valtozo
set /a "_g=!%~1!/1024, _t=(!%~1! %% 1024)*10/1024"
set "%~2=!_g!,!_t! GB"
goto :eof

:VALASZT
rem Csendes valasztas a choice helyett - a choice minden rossz billentyunel sipol,
rem ez csak var tovabb. Egy billentyu, Enter nelkul, kis- es nagybetu is jo.
rem %1 = a lehetseges betuk, pl. IN, %2 = kerdes, %3 = N: ne irja utana az [I/N] reszt
rem A kerdes elott a behuzas es a › jel, utana a lehetosegek: › Indulhat? [I/N]
rem Kimenet: errorlevel = a valasztott betu sorszama, mint a choice-nal: I = 1, N = 2
rem VALASZ_SORBOL=1: a valaszt soronkent olvassa a bemenetrol - automatikus futtatashoz
set "_vb=%~1"
set "_vk=!UI_BEHUZAS!› %~2"
if /I not "%~3"=="N" (
    set "_vl="
    for /l %%i in (0,1,9) do if not "!_vb:~%%i,1!"=="" set "_vl=!_vl!/!_vb:~%%i,1!"
    set "_vk=!_vk! [!_vl:~1!]"
)
set "_vk=!_vk! "
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
