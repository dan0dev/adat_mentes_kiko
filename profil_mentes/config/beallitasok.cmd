rem ==========================================================
rem  Altalanos beallitasok
rem  A mentendo tetelek listaja kulon fajlban van: tetelek.cmd
rem ==========================================================

rem Mentes mappa neve a kulso meghajto gyokereben
set "MAPPA_NEV=Mentes"

rem Ennyi MB tartalekot var el a helyellenorzes a becsult meret folott
set /a RAHAGYAS_MB=300

rem A PST mappa: a mentes ezt viszi at, az Outlook lista ehhez viszonyit
set "SRC_PST=%USERPROFILE%\PST"

rem Tanusitvany tarolok (certmgr.msc - Aktualis felhasznalo), szokozzel elvalasztva:
rem My = Szemelyes, AddressBook = Masok. A kulcsosak jelszoval vedett .pfx-be kerulnek.
set "TAN_TAROLOK=My AddressBook"

rem Ezek a programok zarolhatjak a fajlokat, mentes es exportalas elott ellenorizzuk
set "FIGYELT_PROGRAMOK=chrome.exe msedge.exe outlook.exe winword.exe excel.exe Microsoft.Notes.exe"
rem Ezek a hatterben is futnak, ezert bezaraskor kenyszerrel zarjuk oket
set "KENYSZER_BEZARAS=msedge.exe Microsoft.Notes.exe"


rem Office parancsikonok forrasa, es az MSI-s Office parancsikonjainak helye
set "PD_START=%ProgramData%\Microsoft\Windows\Start Menu\Programs"
set "WIN_INST=%WINDIR:~2%\Installer\"

rem BitLocker / MBAM kliens helye - mindig a 64 bites Program Files
if defined ProgramW6432 (set "PF64=%ProgramW6432%") else (set "PF64=%ProgramFiles%")
set "MBAM_DIR=%PF64%\Microsoft\MDOP MBAM"

rem Az alapertelmezett alkalmazasok beallitofajlja es a hazirend kulcsa
set "AA_DIR=%ProgramData%\EszkozcsereScript"
set "AA_XML=%AA_DIR%\alapertelmezett_alkalmazasok.xml"
set "AA_KULCS=HKLM\SOFTWARE\Policies\Microsoft\Windows\System"
