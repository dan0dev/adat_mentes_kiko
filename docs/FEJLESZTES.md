# Eszközcsere segédlet – fejlesztői leírás

**Verzió: 1.0** · **Készítette: Kakuk Dániel**

A felhasználói leírás: [`profil_mentes\README.md`](../profil_mentes/README.md). Ez a fájl a bővítéshez és a
karbantartáshoz kell, a külső meghajtóra nem kerül.

## Felépítés

```
Eszkozcsere_segedlet.bat     indító a profil_mentes mellett – sosem változik, csak elindítja a segedlet.bat-ot
kiadas.ps1                   új verzió kiadása a GitHubra
profil_mentes\
segedlet.bat               belépési pont: környezet, menü, a modul indítása, összegzés
verzio.txt                 a verzió – a kiadas.ps1 írja, a képernyőn és a címsorban látszik
config\                    ITT BŐVÍTS – listák és beállítások, kód nélkül
  beallitasok.cmd            mappanév, tartalék hely, figyelt programok, MBAM helye...
  tetelek.cmd                a mentendő tételek – egy sor = egy tétel
  parancsikonok.cmd          az asztali Office-parancsikonok listája
modulok\                   menüpontonként egy fájl: képernyők, kérdések, sorrend
lib\                       a munkát végző közös rutinok
  ui.cmd                     minden rajzolás: keretek, lépések, állapotjelek, sávok, kérdések
  kezdokepernyo.cmd          a kezdőképernyő és a menü
  masolas.cmd, robo_prog.cmd robocopy + ellenőrző másodfutás, folyamatjelző
  tetelek.cmd                a config\tetelek.cmd beolvasása és futtatása
  tipusok\                   tételtípusok: MAPPA, MINTA (fájlminta), FAJL, BONGESZO, REG (HKCU-kulcs)
  ellenorzes.cmd             felhasználó, meghajtó, futó programok, szabad hely
  talca.cmd                  a tálcára rögzített ikonok listája és képe – talca.txt, talca.png
  outlook.cmd, programlista.cmd, ikonok.cmd, bitlocker.cmd, chrome.cmd, frissites.cmd, eszkozok.cmd
  teendok.cmd                _TEENDOK.txt
  osszegzes.cmd              a végső összegzés minden menüponthoz
ps\                        a PowerShell részek, olvasható formában
```

## Bővítés

**Új mentendő tétel** – egy sor a `config\tetelek.cmd`-be, pl.:

```bat
%TETEL% MAPPA  "Letöltések"  "%USERPROFILE%\Downloads"  Downloads  P
```

A mentés és a visszaállítás is automatikusan viszi; a lista és a lépésszám magától frissül.
A név legfeljebb 26 karakter. A MAPPA tétel jelzői együtt is megadhatók: `P` = folyamatjelző, `J` = gyorsabb
másolás nagy fájloknál (robocopy `/J`), `A` = átugorható – pl. `PJA` a C:\TEMP.

**Átugorható tétel (`A`)** – másolás közben a **K** billentyű leállítja a robocopy-t (`ps\folyamat.ps1`), a
félbemaradt fájlt törli, és a tétel `[KIHAGYVA] átugorva` lesz, egy sorral a `_TEENDOK.txt`-ben. A
helyellenőrzés az első ilyen tételről külön fájlszámot és méretet ír ki. A félbemaradt fájlt az ideje
árulja el: a robocopy előre lefoglalja a teljes méretet, és csak a végén állítja az időt a forráséra.

