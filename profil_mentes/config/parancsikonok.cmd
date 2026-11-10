rem ==========================================================
rem  Office-parancsikonok az asztalon - visszaallitaskor, automatikusan
rem
rem  Visszaallitaskor kikerulnek az ALAP programok, es minden, aminek a regi gep
rem  asztalan volt ikonja - de csak ha az uj gepen telepitve van. A nem letezo celra
rem  mutato (pl. regi Office 2016-os) ikonok torlodnek, helyettuk jo kerul ki.
rem  Ha minden rendben van, a lepes meg sem jelenik.
rem
rem  Uj program: egy uj %IKON_APP% sor.
rem    1. Nev     - ez lesz a parancsikon neve az asztalon
rem    2. Exe     - a program fajlja; a helyet a Windows App Paths bejegyzesebol veszi
rem                 TEAMS: az uj (aruhazas) vagy a klasszikus Teams
rem    3. ALAP    - mindig kell, ha telepitve van; ures: csak ha a regi gepen kint volt
rem    4-tol      - mas nevek, amiken a regi ikon szerepelhet (pl. angolul)
rem ==========================================================

rem         Nev                        Exe             Alap   Mas nevek
%IKON_APP%  "Word"                     "WINWORD.EXE"   ALAP
%IKON_APP%  "Excel"                    "EXCEL.EXE"     ALAP
%IKON_APP%  "Outlook"                  "OUTLOOK.EXE"   ALAP
%IKON_APP%  "PowerPoint"               "POWERPNT.EXE"  ALAP
%IKON_APP%  "Microsoft Teams"          "TEAMS"         ALAP   "Teams"
%IKON_APP%  "Skype Vállalati verzió"   "lync.exe"      ALAP   "Skype for Business" "Lync"
%IKON_APP%  "OneNote"                  "ONENOTE.EXE"   ""
%IKON_APP%  "Access"                   "MSACCESS.EXE"  ""
%IKON_APP%  "Publisher"                "MSPUB.EXE"     ""
%IKON_APP%  "Visio"                    "VISIO.EXE"     ""
%IKON_APP%  "Project"                  "WINPROJ.EXE"   ""
