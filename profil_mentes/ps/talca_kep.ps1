# ==========================================================
#  Kep a talcarol - lib\talca.cmd futtatja a talca.txt utan
#  A fo kijelzo talcaja PNG-be, hogy az ikonok sorrendje es kinezete is meglegyen.
#  Bemenet: TALCA_KEP - a kimeneti PNG
#  Kimenet egy sor: OK, vagy NEM|<ok> - ilyenkor nincs kep, a talca.txt ettol meg kesz
# ==========================================================
$ErrorActionPreference = 'Stop'
try {
    Add-Type -AssemblyName System.Drawing
    Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public static class TalcaKep {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct APPBARDATA {
        public int cbSize; public IntPtr hWnd; public uint uCallbackMessage; public uint uEdge; public RECT rc; public IntPtr lParam; }
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr FindWindow(string cls, string title);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("shell32.dll")] public static extern UIntPtr SHAppBarMessage(uint msg, ref APPBARDATA d);
    // ABM_GETSTATE = 4, ABM_SETSTATE = 10, ABS_AUTOHIDE = 1
    public static uint Allapot() {
        APPBARDATA d = new APPBARDATA(); d.cbSize = Marshal.SizeOf(typeof(APPBARDATA));
        return (uint)SHAppBarMessage(4, ref d);
    }
    public static void Beallit(IntPtr talca, uint allapot) {
        APPBARDATA d = new APPBARDATA(); d.cbSize = Marshal.SizeOf(typeof(APPBARDATA));
        d.hWnd = talca; d.lParam = (IntPtr)allapot;
        SHAppBarMessage(10, ref d);
    }
}
'@
    # Valodi kepernyopontok - kulonben 125-150%-os nagyitasnal a kep elcsuszik
    [void][TalcaKep]::SetProcessDPIAware()
    $h = [TalcaKep]::FindWindow('Shell_TrayWnd', $null)
    if ($h -eq [IntPtr]::Zero -or -not [TalcaKep]::IsWindowVisible($h)) { 'NEM|a tálca nem látható'; exit 0 }
    $r = New-Object TalcaKep+RECT
    $allapot = [TalcaKep]::Allapot()
    $rejtett = ($allapot -band 1) -ne 0
    try {
        # Automatikusan elrejtett talca: egy pillanatra kikapcsoljuk az elrejtest, a vegen visszaallitjuk
        if ($rejtett) {
            [TalcaKep]::Beallit($h, ($allapot -band (-bnot 1)))
            Start-Sleep -Milliseconds 800
        }
        [void][TalcaKep]::GetWindowRect($h, [ref]$r)
        $w = $r.Right - $r.Left; $hh = $r.Bottom - $r.Top
        $ki = 'NEM|a tálca nem látható'
        if ($w -ge 50 -and $hh -ge 10) {
            $kep = New-Object Drawing.Bitmap $w, $hh
            $g = [Drawing.Graphics]::FromImage($kep)
            $g.CopyFromScreen($r.Left, $r.Top, 0, 0, (New-Object Drawing.Size $w, $hh))
            $g.Dispose()
            $kep.Save($env:TALCA_KEP, [Drawing.Imaging.ImageFormat]::Png)
            $kep.Dispose()
            $ki = 'OK'
        }
    } finally {
        if ($rejtett) { [TalcaKep]::Beallit($h, $allapot) }
    }
    $ki
} catch {
    # Pl. zarolt kepernyo vagy tavoli asztal minimalizalva - ilyenkor nincs mit lefenykepezni
    'NEM|a képernyő nem érhető el'
}
