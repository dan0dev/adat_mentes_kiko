@call %*
@exit /b

rem ==========================================================
rem  Alapertelmezett alkalmazasok - beallitas es ellenorzes
rem  A programok es fajltipusok listaja: config\alapertelmezett_alk.cmd
rem  Hivas: %ALAPALK% :BEALLIT  vagy  %ALAPALK% :ELLENORIZ
rem ==========================================================

:BEALLIT
rem Beallitofajl a Windows sajat formatumaban, es a hozza tartozo rendszerhazirend:
rem HKLM\SOFTWARE\Policies\Microsoft\Windows\System - DefaultAssociationsConfiguration
set "AA_OK=0"
set /a AA_DB=0, AA_PDB=0
set "AA_VAN="
set "AA_NINCS="

rem 0. A Windows ezt a hazirendet csak tartomanyhoz csatlakoztatott gepen alkalmazza
set "AA_TARTOMANY="
for /f %%d in ('powershell -NoProfile -NonInteractive -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; (Get-CimInstance Win32_ComputerSystem).PartOfDomain" 2^>nul') do set "AA_TARTOMANY=%%d"
if /I "!AA_TARTOMANY!"=="False" (
    %UI% :JELOL HIBA "a gép nincs tartományban" "A Windows ezt a beállítást csak tartományi gépen alkalmazza."
    goto :eof
)
if not defined AA_TARTOMANY %UI% :RESZLET "a tartománytagság nem ellenőrizhető, folytatom"
if /I "!AA_TARTOMANY!"=="True" %UI% :RESZLET "a gép tartományban van"

rem 1. Van-e mar ceges beallitas
set "AA_REGI="
for /f "tokens=2,*" %%a in ('reg query "%AA_KULCS%" /v DefaultAssociationsConfiguration 2^>nul ^| find "REG_"') do set "AA_REGI=%%b"
if defined AA_REGI if /I not "!AA_REGI!"=="!AA_XML!" (
    echo            !C_SARGA!Már van ilyen beállítás ezen a gépen:!C_0!
    echo            !C_SARGA!!AA_REGI!!C_0!
    echo            !C_SARGA!Ez valószínűleg céges csoportházirend – ha felülírom, a következő!C_0!
    echo            !C_SARGA!frissítéskor visszaállhat.!C_0!
    %UI% :VALASZT IN "Felülírjam?"
    if errorlevel 2 (
        %UI% :JELOL KIHAGYVA "céges beállítás, nem írtam felül" "!AA_REGI!"
        goto :eof
    )
)

rem 2. A telepitett programok azonositoinak felderitese - a config ezekre hivatkozik
set "PDF_ID="
for %%i in (Acrobat.Document.DC AcroExch.Document.DC AcroExch.Document.11 AcroExch.Document.7) do if not defined PDF_ID reg query "HKCR\%%i\shell\open\command" >nul 2>&1 && set "PDF_ID=%%i"
set "CHROME_ID="
reg query "HKCR\ChromeHTML\shell\open\command" >nul 2>&1 && set "CHROME_ID=ChromeHTML"
if not defined CHROME_ID for /f "tokens=2 delims=\" %%k in ('reg query HKCR /f ChromeHTML /k 2^>nul ^| find /i "ChromeHTML"') do if not defined CHROME_ID reg query "HKCR\%%k\shell\open\command" >nul 2>&1 && set "CHROME_ID=%%k"
>>"%LOG%" echo        PDF azonosító: %PDF_ID%   Chrome azonosító: %CHROME_ID%

rem 3. A beallitofajl megirasa - csak a tenylegesen telepitett programokkal
mkdir "%AA_DIR%" 2>nul
(>"%AA_XML%" echo ^<?xml version="1.0" encoding="UTF-8"?^>) 2>nul
if not exist "%AA_XML%" (
    %UI% :JELOL HIBA "a beállítófájl nem írható" "%AA_XML%"
    goto :eof
)
>>"%AA_XML%" echo ^<DefaultAssociations^>
set "AA_APP="
set AA_PROGRAM=call "%LIB%\alapalk.cmd" :PROGRAM
set AA_TIPUS=call "%LIB%\alapalk.cmd" :TIPUS
set "AA_ELLENORIZ=rem"
call "%CONF%\alapertelmezett_alk.cmd"
if defined AA_APP call :PROGRAM_VEGE
>>"%AA_XML%" echo ^</DefaultAssociations^>
>>"%LOG%" type "%AA_XML%"

if %AA_DB%==0 (
    %UI% :JELOL HIBA "egyik program sincs telepítve" "Nincs mit beállítani."
    goto :eof
)

