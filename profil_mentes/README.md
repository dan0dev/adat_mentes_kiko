# Eszközcsere segédlet

**Verzió: 1.0** · **Készítette: Kakuk Dániel**

A felhasználó adatait a régi gépen lementi egy külső meghajtóra, az új gépen pedig visszaállítja.

## Mit tud

| Menü | Hol | Mit csinál |
|---|---|---|
| **1 Adatok mentése** | régi gép | elmenti az adatokat a külső meghajtóra |
| **2 Próbafuttatás** | régi gép | mindent ellenőriz, de semmit nem másol – éles mentés előtt ajánlott |
| **3 Adatok visszaállítása** | új gép | visszamásolja a mentést a felhasználó profiljába |
| **4 Laptop beállítása** | új gép | fedél lehajtásakor: Nincs művelet · BitLocker (MBAM) indítása |
| **5 Alapértelmezett alkalmazások** | új gép | Word, Excel, PowerPoint, PDF: Adobe Acrobat Reader, böngésző: Chrome |

**Amit ment és visszaállít:**

- Tanúsítványok (certmgr.msc – Személyes, Mások) – a kulcsosakat jelszóval védve
- Outlook-aláírások, a `%USERPROFILE%\PST` mappa
- Office-sablonok, egyéni szótárak, Excel XLSTART
- Chrome: könyvjelzők, előzmények, beállítások – minden profil
- Edge-kedvencek, Kedvencek mappa
- Sticky Notes-jegyzetek
- Fájlkezelő – Gyorselérés, Start menü rögzítései
- Indítópult mappa, C:\TEMP

**Amit listáz** (a mentés mappájába): telepített programok (`apps.txt`), tálcaikonok (`talca.txt`),
csatolt PST-k helye és az Outlook-teendők (`outlook_lista.txt`).

## Használat

**A régi gépen**

1. Dupla kattintás: `Eszkozcsere_segedlet.bat`
2. Ha akarod, előbb **2 Próbafuttatás** – megmutatja, menthető-e minden.
3. **1 Adatok mentése** → a külső meghajtó betűjele (pl. `E`) → **Indulhat a mentés? I**
4. **Tanúsítványok jelszava** – kétszer kéri. **Jegyezd meg**, a visszaállításnál kell! Sehová nem kerül leírásra.
5. Megvárod a végét, átnézed az összegzést.

**Az új gépen**

1. A felhasználó jelentkezzen be (a Chrome-ot és az Edge-et még ne indítsa el).
2. Dupla kattintás: `Eszkozcsere_segedlet.bat` → **3 Adatok visszaállítása** → a mentés sorszáma
3. Tanúsítványok jelszava → megvárod a végét.
4. Laptopnál: **4 Laptop beállítása**.
5. Jobb kattintás → *Futtatás rendszergazdaként* → **5** (beállítás).
   Utána a felhasználó jelentkezzen ki és be, majd sima indítással **5** (ellenőrzés).
6. A `_TEENDOK.txt` alapján a kézi lépések – lásd lent.

## Mire számíts

- **Lépésenként halad**, mindegyik mellett: `[ OK ]` sikerült · `[ HIBA ]` nézd meg · `[KIHAGYVA]` ezen a
  gépen nem létezik – ez általában rendben van.
- **A futó programokat** (Outlook, Word, Excel, Chrome, Edge, Sticky Notes) bezárást kéri, mert zárolhatják a fájlokat.
- **A végén összegzés** és egy színes sáv: zöld = kész, piros = valami hibás.
- **Időtartam**: pár perc, a PST-k méretétől függően több.
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
| `Tanusitvanyok\lista.txt` | a mentett tanúsítványok |

## Ami továbbra is manuális

A `_TEENDOK.txt` ezeket pipálható listában adja:

- **Tálcaikonok** újrarögzítése – `talca.txt` alapján (Windows 11 nem engedi scriptből).
- **Outlook**: PST-k csatolása (`outlook_lista.txt`), további postaládák, feladócímek, fiókok, alapértelmezett aláírás.
- **Archive PST-k** mentése.
- **Letöltések** és a felhasználó **saját mappái** – a segédlet nem menti.
- **Böngészőben mentett jelszavak**
- **Programok** telepítése az `apps.txt` alapján.
- A végén: **a mentés törlése** a külső meghajtóról

## Tudnivalók

- Az **5. menü** beállítása csak **tartományi** gépen él (a Windows így működik), ki- és bejelentkezés után.
- A **kulcsos tanúsítványok** jelszóval védett fájlban vannak (AES-256); jelszó nélkül nem állíthatók vissza.
- A fejlesztői leírás (bővítés, tesztelés): `docs\FEJLESZTES.md` a projekt mappájában.