**Új tételtípus** – új fájl a `lib\tipusok\` alá (pl. `REGISTRY.cmd`) a többi mintájára, `:MENT` és `:VISSZA`
címkével. Bemenet: `T_NEV`, `T_FORRAS`, `T_MAPPA`, `T_P1`, `T_P2`, mentésnél `CEL`, visszaállításnál `FORRAS`.
Az eredményt `%UI% :JELOL OK|HIBA|KIHAGYVA "üzenet" "részlet"` jelzi.

**Visszaállítás utáni teendő egy FAJL tételhez** – a sor 6. oszlopa egy név (pl. `EXPLORER`, `STARTMENU`),
a `lib\tipusok\FAJL.cmd`-ben pedig egy `:UTANA_<név>` címke. Sikeres visszaállítás után ez fut.

**Új Win+R eszköz** – egy `%ESZKOZ%` sor a `config\eszkozok.cmd`-be: billentyű, parancs, hivatalos név.

**Új Office-program az asztali ikonokhoz** – egy `%IKON_APP%` sor a `config\parancsikonok.cmd`-be: név, exe,
`ALAP` (mindig kell, ha telepítve van) vagy üres (csak ha a régi gépen kint volt), és a régi ikon más nevei.

**Új menüpont** – új fájl a `modulok\` alá, plusz: egy `%UI% :MENU` sor a `lib\kezdokepernyo.cmd`-ben,
egy betű a `segedlet.bat` `%UI% :VALASZT 1234567` sorában, és egy sor a menüpont → modul táblába.

## Szabályok a kódhoz

- **UTF-8 (BOM nélkül)** és **CRLF** sorvég. A `segedlet.bat` elején `chcp 65001` fut, a végén az
  eredeti kódlap visszaáll. A felhasználónak szóló szövegek ékezetesek, tegező hangnemben; a címkék,
  változónevek, fájlnevek és a megjegyzések ékezet nélküliek.
- A szövegekben nincs `!` (a késleltetett kiértékelés elnyelné). `( … )` blokkon belül a `)` jelet `^)`-ként kell
  írni, és `%~n` paramétert, aminek az értékében `)` lehet (pl. tételnév), nem szabad blokkba tenni – helyette
  `set` és `!változó!`.
- Egy sor sem hosszabb 76 oszlopnál (elérési utak kivételével). Az eredményüzenet legfeljebb 33 karakter, ami
  hosszabb, az a `:JELOL` harmadik paramétereként részletsor lesz.
- Minden rajzolás a `lib\ui.cmd`-ben van: `:CIM` fejléc, `:FEJLEC` lépés, `:JELOL` eredmény, `:RESZLET` szürke
  részletsor, `:SAV OK|HIBA|FIGYEL` sáv, `:ADAT` címke–érték, `:MENU`, `:SZAKASZ`, `:VONAL`, `:LABLEC NYITO|TELJES`,
  `:VALASZT` egybillentyűs kérdés, `:BEKER` szöveges kérdés, `:PAD`/`:VAG`/`:HOSSZ` segédek.
- Kérdéshez `%UI% :VALASZT IN "Kérdés?"`, ne `choice`: a `choice` minden rossz billentyűnél sípol, a `VALASZT`
  csendben vár tovább. Ugyanúgy errorlevelt ad (I = 1, N = 2). Automatikus futtatásnál `VALASZ_SORBOL=1` mellett
  soronként olvassa a válaszokat a bemenetről.
- A `lib\` fájlok első két sora (`@call %*` / `@exit /b`) teszi hívhatóvá a címkéiket kívülről. A rövidítéseket
  (`%UI%`, `%MASOLAS%`...) a `segedlet.bat` definiálja.
- A modul kilépési kódja: `0` végigment, teljes összegzés · `1` nem kérték, vissza a menübe · `2` nem indult el
  (az okát a modul kiírta) · `3` kilépés a programból · `4` egylépéses menüpont, rövid zárás · `5` nincs teendő
  (`NINCS_TEENDO`). A menüpont saját `setlocal`-ban fut: a végén minden számláló visszaáll, jön a menü.
- Billentyűre várás: `%UI% :BILLENTYU "szöveg"` – ne `pause`: automatikus futtatásnál az több választ elnyelne.
- Minden változó közös – nincs `setlocal` a modulokban és a `lib`-ben, mert az eredmények (`E_n`, `DB_OK`...) így
  jutnak vissza.
- PowerShell: `set "PS_FAJL=%PSDIR%\nev.ps1"`, utána `%PS_FUTTAT%`. Szövegként töltődik be, így a végrehajtási
  házirend nem tiltja le; a paraméterek környezeti változóban mennek, a kimenet UTF-8.
- Robocopy: a saját kimenetét a 852-es kódlapon írja, ezért a naplója hívásonként egy Unicode fájlba megy,
  amit a `type` UTF-8-ként fűz a naplóhoz; a folyamatjelző a `ps\folyamat.ps1`-en át jut a képernyőre.
- A kiírt fájlok (`_TEENDOK.txt`, összegzés, `outlook_lista.txt`, `talca.txt`) rövidek, kulcsszavasak: a fájl
  neve megmondja, mi az, a tartalom csak a lényeg.

## Tesztelés

A `tesztkornyezet\` mappa a segédletet hamis felhasználói profillal, hamis külső meghajtóval (`subst`)
futtatja, előre megírt válaszokkal, és az átiratokat ellenőrzi:

```powershell
tesztkornyezet\mind.ps1 -Ellenoriz -Kredit -Szoveg    # minden forgatókönyv, minden ellenőrzéssel
tesztkornyezet\kepernyok.ps1                          # a képernyőgaléria: minden ui.cmd rutin mintaadatokkal
tesztkornyezet\futtat.ps1 -Valaszok mentes            # egy forgatókönyv, az átirat a kimenet\ mappába kerül
tesztkornyezet\szovegjegyzek.ps1                      # minden szöveg egy táblában: docs\szovegjegyzek.md
```

Az ellenőrzés keresi: csipogást, hibás ékezetet, 76-nál hosszabb sort, cmd hibát, ékezet nélküli és magázó
szavakat, a „Készítette” sort, és az eredményeket az `alap\` mappában rögzített alapértékekhez hasonlítja.
A `PM_TESZT_KONFIG` környezeti változóval a tesztkörnyezet a `config\beallitasok.cmd` után felülírja a
beállításokat (pl. hogy ne kérdezzen rá a futó programokra). A tesztek a külső indítón át futnak.

## Kiadás

```powershell
.\kiadas.ps1 1.1 "Chrome telepítése, BitLocker, frissítés a GitHubról"
```

A `master` ágról, tiszta munkakönyvtárral: lefuttatja a teszteket, átírja a `profil_mentes\verzio.txt`-t és a
README verziószámát, commitol, címkéz (`v1.1`), pushol, a címkézett állapotból ZIP-et készít (az indító és a
`profil_mentes` mappa – tesztek, dokumentáció és git-előzmény nélkül), és feltölti GitHub-kiadásként. A segédlet
6. menüpontja (Segédlet frissítése) a legutolsó kiadást tölti le, és csak akkor frissít, ha annak nagyobb a verziója.

A fejlesztés közben a `verzio.txt` nem változik – több változtatás is mehet egy kiadásba.
Próbakiadás: `-Proba` – nem lesz „legutolsó”, a segédlet csak `FR_KIADAS=v…` mellett tölti le.
