# Eszközcsere segédlet – fejlesztői leírás

**Verzió: 1.0** · **Készítette: Kakuk Dániel**

A felhasználói leírás: [`profil_mentes\README.md`](../profil_mentes/README.md). Ez a fájl a bővítéshez és a
karbantartáshoz kell, a külső meghajtóra nem kerül.

## Felépítés

```
Eszkozcsere_segedlet.bat   belépési pont: környezet, menü, a modul indítása, összegzés
config\                    ITT BŐVÍTS – listák és beállítások, kód nélkül
  beallitasok.cmd            mappanév, tartalék hely, figyelt programok, tanúsítványtárolók, MBAM helye...
  tetelek.cmd                a mentendő tételek – egy sor = egy tétel
  parancsikonok.cmd          az asztali Office-parancsikonok listája
  alapertelmezett_alk.cmd    fájltípusok és programok az 5. menühöz
modulok\                   menüpontonként egy fájl: képernyők, kérdések, sorrend
lib\                       a munkát végző közös rutinok
  ui.cmd                     minden rajzolás: keretek, lépések, állapotjelek, sávok, kérdések
  kezdokepernyo.cmd          a kezdőképernyő és a menü
  masolas.cmd, robo_prog.cmd robocopy + ellenőrző másodfutás, folyamatjelző
  tetelek.cmd                a config\tetelek.cmd beolvasása és futtatása
  tipusok\                   tételtípusok: MAPPA, FAJL, BONGESZO, TANUSITVANY
  ellenorzes.cmd             felhasználó, meghajtó, futó programok, szabad hely
  talca.cmd                  a tálcára rögzített ikonok listája – talca.txt
  outlook.cmd, programlista.cmd, ikonok.cmd, alapalk.cmd, laptop.cmd
  teendok.cmd                _TEENDOK.txt
  osszegzes.cmd              a végső összegzés minden menüponthoz
ps\                        a PowerShell részek, olvasható formában
```

## Bővítés

**Új mentendő tétel** – egy sor a `config\tetelek.cmd`-be, pl.:

```bat
%TETEL% MAPPA  "Letöltések"  "%USERPROFILE%\Downloads"  Downloads  P
```

A mentés, a próbafuttatás és a visszaállítás is automatikusan viszi; a lista és a lépésszám magától frissül.
A név legfeljebb 26 karakter. A MAPPA tétel jelzői együtt is megadhatók: `P` = folyamatjelző, `J` = gyorsabb
másolás nagy fájloknál (robocopy `/J`), pl. `PJ` – így megy a PST-mappa és a C:\TEMP.

**Új tételtípus** – új fájl a `lib\tipusok\` alá (pl. `REGISTRY.cmd`) a többi mintájára, `:MENT` és `:VISSZA`
címkével. Bemenet: `T_NEV`, `T_FORRAS`, `T_MAPPA`, `T_P1`, `T_P2`, mentésnél `CEL`, visszaállításnál `FORRAS`.
Az eredményt `%UI% :JELOL OK|HIBA|KIHAGYVA "üzenet" "részlet"` jelzi.

**Visszaállítás utáni teendő egy FAJL tételhez** – a sor 6. oszlopa egy név (pl. `EXPLORER`, `STARTMENU`),
a `lib\tipusok\FAJL.cmd`-ben pedig egy `:UTANA_<név>` címke. Sikeres visszaállítás után ez fut.

**Tanúsítványtárolók** – `TAN_TAROLOK` a `config\beallitasok.cmd`-ben (alapból `My AddressBook`).

**Új program az asztali parancsikonokhoz** – egy `%IKON_APP%` sor a `config\parancsikonok.cmd`-be.

**Új alapértelmezett fájltípus** – `%AA_TIPUS%` sor (és ha kell, `%AA_ELLENORIZ%` sor) a
`config\alapertelmezett_alk.cmd`-be.

**Új menüpont** – új fájl a `modulok\` alá, plusz: egy `%UI% :MENU` sor a `lib\kezdokepernyo.cmd`-ben,
egy betű az `Eszkozcsere_segedlet.bat` `%UI% :VALASZT 12345` sorában, és egy sor a menüpont → modul táblába.

## Szabályok a kódhoz

- **UTF-8 (BOM nélkül)** és **CRLF** sorvég. Az `Eszkozcsere_segedlet.bat` elején `chcp 65001` fut, a végén az
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
  (`%UI%`, `%MASOLAS%`...) az `Eszkozcsere_segedlet.bat` definiálja.
- A modul `exit /b 0`-val tér vissza, ha végigment (jön az összegzés), `exit /b 1`-gyel, ha megszakították.
- Minden változó közös – nincs `setlocal` a modulokban és a `lib`-ben, mert az eredmények (`E_n`, `DB_OK`...) így
  jutnak vissza.
- PowerShell: `set "PS_FAJL=%PSDIR%\nev.ps1"`, utána `%PS_FUTTAT%`. Szövegként töltődik be, így a végrehajtási
  házirend nem tiltja le; a paraméterek környezeti változóban mennek, a kimenet UTF-8.
- Robocopy: a saját kimenetét a 852-es kódlapon írja, ezért a naplója hívásonként egy Unicode fájlba megy,
  amit a `type` UTF-8-ként fűz a naplóhoz; a folyamatjelző a `ps\folyamat.ps1`-en át jut a képernyőre.
- A kiírt fájlok (`_TEENDOK.txt`, összegzés, `outlook_lista.txt`, `talca.txt`) rövidek, kulcsszavasak: a fájl
  neve megmondja, mi az, a tartalom csak a lényeg.

## Tesztelés

A `tesztkornyezet\` mappa a segédletet hamis felhasználói profillal, hamis külső meghajtóval (`subst`) és
külön teszt-tanúsítványtárolóval (`PmTeszt`) futtatja, előre megírt válaszokkal, és az átiratokat ellenőrzi:

```powershell
tesztkornyezet\mind.ps1 -Ellenoriz -Kredit -Szoveg    # minden forgatókönyv, minden ellenőrzéssel
tesztkornyezet\kepernyok.ps1                          # a képernyőgaléria: minden ui.cmd rutin mintaadatokkal
tesztkornyezet\futtat.ps1 -Valaszok mentes            # egy forgatókönyv, az átirat a kimenet\ mappába kerül
tesztkornyezet\szovegjegyzek.ps1                      # minden szöveg egy táblában: docs\szovegjegyzek.md
```

Az ellenőrzés keresi: csipogást, hibás ékezetet, 76-nál hosszabb sort, cmd hibát, ékezet nélküli és magázó
szavakat, a "Készítette" sort, és az eredményeket az `alap\` mappában rögzített alapértékekhez hasonlítja.
A `PM_TESZT_KONFIG` környezeti változóval a tesztkörnyezet a `config\beallitasok.cmd` után felülírja a
beállításokat (pl. hogy ne kérdezzen rá a futó programokra, és a `PmTeszt` tárolót használja).
