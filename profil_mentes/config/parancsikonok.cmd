rem ==========================================================
rem  Office parancsikonok az asztalon - exportalaskor, ha kerik
rem
rem  Uj program: egy uj %IKON_APP% sor.
rem    1. Nev       - ez latszik a kepernyon
rem    2. Exe       - erre kell mutatnia a jo parancsikonnak
rem    3-tol        - a parancsikon lehetseges nevei, * helyettesithet
rem  Az elso talalat a Start menuben lesz a minta, ezt rakja ki az asztalra.
rem ==========================================================

rem         Nev           Exe              Parancsikon nevek
%IKON_APP%  "Outlook"     "OUTLOOK.EXE"    "Outlook.lnk" "Outlook 20*.lnk" "Microsoft Outlook*.lnk" "Microsoft Office Outlook*.lnk"
%IKON_APP%  "Word"        "WINWORD.EXE"    "Word.lnk" "Word 20*.lnk" "Microsoft Word*.lnk" "Microsoft Office Word*.lnk"
%IKON_APP%  "Excel"       "EXCEL.EXE"      "Excel.lnk" "Excel 20*.lnk" "Microsoft Excel*.lnk" "Microsoft Office Excel*.lnk"
%IKON_APP%  "PowerPoint"  "POWERPNT.EXE"   "PowerPoint.lnk" "PowerPoint 20*.lnk" "Microsoft PowerPoint*.lnk" "Microsoft Office PowerPoint*.lnk"
%IKON_APP%  "Skype"       "lync.exe"       "Skype for Business*.lnk" "Skype V*.lnk" "Microsoft Lync*.lnk" "Lync 20*.lnk"
