# Eszközcsere segédlet 1.0 – look, feel and wording – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `profil_mentes` into a polished company-wide tool – accented Hungarian, one tone, one layout, version and the credit "Készítette: Kakuk Dániel" – without changing what it copies or checks.

**Architecture:** The whole run switches to UTF-8 (`chcp 65001`) so files can hold accented text while labels and variables stay ASCII. `lib\ui.cmd` becomes the only place that draws frames, tags, rows, bands and prompts; every module only passes wording. A test environment outside the tool folder runs every menu in a fake profile on a `subst` drive with scripted answers and checks the transcripts automatically.

**Tech Stack:** cmd batch, robocopy, PowerShell 5.1 (Windows 10/11 built-ins only).

**Spec:** `docs/superpowers/specs/2026-10-27-megjelenes-design.md` – all exact wording, mockups, widths and the glossary are there; this plan does not repeat them.

## Global Constraints

- Windows 10 or 11 only. No new dependencies; built-in tools only.
- `.cmd` / `.bat`: UTF-8 **without BOM**, CRLF line endings. `.ps1`: UTF-8 (they are loaded with `ReadAllText`).
- `chcp 65001` runs before any line containing a non-ASCII byte is executed.
- User-visible text: accented Hungarian per spec §3; labels, variables, file names, existing comments: ASCII.
- No `!` in text; `)` inside `( … )` blocks written `^)`; no unescaped `& | < > %`.
- Only the characters in spec §4 besides letters. No beep, no `choice`, no BEL – use `%UI% :VALASZT`.
- Max line 76 columns (paths excepted); frames/rules 70 wide after a 2-space margin.
- Every `powershell` call whose output is read by `for /f` sets `[Console]::OutputEncoding=[Text.Encoding]::UTF8` first.
- Behaviour unchanged: same items copied, same checks, same backup folder layout (only the renamed files of spec §6 differ).
- Credit string exactly `Készítette: Kakuk Dániel`; product line exactly `Eszközcsere segédlet 1.0 · Készítette: Kakuk Dániel`, built from `VERZIO` and `SZERZO`.
- Never run the restore (menu 3 after Task 4, menu 2 before) on the real profile – only through `tesztkornyezet\futtat.ps1`.

## Review Focus

1. **Accented names end to end** – user folders, PST names, Chrome profile names with á/ő/ű pass through `for /f`, robocopy, PowerShell, the summary and `_TEENDOK.txt` unchanged → Task 2 seeds them and checks the copies byte for byte.
2. **A wording change breaks batch syntax on a branch the normal path never runs** (`)` in an `if` block, `!`, `%`) → every task runs the error and cancel answer files, and the checker looks for parser errors.
3. **Silent key reader under UTF-8** – `xcopy /W` prompt text is localized; a single key must work, Enter and wrong keys must be ignored silently, lower and upper case → manual check in Task 2, again in Task 10.
4. **Started from an open cmd window** – the code page (852) comes back after a normal end and after a cancel → Task 2 test.
5. **Old backups** – a backup made by the current version (`_LEFT-TO-DO.txt`, `mentes_log.txt`, `_MENTES_OK_*.txt`) restored by 1.0: to-do appended to the old file, no second summary, old `_EXPORT_*.txt` removed → Task 8 test using the Task 1 baseline backup.

---

### Task 0: Version control

**Files:** `adat_mentes_kiko\.gitattributes`, `adat_mentes_kiko\.gitignore`

- [ ] **Step 1:** `git init` in `adat_mentes_kiko`; `.gitattributes`: `*.cmd text eol=crlf`, `*.bat text eol=crlf`, `*.ps1 text eol=crlf`; `.gitignore`: `tesztkornyezet/kimenet/`.
- [ ] **Step 2:** Verify: `git ls-files --eol profil_mentes` shows `w/crlf` for every `.cmd`.
- [ ] **Step 3:** Commit `chore: current state before the 1.0 look and feel work`.

### Task 1: Test environment and baseline

