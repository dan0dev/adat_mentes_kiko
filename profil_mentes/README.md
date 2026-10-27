# Profil mentés – eszközcsere segédlet

Indítás: **`profil_mentes.bat`** dupla kattintással. A teljes mappát kell vinni (pl. a külső meghajtóra), a fájlok együtt működnek.

| Menü | Mit csinál | Modul |
|---|---|---|
| 1 | Adatok mentése a régi gépen a külső meghajtóra | `modulok\mentes.cmd` |
| 2 | Adatok exportálása – visszaállítás az új gépen | `modulok\export.cmd` |
| 3 | Laptop: fedél lehajtása, BitLocker (MBAM) | `modulok\laptop.cmd` |
| 4 | Teszt futtatás – a mentés próbája, nem másol semmit | `modulok\mentes.cmd` |
| 5 | Alapértelmezett alkalmazások – admin: beállít, felhasználó: ellenőriz | `modulok\alapalk.cmd` |

## Felépítés

```
profil_mentes.bat        belépési pont: környezet, menü, a modul indítása, összegzés
config\                  ITT BŐVÍTS – listák és beállítások, kód nélkül
  beallitasok.cmd          mappanév, tartalék hely, figyelt programok, MBAM helye...
  tetelek.cmd              a mentendő tételek – egy sor = egy tétel
  parancsikonok.cmd        az asztali Office parancsikonok listája
  alapertelmezett_alk.cmd  fájltípusok és programok az 5. menühöz
modulok\                 menüpontonként egy fájl: képernyők, kérdések, sorrend
lib\                     a munkát végző közös rutinok
  ui.cmd                   címsor, lépések, [OK]/[HIBA] jelölés, színek
  masolas.cmd              robocopy + ellenőrző másodfutás
  tetelek.cmd              a config\tetelek.cmd beolvasása és futtatása
  tipusok\                 tételtípusok: MAPPA, FAJL, BONGESZO
  ellenorzes.cmd           felhasználó, meghajtó, futó programok, szabad hely
  atnezendo.cmd            kézzel átnézendő mappák keresése (Letöltések, saját mappa...)
  talca.cmd                a tálcára rögzített ikonok listája – talca.txt
  outlook.cmd, programlista.cmd, ikonok.cmd, alapalk.cmd, laptop.cmd
  teendok.cmd              _LEFT-TO-DO.txt
  osszegzes.cmd            a végső összegzés minden menüponthoz
ps\                      a PowerShell részek, olvasható formában
```

## Bővítés

**Új mentendő tétel** – egy sor a `config\tetelek.cmd`-be, pl.:

```bat
%TETEL% MAPPA  "Letoltesek"  "%USERPROFILE%\Downloads"  Downloads  P
```

A mentés, a teszt és az exportálás is automatikusan viszi; a lista és a lépésszám magától frissül. A MAPPA tétel jelzői együtt is megadhatók: `P` = folyamatjelző, `J` = gyorsabb másolás nagy fájloknál (robocopy `/J`), pl. `PJ` – így megy a PST mappa és a C:\TEMP.

