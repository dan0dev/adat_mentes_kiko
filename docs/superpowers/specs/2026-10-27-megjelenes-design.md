# Eszközcsere segédlet 1.0 – look, feel and wording (design spec)

Status: draft for review – 2026-10-27
Scope: `profil_mentes\` only. The old single-file `profil_mentes.txt` is not updated.

## 1. Goal

The tool goes from one technician's helper to a company-wide tool that the boss reviews.
Every screen, every message and every file it writes must look like one product: correct
Hungarian with accents, one tone, one layout, a visible version and the credit
**Készítette: Kakuk Dániel**. Behaviour (what is copied, checked, written) does not change.

## 2. Decisions

| # | Decision | Default (recommended) | Why |
|---|---|---|---|
| D1 | How the tool addresses the reader | **Tegezés** (chosen 2026-10-27), the tool speaks in first person ("Megnyissam a naplót?", "Válassz menüpontot") | Decided by the author |
| D2 | Menu order | **Workflow order**: Old machine 1 Mentés, 2 Próbafuttatás – New machine 3 Visszaállítás, 4 Laptop, 5 Alapértelmezett alkalmazások | Grouped and numbered in the order the work is done; the to-do text already says "restore, then laptop, then default apps" |
| D3 | Product name | **Eszközcsere segédlet**, version **1.0** | Already the start-screen title and the README title |
| D4 | To-do file name | **`_TEENDOK.txt`** (restore still finds an old `_LEFT-TO-DO.txt`) | Everything else is Hungarian |
| D5 | Accented text | **UTF-8 files, `chcp 65001` at start** | Tested on this machine (Windows 11 26200): echo, labels, `call`, `for /f`, substitution, `if`, substring by character, PowerShell output all correct |
| D6 | "Export" menu | Renamed **Adatok visszaállítása** | "Export" means taking data out; menu 2 puts data back. The to-do file already called it "IMPORTNÁL" – one term now |

## 3. Text rules (style guide)

1. Correct Hungarian spelling with all accents (á é í ó ö ő ú ü ű) in **user-visible text**.
   Labels, variable names, file names and existing comments stay ASCII.
2. Tone: tegezés (D1) everywhere, in every screen and file – never mixed with magázás.
   The tool refers to itself in first person singular: "ellenőrzöm",
   "bezárom", "Megnyissam…?". It never says "script"; if it needs a noun: "a segédlet".
3. Sentence-style capitals. Only the product name and section rules are in capitals.
4. Dash in sentences: spaced en dash ` – `. Ranges: `1–5`. Hyphen only inside words.
5. Brand + common noun take a hyphen: Outlook-aláírások, Office-sablonok, Chrome-profilok,
   Edge-kedvencek, Sticky Notes-jegyzetek, PST-mappa, Office-parancsikonok.
6. Numbers: decimal comma (`12,5 GB`), singular noun after a numeral (`3 fájl`, `2 profil`).
   Dates on screen and in documents: `2026. 10. 27.`; dates in file names stay `2026-10-27`.
7. No article before a variable value (a/az depends on how it is pronounced): write
   "A kiválasztott meghajtó (E:) nem írható", not "Az E: meghajtó…".
8. Error messages say what happened, then what to do: "A meghajtó nem írható. Kapcsold ki
   az írásvédelmet, vagy válassz másik meghajtót."
9. Use Windows' own Hungarian terms (checked on hu-HU Windows 11):
   Fájlkezelő, Gyorselérés, Indítópult, Start menü, Tálca, "Fedél lehajtásakor: Nincs művelet",
   Alapértelmezett alkalmazások, Outlook-adatfájl (.pst), rendszergazda.
10. Length: a result message is at most **33 characters**; anything longer becomes a
    detail line (see `:JELOL` third parameter). Step and item names are at most **26 characters**.
11. No `!` in any text (delayed expansion eats it). Inside `( … )` blocks, `)` is written `^)`.
    No unescaped `& | < > %` in text.

### Glossary – one word per thing

| Use | Not |
|---|---|
| mentés, menteni | backup, adatmentés (in labels) |
| visszaállítás | export, import, exportálás |
| próbafuttatás | teszt, teszt futtatás |
| külső meghajtó | célmeghajtó (only in the space check: "a külső meghajtón") |
| tétel | elem, lépés (in results) |
| napló | log |
| összegzés | summary |
| teendők | LEFT-TO-DO, to-do |
| számítógép (labels), gép (sentences: régi gép, új gép) | PC, eszköz |
| rendszergazda | admin |
| program (installed applications) | alkalmazás – except "Alapértelmezett alkalmazások" |

## 4. Allowed characters

Latin-2 letters plus only these (all in the WGL4 set, so Consolas and Lucida Console show them):
`═ ║ ╔ ╗ ╚ ╝ ─ – · • › …` and the space. No ✓ ✗ ▸ or emoji – they appear as boxes in the
classic console.

## 5. Layout

- 2-space left margin, frames and rules **70** wide (column 3–72), no line longer than
  **76** columns except lines that print a file path. Works in an 80-column window.
- Colours (existing tokens, new meaning):
  `C_KEK` frames and rules only · `C_FEHER` product name, headings, the value the reader must check ·
  `C_SZURKE` hints and detail lines · `C_ZOLD` / `C_PIROS` / `C_SARGA` only on status tags,
  banners and one-line warnings · `C_ZOLD_HATTER` / `C_PIROS_HATTER` only for the final banner.
- Status tags, always 10 characters, always at the left of the line:
  `[   OK   ]` green · `[  HIBA  ]` red · `[KIHAGYVA]` yellow · `[   –    ]` grey (not requested).
- Prompts start with `› `. Yes/no prompts end with ` [I/N] `. Multiple choice: the options
  on their own line, then a short prompt:
  `U – újraellenőrzés    B – bezárás    F – folytatás így`  →  `› Választás [U/B/F]: `
- No beep anywhere (the two `forfiles … 0x07` lines in `lib\osszegzes.cmd` are removed).
- No "folyamatban..." line under each step: the step header and the window title show progress.
- Window title: `Eszközcsere segédlet – <menüpont>`; during a run `[6/16] PST-mappa (Outlook) – Adatok mentése`.

### 5.1 Start screen (exact wording)

```

  ╔════════════════════════════════════════════════════════════════════╗
  ║                                                                    ║
  ║   ESZKÖZCSERE SEGÉDLET                                Verzió: 1.0  ║
  ║   Felhasználói adatok mentése és visszaállítása eszközcseréhez     ║
  ║                                                                    ║
  ╚════════════════════════════════════════════════════════════════════╝

     Felhasználó     kakuk
     Számítógép      DESKTOP-1234
     Profil          C:\Users\kakuk
     Jogosultság     normál felhasználó          (or: rendszergazda, yellow)

  ── A RÉGI GÉPEN ──────────────────────────────────────────────────────

     1   Adatok mentése                a külső meghajtóra
     2   Próbafuttatás                 a mentés ellenőrzése másolás nélkül

  ── AZ ÚJ GÉPEN ───────────────────────────────────────────────────────

     3   Adatok visszaállítása         a külső meghajtón lévő mentésből
     4   Laptop beállítása             fedél lehajtása, BitLocker
     5   Alapértelmezett alkalmazások  Word, Excel, PowerPoint, PDF, Chrome

  ──────────────────────────────────────────────────────────────────────
     Készítette: Kakuk Dániel

  › Válassz menüpontot [1–5]:
```

### 5.2 Every other screen – header

```

  ESZKÖZCSERE SEGÉDLET  ›  Adatok mentése – előkészítés
  ══════════════════════════════════════════════════════════════════════

```

### 5.3 Run screen

```
  ESZKÖZCSERE SEGÉDLET  ›  Adatok mentése folyamatban
  ══════════════════════════════════════════════════════════════════════
  A folyamat végéig ne húzd ki a külső meghajtót.

  [ 1/16]  Outlook-aláírások
           [   OK   ]  3 fájl, ellenőrizve

  [ 2/16]  Office-sablonok
           [KIHAGYVA]  ezen a gépen nincs ilyen mappa

  [ 7/16]  Chrome-profilok
           Default, Profile 1                         (grey detail line)
           [   OK   ]  2 profil, ellenőrizve
```

### 5.4 Summary screen

```
  ESZKÖZCSERE SEGÉDLET  ›  Összegzés – Adatok mentése
  ══════════════════════════════════════════════════════════════════════

    [   OK   ]  Outlook-aláírások           3 fájl, ellenőrizve
    [KIHAGYVA]  Office-sablonok             ezen a gépen nincs ilyen mappa
    [  HIBA  ]  PST-mappa (Outlook)         néhány fájl nem másolható
  ──────────────────────────────────────────────────────────────────────
    Sikeres: 13     Hibás: 1     Kihagyva: 2     Időtartam: 3 perc 12 mp

      FIGYELEM: 1 tétel hibával zárult – nézd át a listát és a naplót.     (red band, 72 wide)

    Mentés helye    E:\Mentes\kakuk_DESKTOP-1234
    Összegzés       _MENTES_1_HIBA_2026-10-27.txt
    Teendők         _TEENDOK.txt
    Napló           mentes_naplo.txt

  ──────────────────────────────────────────────────────────────────────
     Eszközcsere segédlet 1.0  ·  Készítette: Kakuk Dániel

  › Megnyissam a naplót? [I/N]