rem 4. A hazirend rogzitese es visszaolvasasa
reg add "%AA_KULCS%" /v DefaultAssociationsConfiguration /t REG_SZ /d "%AA_XML%" /f >>"%LOG%" 2>&1
set "AA_UJ="
for /f "tokens=2,*" %%a in ('reg query "%AA_KULCS%" /v DefaultAssociationsConfiguration 2^>nul ^| find "REG_"') do set "AA_UJ=%%b"
if /I not "!AA_UJ!"=="!AA_XML!" (
    %UI% :JELOL HIBA "a házirend nem írható" "Rendszergazdai jog kell."
    goto :eof
)
set "AA_OK=1"
%UI% :JELOL OK "%AA_PDB% program beállítva" "!AA_VAN! – ki- és bejelentkezés után él."
goto :eof

:PROGRAM
rem %AA_PROGRAM% sor: %1 = programcsoport neve. Az elozo csoportot lezarja.
if defined AA_APP call :PROGRAM_VEGE
set "AA_APP=%~1"
set /a AA_T=0
goto :eof

:PROGRAM_VEGE
if %AA_T% GTR 0 (
    set /a AA_PDB+=1
    if defined AA_VAN (set "AA_VAN=!AA_VAN!, !AA_APP!") else (set "AA_VAN=!AA_APP!")
    %UI% :RESZLET "!AA_APP!: %AA_T% fájltípus"
) else (
    if defined AA_NINCS (set "AA_NINCS=!AA_NINCS!, !AA_APP!") else (set "AA_NINCS=!AA_APP!")
    echo            !C_SARGA!!AA_APP!: nincs telepítve, kihagyva!C_0!
)
goto :eof

:TIPUS
rem %AA_TIPUS% sor: %1 = kiterjesztes vagy protokoll, %2 = program azonosito, %3 = program neve
rem Csak akkor, ha a program tenyleg telepitve van: a megnyito parancs is letezik
if "%~2"=="" goto :eof
reg query "HKCR\%~2\shell\open\command" >nul 2>&1
if errorlevel 1 goto :eof
>>"%AA_XML%" echo   ^<Association Identifier="%~1" ProgId="%~2" ApplicationName="%~3" /^>
set /a AA_DB+=1, AA_T+=1
goto :eof

:ELLENORIZ
rem Csak olvas: a felhasznalo jelenlegi alapertelmezett programjai
set "AA_OK=0"
set "AA_ROSSZ="
set /a AA_DB_NEZ=0
set "AA_PROGRAM=rem"
set "AA_TIPUS=rem"
set AA_ELLENORIZ=call "%LIB%\alapalk.cmd" :NEZ
call "%CONF%\alapertelmezett_alk.cmd"
if defined AA_ROSSZ (
    %UI% :JELOL HIBA "nem mindenhol a kért program" "!AA_ROSSZ!"
) else (
    set "AA_OK=1"
    %UI% :JELOL OK "%AA_DB_NEZ% típus ellenőrizve" "Mindenhol a kért program az alapértelmezett."
)
goto :eof

:NEZ
rem %AA_ELLENORIZ% sor: %1 = megnevezes, %2 = tipus, %3 = U protokoll vagy F fajltipus, %4 = vart azonosito resz
set /a AA_DB_NEZ+=1
set "AA_AKT="
set "AA_FORRAS="
set "_k=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%~2"
if /I "%~3"=="U" set "_k=HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\%~2"
rem Ujabb Windows 11 a UserChoiceLatest kulcsot hasznalja, regebbi a UserChoice-t
for /f "tokens=2,*" %%a in ('reg query "%_k%\UserChoiceLatest" /v ProgId 2^>nul ^| find "REG_"') do set "AA_AKT=%%b"
if not defined AA_AKT for /f "tokens=2,*" %%a in ('reg query "%_k%\UserChoice" /v ProgId 2^>nul ^| find "REG_"') do set "AA_AKT=%%b"
if not defined AA_AKT if /I not "%~3"=="U" for /f "tokens=2,*" %%a in ('reg query "HKCR\%~2" /ve 2^>nul ^| find "REG_"') do set "AA_AKT=%%b"
if not defined AA_AKT goto :NEZ_TOVABB
reg query "%_k%\UserChoiceLatest" /v ProgId >nul 2>&1 && goto :NEZ_TOVABB
reg query "%_k%\UserChoice" /v ProgId >nul 2>&1 && goto :NEZ_TOVABB
set "AA_FORRAS= (rendszerszintű)"
:NEZ_TOVABB
set "_ok=0"
if defined AA_AKT (
    set "_x=!AA_AKT:%~4=!"
    if /I not "!_x!"=="!AA_AKT!" set "_ok=1"
)
if not defined AA_AKT set "AA_AKT=nincs beállítva"
>>"%LOG%" echo        %~1 – %~2: !AA_AKT!
if "%_ok%"=="1" (
    %UI% :RESZLET "%~1: rendben – !AA_AKT!!AA_FORRAS!"
) else (
    echo            !C_PIROS!%~1: nem a kért program – !AA_AKT!!C_0!
    if defined AA_ROSSZ (set "AA_ROSSZ=!AA_ROSSZ!, %~1") else (set "AA_ROSSZ=%~1")
)
goto :eof