**Files:**
- Create: `tesztkornyezet\futtat.ps1`, `tesztkornyezet\profil_feltolt.ps1`, `tesztkornyezet\teszt_konfig.cmd`, `tesztkornyezet\ellenoriz.ps1`, `tesztkornyezet\eredmeny.ps1`, `tesztkornyezet\valaszok\*.txt`, `tesztkornyezet\alap\` (baseline output)
- Modify: `profil_mentes\profil_mentes.bat` (one line after `call "%CONF%\beallitasok.cmd"`)

**Interfaces:**
- Produces: `futtat.ps1 -Valaszok <name> [-Mentes <folder>] [-Kodlap 852]` → returns the transcript path `tesztkornyezet\kimenet\<name>.txt`; the fake drive stays at `%TEMP%\pm_teszt\kulso` between runs (`-Tiszta` empties it).
- Produces: `ellenoriz.ps1 -Atirat <file> [-Vege <text>] [-Kredit] [-Szoveg]` → prints one line per problem, exit code = number of problems.
- Produces: `eredmeny.ps1 -Atirat <file> [-Mentes <folder>]` → JSON `{ sikeres, hibas, kihagyva, fajlok[] }`.
- Produces: test hook `PM_TESZT_KONFIG` – if set, `profil_mentes.bat` calls that file right after `beallitasok.cmd`.

- [ ] **Step 1: Add the hook** to `profil_mentes.bat`: `if defined PM_TESZT_KONFIG call "%PM_TESZT_KONFIG%"`.
- [ ] **Step 2: `teszt_konfig.cmd`** sets `FIGYELT_PROGRAMOK=pm_nincs_ilyen.exe`, `KENYSZER_BEZARAS=`, `ATNEZ_IDOKORLAT_MP=5` (so the "running programs" prompt never appears and answers stay aligned).
- [ ] **Step 3: `profil_feltolt.ps1 -Cel <folder>`** builds a fake profile:
  `AppData\Roaming\Microsoft\Signatures\Aláírás – Dániel.htm`, `…\Templates\Sablon.dotx`, `PST\archívum 2024.pst` (1 MB random),
  `AppData\Local\Google\Chrome\User Data\Default\{Preferences,Bookmarks}`, `…\Profile 1\Preferences`,
  `…\User Data\Local State` = `{"os_crypt":{"encrypted_key":"x"},"profile":{"info_cache":{"Default":{"name":"Dániel"},"Profile 1":{"name":"Munka – ő ű"}}}}`,
  `AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin`, and the folder `Saját adatok – Dániel\jegyzet.txt`.
- [ ] **Step 4: `futtat.ps1`**:
  1. seed the profile in `%TEMP%\pm_teszt\profil` if missing; `subst` the first free letter T–Z to `%TEMP%\pm_teszt\kulso`;
  2. child environment: `USERPROFILE`, `APPDATA`, `LOCALAPPDATA` → fake profile, `TEMP`/`TMP` → `%TEMP%\pm_teszt\tmp`, `VALASZ_SORBOL=1`, `PM_TESZT_KONFIG` → `teszt_konfig.cmd`;
  3. answer file: replace `{BETU}` with the drive letter and `{MENTES}` with the number of the backup in the list;
  4. run `cmd /c "chcp <Kodlap> >nul & call profil_mentes.bat < answers > transcript 2>&1 & chcp"` with a 10-minute timeout; always remove the `subst` in `finally`;
  5. before any restore run, delete `C_TEMP` from the chosen backup so the real `C:\TEMP` is never written; before a save run, print a warning if the real `C:\TEMP` is larger than 1 GB (the save reads it).
- [ ] **Step 5: answer files** (current menu numbers; Task 4 renumbers them), one answer per line:
  - `mentes.txt`: 1, I, `{BETU}`, F, I, 10× N – the `F` answers the Outlook "PST outside the PST folder" prompt if this machine has one; at an I/N prompt `:VALASZT` skips it, so it is safe either way.
  - `probafuttatas.txt`: 4, I, `{BETU}`, I, 10× N.
  - `visszaallitas.txt`: 2, I, `{BETU}`, `{MENTES}`, N (icons), I (start), I (Chrome profile list – Chrome comes before the Start menu in `config\tetelek.cmd`), N (Start menu restart), 10× N. Fájlkezelő – Gyorselérés is skipped (the fake profile has no such file), so its restart prompt never appears.
  - `laptop_megse.txt`: 3, N, N. `alapalk_ellenoriz.txt`: 5, I, 10× N.
  - `hibas_bevitel.txt`: 1, I, `QQ`, `C`, `{BETU}`, N. `visszaallitas_hibas.txt`: 2, I, `{BETU}`, `x`, `99`, `{MENTES}`, N, N.
  The trailing N answers cover the conditional end prompts; any left over are ignored.
- [ ] **Step 6: `ellenoriz.ps1`**, after stripping `ESC[…m`:
  - BEL character (0x07) present → problem
  - mojibake `Ã|Å|Ĺ|Ă|â€|\uFFFD` → problem
  - line longer than 76 that contains no `:\` and no `\\` → problem
  - parser errors `unexpected at this time|not recognized as an internal|cannot find the batch label|nem várt|kötegcímke` → problem
  - `-Vege`: the text must appear in the last 15 lines; `-Kredit`: `Készítette: Kakuk Dániel` must appear
  - `-Szoveg`: split lines into tokens on whitespace and `,;()[]?“”`, skip tokens containing `_ \ . :`, lowercase them, and flag tokens starting with an unaccented stem (`felhasznalo szamitogep jogosultsag valaszt mentese visszaallit ellenoriz ellenorz osszegz teendo idotartam kesz meghajto kulso fajl folytatas megszakit tetel eleg masol bezar inditas beallit alapertelmezett`) or that are formal (magázó) forms – the tool uses tegezés (`válasszon adjon nyomjon húzza indítsa másolja ellenőrizze nézze válaszoljon formázza használjon jelentkezzen törölje állítsa rögzítse kövesse csatolja vesse írja javítsa zárja kapcsolja`).
- [ ] **Step 7: `eredmeny.ps1`** reads the counts with `(Sikeres|Rendben):\s*(\d+)\D+(Hib\S*|Probl\S*):\s*(\d+)\D+Kihagyva:\s*(\d+)` and, with `-Mentes`, lists files relative to the backup folder with these names normalized: `_LEFT-TO-DO.txt`→`_TEENDOK.txt`, `*_log.txt`→`*_naplo.txt`, `_MENTES_*.txt`→`_MENTES.txt`, `_EXPORT_*`/`_VISSZAALLITAS_*`→`_VISSZAALLITAS.txt`.
- [ ] **Step 8: Baseline** with the current version: run `mentes`, `probafuttatas`, `visszaallitas`; save the `eredmeny.ps1` JSON to `alap\<name>.json` and copy the backup folder to `alap\mentes_regi\` (used again in Task 8).
  Expected: all three reach the summary; `mentes` and `visszaallitas` have `hibas` = 0.
- [ ] **Step 9:** Commit `test: scripted test environment and baseline`.

### Task 2: UTF-8 foundation, code page restore, no beep

**Files:** Modify `profil_mentes\profil_mentes.bat`, `lib\teendok.cmd` (remove `:KODLAP_UTF8`/`:KODLAP_VISSZA` and their calls), `lib\osszegzes.cmd:100-101,149`, `lib\ikonok.cmd:249`, `lib\alapalk.cmd:305`, `lib\masolas.cmd` (only if Step 5 says so)

**Interfaces:**
- Produces: `PM_KODLAP` (original code page), `PS_FUTTAT` now forces UTF-8 output.

- [ ] **Step 1: Tests:** (a) `ellenoriz.ps1` on the `mentes` transcript must find no BEL; (b) `futtat.ps1 -Valaszok mentes -Kodlap 852` must end with a line containing `852` – this passes today and must keep passing after the switch to 65001.
- [ ] **Step 2: Run** `futtat.ps1 -Valaszok mentes` then `ellenoriz.ps1 -Atirat …` → expected FAIL: BEL found (`osszegzes.cmd:101`).
- [ ] **Step 3: Implement:**
  - `profil_mentes.bat` lines 1–3: `@echo off`, read the code page into `PM_KODLAP` with the `for /f "tokens=2 delims=:."` + `chcp ^<nul` pattern from `teendok.cmd:650`, then `chcp 65001 >nul <nul`. Restore it with `chcp %PM_KODLAP% >nul <nul` before both `exit /b` lines.
  - `PS_FUTTAT` command starts with `[Console]::OutputEncoding=[Text.Encoding]::UTF8;`; the same prefix goes into the inline `powershell` calls in `ikonok.cmd` and `alapalk.cmd`.
  - Delete the two `forfiles … 0x07` lines and their comment in `osszegzes.cmd`.
  - Remove the code page switching from `teendok.cmd` (the whole run is UTF-8 now).
- [ ] **Step 4: Accent round trip test:** after `mentes`, assert with PowerShell that `…\Signatures\Aláírás – Dániel.htm` and `PST\archívum 2024.pst` exist in the backup with equal SHA256, that `Chrome_mentes\profilok.json` contains `Munka – ő ű` and not `encrypted_key`, and that the transcript and `_LEFT-TO-DO.txt` show `Saját adatok – Dániel`.
- [ ] **Step 5: Robocopy log encoding:** read `mentes_log.txt` as UTF-8 and look for `archívum 2024.pst`. If robocopy's own lines come out garbled, `masolas.cmd` writes robocopy's log to `%LOG:.txt=_robocopy.txt%` with `/UNILOG+:` instead of `/LOG+:`, and the main log gets one line `Robocopy részletei: <file>`. Record which case applied in the commit message.
- [ ] **Step 6: Run all answer files:** `ellenoriz.ps1` without `-Szoveg` → 0 problems each; `eredmeny.ps1` counts and file lists equal `alap\*.json`; the `-Kodlap 852` run ends with `852`.
- [ ] **Step 7: Manual key reader check** in a real console (double-click `profil_mentes.bat`): at the first I/N prompt press Enter, `x`, then `i` → no sound, nothing until `i`, which is accepted; repeat with `N`.
- [ ] **Step 8:** Commit `feat: run in UTF-8, restore code page, remove beep`.

### Task 3: UI kit and screen gallery

**Files:**
- Modify: `profil_mentes\lib\ui.cmd`
- Create: `tesztkornyezet\kepernyok.cmd`, `tesztkornyezet\valaszok\kepernyok.txt`

**Interfaces** (all `%UI% :NAME …`; widths and texts from spec §5):
- `:CIM "screen title"` – header of spec §5.2; sets `UI_BEHUZAS` to 2 spaces.
- `:NYITO` – the start-screen box of spec §5.1, using `VERZIO`.
- `:SZAKASZ "A RÉGI GÉPEN"` – `  ── TEXT ───…` to column 72.
- `:VONAL` – 2 spaces + 70 × `─`.
- `:ADAT "label" "value" [SARGA]` – 5 spaces, label padded to 16, value (optionally yellow).
- `:MENU "key" "label" "description"` – 5 spaces, key, 3 spaces, label padded to 30, description.
- `:LABLEC NYITO|TELJES` – `:VONAL`, then `     Készítette: %SZERZO%` or `     Eszközcsere segédlet %VERZIO%  ·  Készítette: %SZERZO%`.
- `:FEJLEC "name"` – `  [ n/N]  name` (n right-aligned to 2), window title `[n/N] name – %MOD_NEV%`, log line; sets `UI_BEHUZAS` to 11 spaces. No "folyamatban..." line.
- `:RESZLET "text"` – `UI_BEHUZAS` + grey text; also written to the log.
- `:JELOL OK|HIBA|KIHAGYVA|NEMKERT "message" ["detail"]` – 11 spaces, 10-character tag, 2 spaces, message; detail via `:RESZLET`. Stores `E_n`, `M_n`, `D_n`.
- `:OSSZ_SOR n` – spec §5.4 row; message cut at 33 with `…`; file line `[STATUS] name – message[ – detail]`.
- `:SAV OK|HIBA|FIGYEL "text"` – a band 70 wide after 2 spaces, background colour; yellow plain line for `FIGYEL`; no colours → plain text.
- `:VALASZT letters "question" [N]` – prints `UI_BEHUZAS` + `› ` + question + ` [I/N] ` (letters joined with `/`); errorlevel, `VALASZ_SORBOL` and the silent reader unchanged. Callers pass the question with its `?` and without leading spaces.
- `:PAD var length`, `:VAG var length` – pad with spaces / cut with `…`, counting characters.
- Unchanged: `:MB_GB`, `:IDO`, `:SZINEK_BEALLIT`.
- Consumes: `VERZIO=1.0`, `SZERZO=Kakuk Dániel` – set near the top of `profil_mentes.bat` in this task.

- [ ] **Step 1: Gallery first:** `kepernyok.cmd` sets the same `APP/LIB/UI…` variables as `profil_mentes.bat`, then draws every routine above with sample data: all four tags with and without detail, a 40-character message (must be cut), three summary rows, all three bands, both footers, one yes/no prompt.
- [ ] **Step 2: Run** `cmd /c "kepernyok.cmd < valaszok\kepernyok.txt > kimenet\kepernyok.txt"` → expected FAIL (routines missing).
- [ ] **Step 3: Implement** the routines in `ui.cmd`; the frame strings are written out literally in the file (no loops). Colour rules from spec §5.
- [ ] **Step 4: Verify:** `ellenoriz.ps1 -Atirat kimenet\kepernyok.txt -Kredit` → 0 problems; a PowerShell assertion that every `═`/`─` rule and box line is exactly 72 characters and every summary row is ≤ 76.
- [ ] **Step 5: Look at it:** double-click `kepernyok.cmd` in Windows Terminal and in a classic console (`conhost.exe cmd /c kepernyok.cmd`); compare with the spec mockups. Fix spacing until it matches.
- [ ] **Step 6:** Commit `feat: UI kit and screen gallery`.

### Task 4: Start screen, menu order, version and credit

**Files:**
- Create: `profil_mentes\lib\kezdokepernyo.cmd` (`:MUTAT`)
- Rename: `modulok\export.cmd` → `modulok\visszaallitas.cmd`
- Modify: `profil_mentes.bat` (menu and module table), `lib\osszegzes.cmd` (every `"%MOD%"=="n"` test), `tesztkornyezet\valaszok\*.txt`, `tesztkornyezet\kepernyok.cmd`

**Interfaces:**
- Produces: `MODUL` (`mentes`, `visszaallitas`, `laptop`, `alapalk`) and `TESZTMOD` are the only state later code uses to know the menu; `MOD` is no longer read outside `profil_mentes.bat`.
- Produces: `%KEZDO% :MUTAT` draws spec §5.1 including the four `:ADAT` lines; `Jogosultság` is `normál felhasználó` or yellow `rendszergazda`. `KEZDO` is defined in `profil_mentes.bat` next to the other shortcuts (`set KEZDO=call "%LIB%\kezdokepernyo.cmd"`), and the gallery defines it the same way.

- [ ] **Step 1: Tests first:** renumber the answer files (spec D2: 1 save, 2 test run, 3 restore, 4 laptop, 5 default apps); add `ellenoriz.ps1 -Kredit` to every run; add the start screen to the gallery.
- [ ] **Step 2: Run** `mentes` → expected FAIL: no credit, and the restore answer file now lands in the laptop menu.
- [ ] **Step 3: Implement:** menu text and descriptions from spec §6 via `:SZAKASZ`/`:MENU`; prompt `Válassz menüpontot [1–5]:` with `:VALASZT 12345 … N`; the table `key → MOD_NEV + MODUL (+ TESZTMOD)`; `osszegzes.cmd` switches on `MODUL`/`TESZTMOD`; window title `Eszközcsere segédlet – %MOD_NEV%` after the choice; cancel text and yellow line from spec §6.
- [ ] **Step 4: Verify:** every answer file → `ellenoriz.ps1 -Kredit` 0 problems; counts and file lists equal the baseline.
- [ ] **Step 5:** Commit `feat: start screen, workflow menu order, version and credit`.

### Task 5: Wording – save and test run

**Files:** Modify `modulok\mentes.cmd`, `lib\ellenorzes.cmd`, `lib\outlook.cmd`, `lib\atnezendo.cmd`, `lib\masolas.cmd`, `lib\tetelek.cmd` (`:LISTA` uses `:PAD`), `lib\tipusok\MAPPA.cmd`, `lib\tipusok\FAJL.cmd` (`:MENT` and `:FAJL`), `lib\tipusok\BONGESZO.cmd` (`:MENT`, `:PROFILLISTA_MENT`), `lib\programlista.cmd`, `lib\talca.cmd`, `config\tetelek.cmd` (names column), `ps\atnezendo.ps1` (the lines it prints)

- [ ] **Step 1: Test:** `probafuttatas`, `mentes`, `hibas_bevitel` with `-Szoveg` → expected FAIL (unaccented words).
- [ ] **Step 2: Rewrite** every user-visible string in these files following spec §3, the glossary and the name table in spec §6; copy results from the `masolas.cmd` table in spec §6; dynamic lists (profile names, running programs, measured folders) become `:RESZLET` lines and the message becomes a count, e.g. `2 profil, ellenőrizve`; multiple-choice prompts follow the options-line pattern of spec §5 (`U – újraellenőrzés    B – bezárás    F – folytatás így`, `M – megszakítás    F – folytatás így`).
- [ ] **Step 3: Verify:** the three runs with `-Szoveg` → 0 problems; counts equal the baseline; the `hibas_bevitel` transcript shows both drive-letter errors and then continues.
- [ ] **Step 4:** Commit `feat: wording for save and test run`.

### Task 6: Wording – restore

**Files:** Modify `modulok\visszaallitas.cmd`, `lib\ikonok.cmd`, `lib\tipusok\BONGESZO.cmd` (`:VISSZA`, `:PROFILLISTA_VISSZA`), `lib\tipusok\FAJL.cmd` (`:VISSZA`, `:UTANA_*`), `config\parancsikonok.cmd` (display names stay program names)

- [ ] **Step 1: Test:** `visszaallitas`, `visszaallitas_hibas` with `-Szoveg` → expected FAIL.
- [ ] **Step 2: Rewrite** the strings. The "someone else's backup" warning has no article before the name: `Ez a mentés nem ennek a felhasználónak készült: <folder>`. The browser prompt names no browser with an article: `<Chrome> ezen a gépen már futott. …`.
- [ ] **Step 3: Verify:** both runs → 0 problems with `-Szoveg`; counts equal the baseline; in the fake profile `Local State` contains `Munka – ő ű` and a `Local State.regi` exists.
- [ ] **Step 4:** Commit `feat: wording for restore`.

### Task 7: Wording – laptop and default apps

**Files:** Modify `modulok\laptop.cmd`, `lib\laptop.cmd`, `modulok\alapalk.cmd`, `lib\alapalk.cmd`, `config\alapertelmezett_alk.cmd` (group and check names only; ProgIds untouched)

- [ ] **Step 1: Test:** `laptop_megse`, `alapalk_ellenoriz` with `-Szoveg` → expected FAIL.
- [ ] **Step 2: Rewrite** the strings. Lid texts use Windows' wording: `Fedél lehajtásakor: Nincs művelet – hálózatról és akkumulátorról is`. The default-apps intro explains the Windows rule in two sentences; the OK message is a count (`4 program beállítva`), the program names go to a detail line.
- [ ] **Step 3: Verify:** both runs → 0 problems. Real laptop and admin runs happen in Task 10.
- [ ] **Step 4:** Commit `feat: wording for laptop and default apps`.

### Task 8: Summary screens and the files the tool writes

**Files:** Modify `lib\osszegzes.cmd`, `lib\teendok.cmd`, `ps\outlook_lista.ps1`, `ps\talca.ps1`, `modulok\*.cmd` (log file names), `tesztkornyezet\kepernyok.cmd`

**Interfaces:**
- Consumes: `:OSSZ_SOR`, `:SAV`, `:LABLEC TELJES` (Task 3); `D_n` (detail) for the summary file and `_TEENDOK.txt`.

- [ ] **Step 1: Tests:** gallery shows the three summary cases and the test-run summary; new test `regi_mentes`: copy `alap\mentes_regi\` to the fake drive, run `visszaallitas` on it, assert `_LEFT-TO-DO.txt` got the result section, no `_TEENDOK.txt` was created there, only one `_VISSZAALLITAS_*.txt` exists and no `_EXPORT_*.txt`.
- [ ] **Step 2: Run** → expected FAIL.
- [ ] **Step 3: Implement:** summary layout of spec §5.4 and banners of spec §6; the test-run summary uses `Rendben / Probléma / Kihagyva`; `_TEENDOK.txt` gets accented headings, every manual task as `[ ]` checkbox, dates as `2026. 10. 27.` and the product footer; `outlook_lista.txt` and `talca.txt` texts accented with the same footer; renamed files from spec §6; restore uses `_TEENDOK.txt`, else an existing `_LEFT-TO-DO.txt`.
- [ ] **Step 4: Verify:** all answer files with `-Szoveg -Kredit` → 0 problems; `regi_mentes` passes; open `_TEENDOK.txt` and `outlook_lista.txt` in Notepad – accents correct, footer present.
- [ ] **Step 5:** Commit `feat: summary screens and written documents`.

### Task 9: README, wording review list, memory

**Files:** Modify `profil_mentes\README.md`; create `tesztkornyezet\szovegjegyzek.ps1`, output `docs\szovegjegyzek.md`

- [ ] **Step 1: README:** title, `Verzió: 1.0`, `Készítette: Kakuk Dániel`; a short "Használat" section for colleagues (old machine → new machine, in menu order); developer rules updated: UTF-8 instead of ASCII, the `!`/`)` rules, `%UI%` routines list, `PM_TESZT_KONFIG`, how to run `tesztkornyezet`.
- [ ] **Step 2: Wording list:** `szovegjegyzek.ps1` collects every text passed to `echo`, `:CIM`, `:FEJLEC`, `:JELOL`, `:RESZLET`, `:VALASZT`, `:SAV`, `:MENU`, `:ADAT` plus the item names, as a table `file:line | text` in `docs\szovegjegyzek.md`, so the whole wording can be proofread in one place (by you, and by anyone you ask).
- [ ] **Step 3:** Update memory: the tool is UTF-8 now (not ASCII-only), company-wide, credit and tone decisions.
- [ ] **Step 4:** Commit `docs: README 1.0 and wording review list`.

### Task 10: Real-console walkthrough and screenshots

- [ ] **Step 1:** On a work laptop with Windows 10 (classic console) and one with Windows 11 (Terminal): save with a real external drive, test run, restore on a second device, laptop menu, default apps as admin, then as the user after logging out and in.
- [ ] **Step 2:** For each screen check against the spec mockups: alignment, colours, no wrapped lines in an 80-column window, no sound, the key reader works.
- [ ] **Step 3:** Screenshots (Win+Shift+S) of the start screen, a run, a summary with all OK and one with an error, for the presentation.
- [ ] **Step 4:** Fix findings, rerun the whole `tesztkornyezet`, commit `release: Eszközcsere segédlet 1.0`.
