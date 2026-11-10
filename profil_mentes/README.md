# Eszközcsere segédlet

**Verzió: 1.0** · **Készítette: Kakuk Dániel**

A felhasználó adatait a régi gépen lementi egy külső meghajtóra, az új gépen pedig visszaállítja.

Indítás: **`Eszkozcsere_segedlet.bat`** – a `profil_mentes` mappa mellett. Az indító sosem változik,
a frissítés (6. menüpont) csak a `profil_mentes` mappát cseréli. A verzió a kezdőképernyőn és az ablak
címsorában látszik.

## Mit tud

| Menü | Hol | Mit csinál |
|---|---|---|
| **1 Adatok mentése** | régi gép | elmenti az adatokat a külső meghajtóra |
| **2 Adatok visszaállítása** | új gép | visszamásolja a mentést a felhasználó profiljába, kirakja az Office-ikonokat |
| **3 BitLocker beállítása** | új gép | a BitLocker titkosítás indítása az MBAM klienssel |
| **4 Chrome telepítése** | új gép | ha a Szoftverközpont nem indítja el a letöltést: a legfrissebb Chrome a Google oldaláról, rendszergazdai jelszóval |
| **5 Rendszergazdai eszközök** | bármelyik | Win+R parancsok (Eszközkezelő, Nyomtatáskezelés…), hálózati teszt naplóval, hálózat helyreállítása, rendszerfájlok javítása, lemezellenőrzés, speciális indítás – külön rendszergazdai ablakban, a jelszót egyszer kell megadni |
| **6 Segédlet frissítése** | bármelyik | a legújabb változat a GitHubról – letölti, a segédlet bezárása után lecseréli a fájlokat, és újraindul |

**Amit ment és visszaállít** – a teljes lista helyekkel és a kézi teendőkkel: [MIT_MENT.md](MIT_MENT.md)

- Outlook-aláírások, -levélpapírok
- Office: sablonok, egyéni szótárak, automatikus javítás, menüszalag, Word-gyorsrészek, Excel XLSTART
- Chrome: könyvjelzők és ikonjaik, előzmények, beállítások, új lap csempéi, címsor-javaslatok, saját
  helyesírási szavak – minden profil
- Edge-kedvencek, Kedvencek mappa, Teams-hátterek
- Sticky Notes-jegyzetek
- Fájlkezelő – Gyorselérés, Start menü rögzítései
- Indítópult mappa, C:\TEMP

**Amit listáz** (a mentés mappájába): telepített programok (`apps.txt`), tálcaikonok (`talca.txt`, és egy kép a tálcáról: `talca.png`),
csatolt PST-k helye és az Outlook-teendők (`outlook_lista.txt`), a nyomtatók és a hálózati meghajtók
(`nyomtatok_meghajtok.txt`), az asztali Office-ikonok (`asztal_office.txt`).

## Használat

**A régi gépen**

1. Dupla kattintás: `Eszkozcsere_segedlet.bat`
2. **1** → a külső meghajtó betűjele (a felismert már ott áll – Enter, vagy rögtön írd a másikat) → **Indulhat a mentés? I**
3. A végén egy kérdés: megnyissa-e a teendőket és a mappát – utána vissza a menübe. Kilépés: **X**.

**Az új gépen**

1. A felhasználó jelentkezzen be (a Chrome-ot és az Edge-et még ne indítsa el).
2. Dupla kattintás: `Eszkozcsere_segedlet.bat` → **2** → betűjel (Enter) → mentés (Enter) → **Indulhat? I**.
   Másolás közben nem kérdez semmit; a végén magától kirakja vagy javítja az Office-ikonokat, ha kell.
3. **3 BitLocker beállítása** – utána kövesd az MBAM ablakot. A menüpontok után a menü visszajön.
   Ha a Szoftverközpont nem indítja el a Chrome letöltését: **4 Chrome telepítése** – a Google céges
   telepítője (kb. 170 MB), aláírás-ellenőrzéssel; a Windows kéri a rendszergazdai jelszót, utána csendben települ.
4. A `_TEENDOK.txt` alapján a kézi lépések – lásd lent.

## Mire számíts

- **Lépésenként halad**, mindegyik mellett: `[ OK ]` sikerült · `[ HIBA ]` nézd meg · `[KIHAGYVA]` nincs ilyen
  (a gépen, vagy visszaállításkor a mentésben) – ez általában rendben van.
- **A futó programok bezárását** (Outlook, Word, Excel, Chrome, Edge, Sticky Notes) kéri, mert zárolhatják a fájlokat.
- **Belső lemezre** mentés előtt egyszer rákérdez – így egy Enterrel sem kerül a mentés a régi gép saját lemezére.
- **Office-ikonok**: visszaállításkor kirakja a Word, Excel, Outlook, PowerPoint, Teams, Skype Vállalati verzió
  ikonját, és mindazt, ami a régi gépen kint volt – ha telepítve van. A régi (pl. Office 2016-os) rossz ikonokat
  lecseréli. Ha minden rendben, a lépés meg sem jelenik.
- **A végén összegzés** és egy színes sáv: zöld = kész, piros = valami hibás.
- **Időtartam**: pár perc, nagy C:\TEMP mappánál több.
- **A C:\TEMP mappa átugorható**: mentés előtt kiírja, hány fájl és mekkora. Ha a másolása túl sokáig tart,
  **K** – a félbemaradt fájl törlődik, a többi lépés megy tovább, a `_TEENDOK.txt`-be pedig bekerül.
- **Újrafuttatható**: a meglévő mentés frissül, semmi nem törlődik.
- **Ha a Chrome már futott** az új gépen, a visszaállítás előtt rákérdez, átírhatja-e a profillistát (az ott
  mentett jelszavak, sütik elveszhetnek; a régit `Local State.regi` néven megtartja).
- **A Fájlkezelő** a visszaállítás végén magától újraindul (a Gyorselérés miatt).
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

- **Tálcaikonok** újrarögzítése – `talca.txt` és `talca.png` alapján (a Windows 11 nem engedi szkriptből).
- **Outlook**: PST-k csatolása (`outlook_lista.txt`), további postaládák, feladócímek, fiókok, alapértelmezett aláírás.
- **PST-k** átmásolása – a helyüket a mentés előtt kiírja, és az `outlook_lista.txt`-ben is megvan.
- **Tanúsítványok** (certmgr.msc – Személyes) – a segédlet nem menti őket.
- **Letöltések** és a felhasználó **saját mappái** – a segédlet nem menti.
- **Böngészőjelszavak** – szinkronnal vagy exporttal, a segédlet nem viszi át.
- **Programok** telepítése az `apps.txt` alapján.
- **Nyomtatók, hálózati meghajtók** – ami nem jött vissza magától, a `nyomtatok_meghajtok.txt` alapján.
- **Alapértelmezett alkalmazások**: Gépház › Alkalmazások › Alapértelmezett alkalmazások – Word, Excel,
  PowerPoint, PDF: Adobe Acrobat Reader, böngésző: Chrome.
- A végén: **a mentés törlése** a külső meghajtóról
