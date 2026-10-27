rem ==========================================================
rem  Alapertelmezett alkalmazasok - 5. menupont
rem
rem  Beallitaskor - rendszergazdakent - csak a PROGRAM es TIPUS sorok
rem  szamitanak, ellenorzeskor - felhasznalokent - csak az ELLENORIZ sorok.
rem
rem  %AA_PROGRAM%  "nev"                      uj programcsoport kezdete
rem  %AA_TIPUS%    "kiterjesztes vagy protokoll" "ProgId" "program neve"
rem                csak akkor kerul a beallitofajlba, ha a ProgId telepitve van
rem  %AA_ELLENORIZ% "megnevezes" "tipus" F/U "a ProgId vart resze"
rem                F = fajltipus, U = protokoll, pl. http
rem
rem  A PDF_ID es a CHROME_ID a gepen talalt azonosito, lib\alapalk.cmd keresi meg.
rem ==========================================================

%AA_PROGRAM% "Word"
%AA_TIPUS%   ".docx"  "Word.Document.12"                  "Microsoft Word"
%AA_TIPUS%   ".doc"   "Word.Document.8"                   "Microsoft Word"
%AA_TIPUS%   ".docm"  "Word.DocumentMacroEnabled.12"      "Microsoft Word"
%AA_TIPUS%   ".dotx"  "Word.Template.12"                  "Microsoft Word"
%AA_TIPUS%   ".dot"   "Word.Template.8"                   "Microsoft Word"
%AA_TIPUS%   ".rtf"   "Word.RTF.8"                        "Microsoft Word"

%AA_PROGRAM% "Excel"
%AA_TIPUS%   ".xlsx"  "Excel.Sheet.12"                    "Microsoft Excel"
%AA_TIPUS%   ".xls"   "Excel.Sheet.8"                     "Microsoft Excel"
%AA_TIPUS%   ".xlsm"  "Excel.SheetMacroEnabled.12"        "Microsoft Excel"
%AA_TIPUS%   ".xlsb"  "Excel.SheetBinaryMacroEnabled.12"  "Microsoft Excel"
%AA_TIPUS%   ".csv"   "Excel.CSV"                         "Microsoft Excel"

%AA_PROGRAM% "PowerPoint"
%AA_TIPUS%   ".pptx"  "PowerPoint.Show.12"                "Microsoft PowerPoint"
%AA_TIPUS%   ".ppt"   "PowerPoint.Show.8"                 "Microsoft PowerPoint"
%AA_TIPUS%   ".pptm"  "PowerPoint.ShowMacroEnabled.12"    "Microsoft PowerPoint"
%AA_TIPUS%   ".ppsx"  "PowerPoint.SlideShow.12"           "Microsoft PowerPoint"
%AA_TIPUS%   ".pps"   "PowerPoint.SlideShow.8"            "Microsoft PowerPoint"

%AA_PROGRAM% "PDF – Acrobat Reader"
%AA_TIPUS%   ".pdf"   "%PDF_ID%"                          "Adobe Acrobat Reader"

%AA_PROGRAM% "Chrome"
%AA_TIPUS%   "http"   "%CHROME_ID%"                       "Google Chrome"
%AA_TIPUS%   "https"  "%CHROME_ID%"                       "Google Chrome"
%AA_TIPUS%   ".htm"   "%CHROME_ID%"                       "Google Chrome"
%AA_TIPUS%   ".html"  "%CHROME_ID%"                       "Google Chrome"

rem             Megnevezes           Tipus    F/U  Vart ProgId resz
%AA_ELLENORIZ%  "Word"               ".docx"  F    "Word."
%AA_ELLENORIZ%  "Excel"              ".xlsx"  F    "Excel."
%AA_ELLENORIZ%  "PowerPoint"         ".pptx"  F    "PowerPoint."
%AA_ELLENORIZ%  "PDF"                ".pdf"   F    "Acro"
%AA_ELLENORIZ%  "Böngésző – http"    "http"   U    "ChromeHTML"
%AA_ELLENORIZ%  "Böngésző – https"   "https"  U    "ChromeHTML"
%AA_ELLENORIZ%  "Weboldal – .html"   ".html"  F    "ChromeHTML"
