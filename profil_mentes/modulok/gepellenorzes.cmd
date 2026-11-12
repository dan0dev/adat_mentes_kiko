rem ==========================================================
rem  7. Gep ellenorzese - teljesitmeny, ho, memoria, lemez, akku, esemenynaplo
rem  Pillanatkep a gep allapotarol: ps\gepellenorzes.ps1 - a sajat kepernyojet
rem  maga irja. A naplo a naplok\gepellenorzes mappaba kerul a profil_mentes
rem  mellett; ha ott nem irhato, a felhasznalo TEMP mappajaba.
rem  A megfigyelo mod (X percig meri a hot es a terhelest) csak tippkent latszik
rem  a vegen: PowerShellbol, a -MonitorPerc parameterrel indul.
rem  Kilepesi kod: 4 = vegigment, rovid zaras
rem ==========================================================

cls
%UI% :CIM "Gép ellenőrzése"
echo   Teljesítmény, hő, memória, lemez, akku, eseménynapló – kb. fél perc.
if not "%ADMIN%"=="1" echo   !C_SARGA!Normál jogosultsággal fut – a hő és az akkukopás hiányozhat.!C_0!
echo.
%ESZK% :NAPLO_MAPPA
set "GE_NAPLOK=%ES_NAPLOK%\gepellenorzes"
set "PS_FAJL=%PSDIR%\gepellenorzes.ps1"
%PS_FUTTAT%

rem ---------- Tipp: megfigyelo mod ----------
rem Szovegkent toltve indul, mint a segedletben - a vegrehajtasi hazirend nem tiltja le
set "_ge_parancs=& ([scriptblock]::Create((Get-Content -Raw -Encoding UTF8 '%PSDIR%\gepellenorzes.ps1'))) -MonitorPerc 10"
echo.
%UI% :SZAKASZ "TIPP – MEGFIGYELŐ MÓD"
echo.
echo   Ha a gép csak terhelés alatt melegszik: van megfigyelő mód is – pl. 10
echo   percig 30 másodpercenként méri a hőt és a terhelést, Excelbe (CSV) is.
echo   Egy PowerShell ablakba másold be:
echo.
echo   !C_FEHER!!_ge_parancs!!C_0!
echo.
echo   A percek száma a -MonitorPerc után írható át, a mérés gyakorisága
echo   -IntervalMp 20 hozzáírásával. A napló: C:\Temp\GepEllenorzes
exit /b 4
