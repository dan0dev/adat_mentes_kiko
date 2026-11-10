rem ==========================================================
rem  A mentendo es visszaallitando tetelek - ebben a sorrendben futnak
rem
rem  Uj tetel: egy uj %TETEL% sor. A mentes es a visszaallitas is
rem  automatikusan viszi, a lepesszam es a lista is magatol frissul.
rem
rem  Oszlopok:
rem    1. Tipus     - lib\tipusok\ alatti fajl neve: MAPPA, MINTA, FAJL, BONGESZO
rem    2. Nev       - ez latszik a kepernyon, a naploban es az osszegzesben,
rem                   legfeljebb 26 karakter, ekezetesen
rem    3. Forras    - a hely a felhasznalo profiljaban
rem    4. Mappa     - almappa a mentesen belul
rem    5-6. Tipusonkent:
rem         MAPPA     jelzok, egyutt is: P = folyamatjelzo, J = gyorsabb masolas nagy fajloknal,
rem                   A = atugorhato: masolas kozben a K billentyuvel kihagyhato
rem         MINTA     fajlminta, pl. *.acl - a mappabol csak ezek, almappak nelkul
rem         FAJL      fajlnev, utana mi tortenjen visszaallitas utan, hogy a Windows betoltse:
rem                   EXPLORER = Fajlkezelo ujrainditas, STARTMENU = Start menu ujrainditas
rem         BONGESZO  bongeszo neve, utana a mentendo fajlok listajat tartalmazo valtozo
rem ==========================================================

rem Bongeszonkent mentett fajlok, profilonkent. A Local State nem kerul at,
rem mert abban van a gephez kotott titkositokulcs - csak a profillista.
rem Chrome: konyvjelzok, elozmenyek, beallitasok, a konyvjelzok ikonjai (Favicons), az uj lap
rem csempei (Top Sites), a cimsor javaslatai (Shortcuts), a sajat helyesirasi szavak
set CHROME_FAJLOK=Bookmarks History "History Provider Cache" Preferences Favicons "Top Sites" Shortcuts "Custom Dictionary.txt"
set EDGE_FAJLOK=Bookmarks

rem     Tipus     Nev                           Forras                                                                         Mappa          Parameterek
%TETEL% MAPPA     "Outlook-aláírások"           "%APPDATA%\Microsoft\Signatures"                                              Signatures
%TETEL% MAPPA     "Office-sablonok"             "%APPDATA%\Microsoft\Templates"                                               Templates
%TETEL% MAPPA     "Office egyéni szótárai"      "%APPDATA%\Microsoft\UProof"                                                  UProof
%TETEL% MINTA     "Office automatikus javítás"  "%APPDATA%\Microsoft\Office"                                                OfficeAutoJavitas  *.acl
%TETEL% MAPPA     "Word-gyorsrészek"            "%APPDATA%\Microsoft\Document Building Blocks"                              BuildingBlocks
%TETEL% MINTA     "Office menüszalag"           "%LOCALAPPDATA%\Microsoft\Office"                                           OfficeUI       *.officeUI
%TETEL% MAPPA     "Outlook-levélpapírok"        "%APPDATA%\Microsoft\Stationery"                                            Stationery
%TETEL% MAPPA     "Excel XLSTART mappa"         "%APPDATA%\Microsoft\Excel\XLSTART"                                           XLSTART
%TETEL% MAPPA     "Indítópult mappa"            "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"                     Startup
%TETEL% BONGESZO  "Chrome-profilok"             "%LOCALAPPDATA%\Google\Chrome\User Data"                                      Chrome_mentes  Chrome  CHROME_FAJLOK
%TETEL% BONGESZO  "Edge-kedvencek"              "%LOCALAPPDATA%\Microsoft\Edge\User Data"                                     Edge_mentes    Edge    EDGE_FAJLOK
%TETEL% MAPPA     "Teams-hátterek"              "%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"  TeamsHatterek
%TETEL% MAPPA     "Kedvencek mappa"             "%USERPROFILE%\Favorites"                                                     Favorites
%TETEL% MAPPA     "Sticky Notes-jegyzetek"      "%LOCALAPPDATA%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"  StickyNotes
%TETEL% FAJL      "Fájlkezelő – Gyorselérés"    "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations"                    Gyorseleres    f01b4d95cf55d32a.automaticDestinations-ms  EXPLORER
%TETEL% FAJL      "Start menü rögzítései"       "%LOCALAPPDATA%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"  StartMenu  start2.bin  STARTMENU
%TETEL% MAPPA     "C:\TEMP mappa"               "%C_TEMP_FORRAS%"                                                              C_TEMP         PJA
