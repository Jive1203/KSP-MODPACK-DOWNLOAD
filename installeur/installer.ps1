# Installeur du modpack « KSP 2 dans KSP 1 » (lance par INSTALLER.cmd).
# 1. trouve Kerbal Space Program (Steam) ; 2. en fait une copie reservee au pack (le jeu habituel reste intact) ;
# 3. telecharge CKAN et installe les mods du pack, versions figees (ksp2-dans-ksp1.ckan) ;
# 4. copie les mods propres au pack (dossier GameData du depot) ; 5. raccourci « KSP MODPACK » sur le Bureau.
# Relancer l'installeur sur la meme copie la met a jour.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$depot = Split-Path -Parent $PSScriptRoot
$versionCkan = 'v1.36.2'

function Titre([string]$t) { Write-Host ''; Write-Host "=== $t ===" -ForegroundColor Cyan }
function Stop-Installeur([string]$t) { Write-Host ''; Write-Host $t -ForegroundColor Red; Read-Host 'Appuyez sur Entree pour fermer'; exit 1 }

Write-Host 'Modpack KSP 2 dans KSP 1 : installation' -ForegroundColor Green
Write-Host "Compter 25 Go d'espace libre et 30 a 60 minutes la premiere fois (17 Go de mods a telecharger)."

# ---------- 1. Le jeu
Titre '1. Recherche de Kerbal Space Program'
$candidats = New-Object System.Collections.Generic.List[string]
try {
    $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath
    if ($steam) {
        $candidats.Add((Join-Path $steam 'steamapps\common\Kerbal Space Program'))
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
                $candidats.Add((Join-Path ($m.Groups[1].Value -replace '\\\\', '\') 'steamapps\common\Kerbal Space Program'))
            }
        }
    }
} catch { }
foreach ($l in 'C:', 'D:', 'E:', 'F:') { $candidats.Add("$l\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program"); $candidats.Add("$l\SteamLibrary\steamapps\common\Kerbal Space Program") }
$source = $candidats | Where-Object { Test-Path (Join-Path $_ 'KSP_x64.exe') } | Select-Object -First 1
if (-not $source) {
    Write-Host 'Jeu introuvable automatiquement : choisissez le dossier qui contient KSP_x64.exe.'
    Add-Type -AssemblyName System.Windows.Forms
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    $d.Description = 'Dossier de Kerbal Space Program (celui qui contient KSP_x64.exe)'
    if ($d.ShowDialog() -ne 'OK') { Stop-Installeur 'Installation annulee.' }
    $source = $d.SelectedPath
}
if (-not (Test-Path (Join-Path $source 'KSP_x64.exe'))) { Stop-Installeur "Pas de KSP_x64.exe dans $source" }
$lisez = Join-Path $source 'readme.txt'
$version = if (Test-Path $lisez) { ([regex]::Match((Get-Content $lisez -Raw), '1\.\d+\.\d+')).Value } else { '?' }
Write-Host "Jeu trouve : $source (version $version)"
if ($version -notlike '1.12*') { Write-Host 'Attention : le pack est fait pour KSP 1.12. Tous les joueurs doivent avoir exactement la meme version.' -ForegroundColor Yellow }

# ---------- 2. La copie reservee au pack
Titre '2. Copie du jeu reservee au pack'
$parDefaut = Join-Path (Split-Path -Parent $source) 'KSP MODPACK'
if (Test-Path (Join-Path $source 'GameData\Chantiers')) { $parDefaut = $source }   # on relance l'installeur depuis la copie du pack
$r = Read-Host "Dossier du pack [Entree = $parDefaut]"
$cible = if ([string]::IsNullOrWhiteSpace($r)) { $parDefaut } else { $r.Trim('" ') }
$cible = [System.IO.Path]::GetFullPath($cible).TrimEnd('\')
$miseAJour = Test-Path (Join-Path $cible 'KSP_x64.exe')
if ($miseAJour) { Write-Host "Copie existante : mise a jour de $cible" }
else {
    $lecteur = [System.IO.Path]::GetPathRoot($cible)
    $libre = (Get-PSDrive -Name $lecteur.Substring(0, 1)).Free / 1GB
    if ($libre -lt 25) { Stop-Installeur ("Il faut 25 Go libres sur $lecteur (il y en a {0:N0})." -f $libre) }
    Write-Host "Copie de $source vers $cible (jeu de base seulement, sans vos mods ni vos parties)..."
    $exclus = 'GameData', 'saves', 'Ships', 'CKAN', 'Logs', 'thumbs', 'Screenshots', 'PluginData' | ForEach-Object { Join-Path $source $_ }
    robocopy $source $cible /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 /XD @exclus /XF KSP.log settings.cfg PartDatabase.cfg | Out-Null
    if ($LASTEXITCODE -ge 8) { Stop-Installeur "La copie du jeu a echoue (robocopy $LASTEXITCODE)." }
    foreach ($d in 'GameData\Squad', 'GameData\SquadExpansion', 'saves\scenarios', 'saves\training') {
        if (Test-Path (Join-Path $source $d)) { robocopy (Join-Path $source $d) (Join-Path $cible $d) /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null }
    }
    foreach ($d in 'Ships\VAB', 'Ships\SPH', 'saves') { New-Item -ItemType Directory -Force (Join-Path $cible $d) | Out-Null }
}

# ---------- 3. Les mods du pack, par CKAN
Titre '3. Mods du pack (CKAN)'
$ckanDir = Join-Path $cible 'CKAN-installeur'
New-Item -ItemType Directory -Force $ckanDir | Out-Null
$ckan = Join-Path $ckanDir 'ckan.exe'
if (-not (Test-Path $ckan)) {
    Write-Host "Telechargement de CKAN $versionCkan (outil officiel d'installation de mods de KSP, github.com/KSP-CKAN)..."
    Invoke-WebRequest "https://github.com/KSP-CKAN/CKAN/releases/download/$versionCkan/ckan.exe" -OutFile $ckan -UseBasicParsing
}
Write-Host 'Installation des mods (longue la premiere fois : environ 17 Go)...'
& $ckan update --gamedir $cible --headless 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Host "  $_" }
& $ckan install --gamedir $cible --headless --no-recommends -c (Join-Path $depot 'ksp2-dans-ksp1.ckan') 2>&1 | Tee-Object -FilePath (Join-Path $cible 'installation_ckan.log') | Select-Object -Last 6 | ForEach-Object { Write-Host "  $_" }
# En mode automatique, CKAN saute sans le dire les mods que plusieurs autres peuvent fournir : on les nomme
& $ckan install --gamedir $cible --headless --no-recommends ExtraPlanetaryLaunchpads ParallaxContinued-Planet-Textures ParallaxContinued-Scatter-Textures ParallaxContinued-Terrain-Textures Scatterer-config Scatterer-sunflare 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Host "  $_" }
if (-not (Test-Path (Join-Path $cible 'GameData\ModuleManager*.dll'))) { Write-Host 'Attention : ModuleManager absent, CKAN a peut-etre echoue : voir installation_ckan.log dans le dossier du pack.' -ForegroundColor Yellow }

