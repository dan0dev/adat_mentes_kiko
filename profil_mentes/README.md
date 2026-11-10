# Eszközcsere segédlet

**Verzió: 1.0** · **Készítette: Kakuk Dániel**

A felhasználó adatait a régi gépen lementi egy külső meghajtóra, az új gépen pedig visszaállítja.

## Mit tud

| Menü | Hol | Mit csinál |
|---|---|---|
| **1 Adatok mentése** | régi gép | elmenti az adatokat a külső meghajtóra |
| **2 Adatok visszaállítása** | új gép | visszamásolja a mentést a felhasználó profiljába |
| **3 BitLocker beállítása** | új gép | a BitLocker titkosítás indítása az MBAM klienssel |
| **4 Chrome telepítése** | új gép | ha a Szoftverközpont nem indítja el a letöltést: a legfrissebb Chrome a Google oldaláról, rendszergazdai jelszóval |
| **5 Segédlet frissítése** | bármelyik | a legújabb változat a GitHubról – letölti, a segédlet bezárása után lecseréli a fájlokat, és újraindul |

**Amit ment és visszaállít:**

- Outlook-aláírások
- Office-sablonok, egyéni szótárak, Excel XLSTART
- Chrome: könyvjelzők, előzmények, beállítások – minden profil
- Edge-kedvencek, Kedvencek mappa
- Sticky Notes-jegyzetek
- Fájlkezelő – Gyorselérés, Start menü rögzítései
- Indítópult mappa, C:\TEMP

**Amit listáz** (a mentés mappájába): telepített programok (`apps.txt`), tálcaikonok (`talca.txt`, és egy kép a tálcáról: `talca.png`),
csatolt PST-k helye és az Outlook-teendők (`outlook_lista.txt`).

## Használat

**A régi gépen**

1. Dupla kattintás: `Eszkozcsere_segedlet.bat`
2. **1 Adatok mentése** → a külső meghajtó betűjele – a felismert külső meghajtó (ha nincs, `D`) már ott áll, Enterrel elfogadod, vagy rögtön beírod a másikat → **Indulhat a mentés? I**
3. Megvárod a végét, átnézed az összegzést.

**Az új gépen**

1. A felhasználó jelentkezzen be (a Chrome-ot és az Edge-et még ne indítsa el).
2. Dupla kattintás: `Eszkozcsere_segedlet.bat` → **2 Adatok visszaállítása** → a mentés sorszáma → megvárod a végét.
3. **3 BitLocker beállítása** – utána kövesd az MBAM ablakot.
   Ha a Szoftverközpont nem indítja el a Chrome letöltését: **4 Chrome telepítése** – a Google céges
   telepítője (kb. 170 MB), aláírás-ellenőrzéssel; a Windows kéri a rendszergazdai jelszót, utána csendben települ.
4. A `_TEENDOK.txt` alapján a kézi lépések – lásd lent.

## Mire számíts

- **Lépésenként halad**, mindegyik mellett: `[ OK ]` sikerült · `[ HIBA ]` nézd meg · `[KIHAGYVA]` ezen a
  gépen nem létezik – ez általában rendben van.
- **A futó programokat** (Outlook, Word, Excel, Chrome, Edge, Sticky Notes) bezárást kéri, mert zárolhatják a fájlokat.
- **A végén összegzés** és egy színes sáv: zöld = kész, piros = valami hibás.
- **Időtartam**: pár perc, nagy C:\TEMP mappánál több.
- **A C:\TEMP mappa átugorható**: mentés előtt kiírja, hány fájl és mekkora. Ha a másolása túl sokáig tart,
  **K** – a félbemaradt fájl törlődik, a többi lépés megy tovább, a `_TEENDOK.txt`-be pedig bekerül.
- **Újrafuttatható**: a meglévő mentés frissül, semmi nem törlődik.
- **Ha a Chrome már futott** az új gépen, rákérdez, átírhatja-e a profillistát (az ott mentett jelszavak,
  sütik elveszhetnek; a régit `Local State.regi` néven megtartja).
- **Hangot nem ad.**

A mentés mappája: `<meghajtó>:\Mentes\<felhasználó>_<gép>\`

| Fájl | Mi ez |
|---|---|
| `_TEENDOK.txt` | a kézi teendők listája, pipálható |
| `_MENTES_OK_<dátum>.txt` / `_MENTES_<n>_HIBA_<dátum>.txt` | a mentés összegzése – a nevében az eredmény |
| `_VISSZAALLITAS_…txt` | a visszaállítás összegzése |
| `mentes_naplo.txt`, `visszaallitas_naplo.txt` | részletes napló, hiba esetén ide nézz |
| `apps.txt`, `talca.txt`, `outlook_lista.txt` | listák a kézi lépésekhez |
| `talca.png` | kép a tálcáról – az ikonok sorrendje is látszik |

## Ami továbbra is manuális

A `_TEENDOK.txt` ezeket pipálható listában adja:

- **Tálcaikonok** újrarögzítése – `talca.txt` és `talca.png` alapján (Windows 11 nem engedi scriptből).
- **Outlook**: PST-k csatolása (`outlook_lista.txt`), további postaládák, feladócímek, fiókok, alapértelmezett aláírás.
- **PST-k** átmásolása – a helyüket a mentés előtt kiírja, és az `outlook_lista.txt`-ben is megvan.
- **Tanúsítványok** (certmgr.msc – Személyes) – a segédlet nem menti őket.
- **Letöltések** és a felhasználó **saját mappái** – a segédlet nem menti.
- **Böngészőben mentett jelszavak**
- **Programok** telepítése az `apps.txt` alapján.
- **Alapértelmezett alkalmazások**: Gépház › Alkalmazások › Alapértelmezett alkalmazások – Word, Excel,
  PowerPoint, PDF: Adobe Acrobat Reader, böngésző: Chrome.
- A végén: **a mentés törlése** a külső meghajtóról
