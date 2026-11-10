rem Teszt beallitasok - a profil_mentes\segedlet.bat a PM_TESZT_KONFIG valtozon keresztul hivja
rem a config\beallitasok.cmd utan. Igy a futo programok kerdese nem jon elo.
set "FIGYELT_PROGRAMOK=pm_nincs_ilyen.exe"
set "KENYSZER_BEZARAS="
rem A C:\TEMP helyett a hamis profil egy mappaja - a valodi C:\TEMP-hez a teszt nem nyul
set "C_TEMP_FORRAS=%USERPROFILE%\_C_TEMP"
rem Az asztal, a kozos asztal: a hamis profilban - a valodi asztali ikonokhoz a teszt nem nyul
set "PM_TESZT_DESK=%USERPROFILE%\Desktop"
set "PM_TESZT_KOZOS_ASZTAL=%USERPROFILE%\_KozosAsztal"
rem A Fajlkezelot es a Start menut a teszt nem inditja ujra, rendszergazdai ablakot nem nyit
set "PM_TESZT_NE_INDITS_UJRA=1"
set "PM_TESZT_NINCS_EMELES=1"
