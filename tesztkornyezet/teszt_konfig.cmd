rem Teszt beallitasok - az Eszkozcsere_segedlet.bat a PM_TESZT_KONFIG valtozon keresztul hivja
rem a config\beallitasok.cmd utan. Igy a futo programok kerdese nem jon elo,
rem es az atnezendo mappak merese gyorsan lezarul.
set "FIGYELT_PROGRAMOK=pm_nincs_ilyen.exe"
set "KENYSZER_BEZARAS="
set "ATNEZ_IDOKORLAT_MP=5"
rem Tanusitvanyok: csak a kulon PmTeszt tarolo - a valodi Szemelyes tarolohoz a teszt nem nyul.
rem A jelszot nem kerdezi, ezt hasznalja.
set "TAN_TAROLOK=PmTeszt"
set "PM_TESZT_JELSZO=Teszt-1234"