**Új tételtípus** – új fájl a `lib\tipusok\` alá (pl. `REGISTRY.cmd`) a többi mintájára, `:MENT` és `:VISSZA` címkével. Bemenet: `T_NEV`, `T_FORRAS`, `T_MAPPA`, `T_P1`, `T_P2`, mentésnél `CEL`, exportnál `FORRAS`. Az eredményt `%UI% :JELOL OK|HIBA|KIHAGYVA "üzenet"` jelzi.

**Visszaállítás utáni teendő egy FAJL tételhez** – a sor 6. oszlopa egy név (pl. `EXPLORER`, `STARTMENU`), a `lib\tipusok\FAJL.cmd`-ben pedig egy `:UTANA_<név>` címke. Sikeres visszaállítás után ez fut.

**Kézzel átnézendő mappák** – mentés előtt a script megkeresi és kiírja (a `_LEFT-TO-DO.txt`-be is), de nem másolja: a Letöltések, Asztal, Dokumentumok helyét és méretét, a nem szabványos mappákat a C: gyökerében és a felhasználó mappájában, és a csatolt PST-k mappáit. Hogy mit hagyjon ki, és meddig mérjen (alapból 60 mp), a `config\beallitasok.cmd`-ben állítható (`ATNEZ_*`).

**Új program az asztali parancsikonokhoz** – egy `%IKON_APP%` sor a `config\parancsikonok.cmd`-be.

**Új alapértelmezett fájltípus** – `%AA_TIPUS%` sor (és ha kell, `%AA_ELLENORIZ%` sor) a `config\alapertelmezett_alk.cmd`-be.

**Új menüpont** – új fájl a `modulok\` alá, plusz a `profil_mentes.bat`-ban: egy sor a menübe, egy betű a menü `%UI% :VALASZT 12345` sorába, egy sor a menüpont → modul táblába.

## Szabályok a kódhoz

- **Csak ASCII** (ékezet nélkül) és **CRLF** sorvég – a cmd másképp hibázhat.
- A `lib\` fájlok első két sora (`@call %*` / `@exit /b`) teszi hívhatóvá a címkéiket kívülről: `%UI% :JELOL OK "szöveg"`. A rövidítéseket (`%UI%`, `%MASOLAS%`...) a `profil_mentes.bat` definiálja.
- A modul `exit /b 0`-val tér vissza, ha végigment (jön az összegzés), `exit /b 1`-gyel, ha megszakították.
- Kérdéshez `%UI% :VALASZT IN "szöveg"`, ne `choice`: a `choice` minden rossz billentyűnél sípol, a `VALASZT` csendben vár tovább. Ugyanúgy errorlevelt ad (I = 1, N = 2). Automatikus futtatásnál `VALASZ_SORBOL=1` mellett soronként olvassa a válaszokat.
- Minden változó közös – nincs `setlocal` a modulokban és a `lib`-ben, mert az eredmények (`E_n`, `DB_OK`...) így jutnak vissza.
- PowerShell: `set "PS_FAJL=%PSDIR%\nev.ps1"`, utána `%PS_FUTTAT%`. Szövegként töltődik be, így a végrehajtási házirend nem tiltja le; a paraméterek környezeti változóban mennek.

## Futó programok bezárása

Mentés, export és teszt előtt a script megnézi, fut-e a `FIGYELT_PROGRAMOK` közül valami (Chrome, Edge, Outlook, Word, Excel, Sticky Notes). **B** = bezárja őket normálisan (a program rákérdezhet a mentésre). Ha ezután is futnak, **K** = kényszerített bezárás – a nem mentett munka elveszik, az Outlooknál csak végső esetben.

## Start menü és tálca

- **Start menü rögzítések** (Windows 11): a `start2.bin` mentése és visszaállítása, utána a Start menü újraindítása. Ami az új gépen nincs telepítve, annak a rögzítése kimarad. Ha a cég házirendben adja a Start menü elrendezését, az felülírja.
- **Tálca**: csak lista (`talca.txt`), mert Windows 11-en script nem tud megbízhatóan rögzíteni – kézzel kell újra.

## Eltérés az egyfájlos `profil_mentes.txt`-hez képest

Működésben nincs: a mentés, a teszt, az export és az 5. menü ellenőrzése ugyanazt a fájlt, kimenetet és logot adja (ugyanazon a gépen, ugyanazzal a válaszsorral összehasonlítva). Apró, szándékos különbségek:

- a mentendő tételek listája a configból generálódik, két egyenlő oszlopban;
- az Intéző újraindítási kérdés szövege: „hogy betöltse: Intezo Gyorseleres”;
- az 5. menü ellenőrzésénél a „mind rendben” üzenet a darabszámot írja ki a programnevek helyett.