# ---------- 4. Les mods propres au pack
Titre '4. Mods propres au pack'
foreach ($d in Get-ChildItem (Join-Path $depot 'GameData') -Directory) {
    Copy-Item $d.FullName (Join-Path $cible 'GameData') -Recurse -Force
    Write-Host "  $($d.Name)"
}

# ---------- 5. Raccourci
Titre '5. Raccourci sur le Bureau'
$lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'KSP MODPACK.lnk'
$w = New-Object -ComObject WScript.Shell
$s = $w.CreateShortcut($lnk)
$s.TargetPath = Join-Path $cible 'KSP_x64.exe'
$s.WorkingDirectory = $cible
$s.IconLocation = (Join-Path $cible 'KSP_x64.exe') + ',0'
$s.Save()
Write-Host "Raccourci : $lnk"

Write-Host ''
Write-Host 'Installation terminee.' -ForegroundColor Green
Write-Host 'Le premier lancement est long (jusqu''a 10 minutes). Le guide du pack : Guide_du_modpack.pdf dans ce dossier.'
Write-Host 'Pour jouer ensemble : fenetre « Partie en ligne » du menu principal (voir GameData\PartieEnLigne\PluginData\LISEZMOI.txt).'
Read-Host 'Appuyez sur Entree pour fermer'
