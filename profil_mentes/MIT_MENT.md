# Mit ment a segédlet, és mi marad kézi

**Eszközcsere segédlet** · Készítette: Kakuk Dániel

A mentés helye: `<külső meghajtó>:\Mentes\<felhasználó>_<gép>\` – a visszaállítás ugyanide teszi vissza,
ahonnan mentette.

## Amit ment és visszaállít

| Tétel | Honnan (a felhasználó profiljában) | Mi ez |
|---|---|---|
| Outlook-aláírások | `%APPDATA%\Microsoft\Signatures` | minden aláírás, képekkel |
| Office-sablonok | `%APPDATA%\Microsoft\Templates` | saját sablonok, a Word `Normal.dotm`-ja |
| Office egyéni szótárai | `%APPDATA%\Microsoft\UProof` | a helyesírás-ellenőrzőhöz felvett szavak |
| Office automatikus javítás (tesztelés alatt) | `%APPDATA%\Microsoft\Office\*.acl` | saját javítások, pl. „ttm” → „tisztelettel” |
| Word-gyorsrészek (tesztelés alatt) | `%APPDATA%\Microsoft\Document Building Blocks` | mentett szövegrészek, gyorsrészek |
| Office menüszalag (tesztelés alatt) | `%LOCALAPPDATA%\Microsoft\Office\*.officeUI` | testreszabott menüszalag, gyorselérési eszköztár |
| Outlook-levélpapírok (tesztelés alatt) | `%APPDATA%\Microsoft\Stationery` | levélpapírok, témák |
| Office – legutóbbi fájlok (tesztelés alatt) | registry: `HKCU\…\Office\16.0\Word`, `Excel`, `PowerPoint` › `User MRU` | a legutóbb megnyitott és a rögzített fájlok listája (Office 2016 és 365). A helyi és a hálózati fájl csak akkor nyílik meg, ha az új gépen is ugyanott van; a OneDrive/SharePoint-fájlok a fiókkal amúgy is visszajönnek |
| Excel XLSTART mappa | `%APPDATA%\Microsoft\Excel\XLSTART` | induláskor megnyíló fájlok, személyes makrófüzet |
| Indítópult mappa | `%APPDATA%\…\Start Menu\Programs\Startup` | bejelentkezéskor induló programok |
| Chrome-profilok | `%LOCALAPPDATA%\Google\Chrome\User Data` | minden profilból: könyvjelzők, előzmények, beállítások – és a profillista; a könyvjelzők ikonjai, az új lap csempéi, a címsor javaslatai, a saját helyesírási szavak (tesztelés alatt) |
| Edge-kedvencek | `%LOCALAPPDATA%\Microsoft\Edge\User Data` | minden profil kedvencei, a profillista |
| Kedvencek mappa | `%USERPROFILE%\Favorites` | a régi Internet Explorer / Edge kedvencek |
| Sticky Notes-jegyzetek | `%LOCALAPPDATA%\Packages\Microsoft.MicrosoftStickyNotes_…` | a cetlik |
| Fájlkezelő – Gyorselérés | `%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations` | a rögzített mappák |
| Fájlkezelő – Legutóbbiak (tesztelés alatt) | ugyanott | a Fájlkezelő legutóbbi fájljai |
| Start menü rögzítései | `%LOCALAPPDATA%\Packages\Microsoft.Windows.StartMenuExperienceHost_…` | a Start menübe rögzített programok |
| C:\TEMP mappa | `C:\TEMP` | teljes mappa – másolás közben **K**-val átugorható |

Ami a régi gépen nem létezik, az kimarad (`[KIHAGYVA]`) – ez általában rendben van.

**Visszaállításkor magától:**

- **Office-ikonok az asztalon** (tesztelés alatt) – Word, Excel, Outlook, PowerPoint, Teams, Skype Vállalati verzió, és ami a
  régi gép asztalán kint volt (pl. OneNote) – ha telepítve van. A régi (pl. Office 2016-os) rossz ikonokat
  lecseréli. Ha minden rendben, a lépés meg sem jelenik.
- **Fájlkezelő és Start menü** újraindítása, hogy a Gyorselérés és a rögzítések betöltődjenek.

## Amit listáz (a mentés mappájába, a kézi lépésekhez)

| Fájl | Mi van benne |
|---|---|
| `apps.txt` | a telepített programok |
| `talca.txt`, `talca.png` | a tálcára rögzített ikonok – listában és képen |
| `outlook_lista.txt` | a csatolt PST-k helye, az Outlook kézi teendői |
| `nyomtatok_meghajtok.txt` | a nyomtatók és a hálózati meghajtók |
| `asztal_office.txt` | a régi gép asztali Office-ikonjai |
| `_TEENDOK.txt` | a kézi teendők pipálható listája |

## Amit kézzel kell beállítani

A `_TEENDOK.txt` ezeket pipálható listában adja.

**A régi gépen**

- [ ] **Outlook:** további postaládák, feladócímek, fiókok – `outlook_lista.txt`
- [ ] **Tálcaikonok** – `talca.txt`, `talca.png`
- [ ] **PST-k átmásolása** – a helyük az `outlook_lista.txt`-ben
- [ ] **Tanúsítványok:** certmgr.msc – Személyes
- [ ] **Böngészőjelszavak:** szinkronnal vagy exporttal – nem kerülnek át (a géphez kötött kulccsal titkosítottak)

**Az új gépen**

- [ ] **2 Visszaállítás, 3 BitLocker**
- [ ] **Chrome:** a Szoftverközpontból – ha nem indul el a letöltés, **4 Chrome telepítése**
- [ ] **Alapértelmezett alkalmazások:** Word, Excel, PowerPoint, PDF (Adobe Acrobat Reader), böngésző (Chrome) –
  Gépház › Alkalmazások › Alapértelmezett alkalmazások
- [ ] **Tanúsítványok** telepítése
- [ ] **Outlook:** PST-k csatolása (`outlook_lista.txt`), postaládák, feladócímek, fiókok, alapértelmezett aláírás
- [ ] **Chrome, Edge:** profilok, könyvjelzők, bejelentkezés
- [ ] **Sticky Notes:** megvannak a jegyzetek?
- [ ] **Programok:** az `apps.txt` összevetése, a hiányzók telepítése
- [ ] **Nyomtatók, hálózati meghajtók:** ami nem jött vissza magától – `nyomtatok_meghajtok.txt`
- [ ] **Tálcaikonok** újra – `talca.txt`, `talca.png` (a Windows 11 nem engedi szkriptből)
- [ ] **Start menü:** a hiányzó rögzítések
- [ ] **Minden rendben:** a mentés törlése a külső meghajtóról

**Amit a segédlet szándékosan nem ment**

- **Letöltések** és a felhasználó **saját mappái** – ezeket eszközcserénként kell eldönteni.
- **A PST-fájlok** – csak a helyüket listázza.
- **A tanúsítványok** – a kulcsosak nem vihetők át megbízhatóan.
- **A böngészők jelszavai és sütijei** – a régi géphez kötött kulccsal titkosítottak.