```

Row: 4 spaces, tag (10), 2 spaces, name padded to 26, 1 space, message (≤ 33, cut with `…`).

## 6. Exact wording for fixed texts

### Menu (title bar / summary names)

| Key | Menu label | Description column | `MOD_NEV` |
|---|---|---|---|
| 1 | Adatok mentése | a külső meghajtóra | Adatok mentése |
| 2 | Próbafuttatás | a mentés ellenőrzése másolás nélkül | Próbafuttatás |
| 3 | Adatok visszaállítása | a külső meghajtón lévő mentésből | Adatok visszaállítása |
| 4 | Laptop beállítása | fedél lehajtása, BitLocker | Laptop beállítása |
| 5 | Alapértelmezett alkalmazások | Word, Excel, PowerPoint, PDF, Chrome | Alapértelmezett alkalmazások |

### Item and step names (≤ 26 characters)

| Now | New |
|---|---|
| Outlook alairasok | Outlook-aláírások |
| Office sablonok | Office-sablonok |
| Office egyeni szotar | Office egyéni szótárai |
| Excel XLSTART | Excel XLSTART mappa |
| Startup mappa | Indítópult mappa |
| PST mappa | PST-mappa (Outlook) |
| Chrome profilok | Chrome-profilok |
| Edge kedvencek | Edge-kedvencek |
| Kedvencek - Favorites | Kedvencek mappa |
| Sticky Notes | Sticky Notes-jegyzetek |
| Intezo Gyorseleres | Fájlkezelő – Gyorselérés |
| Start menu rogzitesek | Start menü rögzítései |
| C:\TEMP | C:\TEMP mappa |
| Telepitett programok | Programlista |
| Talca ikonjai | Tálcaikonok listája |
| Outlook lista | Outlook-lista |
| Kornyezet | Környezet |
| Office parancsikonok | Office-parancsikonok |
| Fedel lehajtasa | Fedél lehajtása |
| BitLocker - MBAM | BitLocker (MBAM) |
| Alapertelmezett alkalmazasok beallitasa | Társítások beállítása |
| Alapertelmezett alkalmazasok ellenorzese | Társítások ellenőrzése |

### Copy results (`lib\masolas.cmd`) – message ≤ 33, detail line

| Case | Message | Detail |
|---|---|---|
| OK | átmásolva, ellenőrizve | – |
| rc ≥ 16 | nem másolható | Az elérési út vagy a jogosultság nem megfelelő – részletek a naplóban. |
| rc ≥ 8 | néhány fájl nem másolható | Zárolt fájl vagy hiányzó jogosultság – részletek a naplóban. |
| check did not run | az ellenőrzés nem futott le | Részletek a naplóban. |
| check differs | a másolat eltér az eredetitől | Egy fájl másolás közben megváltozott vagy zárolt volt. |
| test OK | elérhető, menthető | – |
| test rc ≥ 8 | nem olvasható | Jogosultság vagy elérési út – részletek a naplóban. |
| folder missing | ezen a gépen nincs ilyen mappa | – |
| file missing | ezen a gépen nincs ilyen fájl | – |

### Final banners

| Case | Band | Text |
|---|---|---|
| errors | red | `FIGYELEM: <n> tétel hibával zárult – nézd át a listát és a naplót.` |
| skipped only | green | `KÉSZ – minden elérhető tétel rendben.` + grey line `A kihagyott tételek ezen a gépen nem léteztek; ez általában rendben van.` |
| all OK | green | `KÉSZ – minden tétel sikeresen lefutott.` |
| test, problems | red | `PRÓBAFUTTATÁS: <n> probléma – javítsd ezeket az éles mentés előtt.` |
| test OK | green | `PRÓBAFUTTATÁS SIKERES – a mentés ezen a gépen lefuttatható.` |
| cancelled | yellow line | `Megszakítva – nem történt változtatás.` |

### Credit and version

- Start screen footer: `Készítette: Kakuk Dániel`
- Summary footer and the last line of every text file the tool writes
  (`_TEENDOK.txt`, the summary file, `outlook_lista.txt`, `talca.txt`):
  `Eszközcsere segédlet 1.0 · Készítette: Kakuk Dániel`
- `apps.txt` stays a plain list (no footer), so it is easy to compare.
- README first lines: title, `Verzió: 1.0`, `Készítette: Kakuk Dániel`.

### Files the tool writes (ASCII names)

| Now | New |
|---|---|
| `_LEFT-TO-DO.txt` | `_TEENDOK.txt` (restore appends to an old `_LEFT-TO-DO.txt` if that is what the backup has) |
| `mentes_log.txt`, `visszaallitas_log.txt`, `teszt_log.txt`, `laptop_log.txt`, `alapertelmezett_alk_log.txt` | `…_naplo.txt` with the same prefixes; `teszt_` becomes `probafuttatas_` |
| `_EXPORT_*.txt` summary | `_VISSZAALLITAS_*.txt` (old `_EXPORT_*.txt` removed together with the new ones) |
| `modulok\export.cmd` | `modulok\visszaallitas.cmd` |

## 7. Out of scope

New features, behaviour changes, a GUI, renaming `profil_mentes.bat` or the `profil_mentes`
folder, converting existing code comments, the old `profil_mentes.txt`.
