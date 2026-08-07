# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Import-Module posh-git
# $omp_config = Join-Path $PSScriptRoot "theme.omp.json"
# oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons
$themes = Get-TerminalIconsTheme
foreach ($theme in $themes) {
    if ([string]::IsNullOrEmpty($theme.Color.Name)) {
        $draculaTheme = Join-Path $PSScriptRoot "dracula.psd1"
        Add-TerminalIconsColorTheme -Force $draculaTheme
        Set-TerminalIconsTheme -ColorTheme dracula
    }
}

# PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle Listview

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Global fuzzy find files/dirs → open in nvim (alias: fe)
# Usage:
#   fe              → global search (home + frecent dirs from z)
#   fe readme       → same, with "readme" pre-filled in fzf
#   fe -Local       → search only under the current directory
#   fe -Path C:\x   → search only under C:\x
function Invoke-FuzzyNvim {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path,

        [Parameter()]
        [switch]$Local,

        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )

    $queryText = $null
    $searchRoots = [System.Collections.Generic.List[string]]::new()

    # Explicit -Path wins; -Local = cwd only; otherwise global roots
    if ($Path) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            Write-Error "Path not found: $Path"
            return
        }
        $searchRoots.Add((Resolve-Path -LiteralPath $Path).Path)
    } elseif ($Local) {
        $searchRoots.Add($PWD.Path)
    } else {
        # Global: entire user profile
        $home = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
        if ($home -and (Test-Path -LiteralPath $home)) {
            $searchRoots.Add((Resolve-Path -LiteralPath $home).Path)
        }

        # Also include frecent directories from z (covers other drives / paths outside home)
        if (Get-Variable -Name history -Scope Global -ErrorAction SilentlyContinue) {
            $homePrefix = $searchRoots[0]
            foreach ($entry in @($global:history)) {
                $dir = $null
                if ($null -eq $entry) { continue }
                if ($entry.Path -and $entry.Path.PSObject.Properties['FullName']) {
                    $dir = $entry.Path.FullName
                } elseif ($entry.Path) {
                    $dir = "$($entry.Path)"
                }
                if (-not $dir) { continue }
                if (-not (Test-Path -LiteralPath $dir -PathType Container)) { continue }

                # Skip dirs already covered by home (fd will recurse home fully)
                if ($homePrefix -and $dir.StartsWith($homePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $searchRoots.Add($dir)
            }
        }
    }

    if ($searchRoots.Count -eq 0) {
        Write-Error "No search roots available."
        return
    }

    # Deduplicate while preserving order
    $uniqueRoots = [System.Collections.Generic.List[string]]::new()
    $seen = @{}
    foreach ($r in $searchRoots) {
        $key = $r.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $uniqueRoots.Add($r)
        }
    }

    if ($Query -and $Query.Count -gt 0) {
        $queryText = $Query -join ' '
    }

    $fdArgs = @(
        '--color', 'never'
        '--hidden'
        '--follow'
        '--absolute-path'
        # junk / caches (keeps a home-wide scan usable)
        '--exclude', '.git'
        '--exclude', 'node_modules'
        '--exclude', '.venv'
        '--exclude', 'venv'
        '--exclude', '__pycache__'
        '--exclude', 'dist'
        '--exclude', 'build'
        '--exclude', '.next'
        '--exclude', '.cache'
        '--exclude', '.npm'
        '--exclude', '.nuget'
        '--exclude', '.cargo'
        '--exclude', 'AppData'
        '--exclude', 'Application Data'
        '--exclude', 'Cookies'
        '--exclude', 'Local Settings'
        '--exclude', 'Recent'
        '--exclude', 'SendTo'
        '--exclude', 'Start Menu'
        '--exclude', 'Templates'
        '--exclude', 'NTUSER.DAT'
        '--exclude', 'ntuser.dat.LOG1'
        '--exclude', 'ntuser.dat.LOG2'
        '.'
    ) + @($uniqueRoots)

    # Preview: list dir contents, or first lines of a file
    $previewCmd = "powershell -NoProfile -Command `"`$p = '{}'; if (Test-Path -LiteralPath `$p -PathType Container) { Get-ChildItem -LiteralPath `$p -ErrorAction SilentlyContinue | Select-Object -First 40 -ExpandProperty Name } else { Get-Content -LiteralPath `$p -TotalCount 80 -ErrorAction SilentlyContinue }`""

    $scopeLabel = if ($Local) { 'local' } elseif ($Path) { 'path' } else { 'global' }
    $fzfArgs = @(
        '--height', '50%'
        '--layout', 'reverse'
        '--border'
        '--preview-window', 'right:50%:wrap'
        '--preview', $previewCmd
        '--bind', 'ctrl-/:toggle-preview'
        '--prompt', "nvim ($scopeLabel)> "
        '--header', 'Enter: open in nvim | Ctrl-/: toggle preview | Esc: cancel'
    )

    if ($queryText) {
        $fzfArgs += @('--query', $queryText)
    }

    $selection = & fd @fdArgs 2>$null | & fzf @fzfArgs
    if ([string]::IsNullOrWhiteSpace($selection)) { return }

    if (Test-Path -LiteralPath $selection) {
        nvim -- $selection
    } else {
        Write-Error "Selection no longer exists: $selection"
    }
}
Set-Alias -Name fe -Value Invoke-FuzzyNvim

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
# Prefer USERPROFILE on Windows — $HOME is often unset in pwsh
if (-not $env:HOME) { $env:HOME = $env:USERPROFILE }
$env:XDG_CONFIG_HOME = Join-Path $env:USERPROFILE ".config"

# Get Files
function List-Tree {
    param (
        [string]$Path = $PWD.Path,
        [int]$Indent = 0
    )
    $items = Get-ChildItem -Path $Path -Force | Sort-Object PSIsContainer, Name
    foreach ($item in $items) {
        # Set an icon for files and folders
        $icon = if ($item.PSIsContainer) { " " } else { "󰈙 " }
        $prefix = (" " * $Indent) + ($item.PSIsContainer ? "├── " : "│   ")
        $name = $item.Name  # Display only the name of the file or folder

        # Output the item with the icon and color
        Write-Host "$prefix$icon$name" -ForegroundColor ($item.PSIsContainer ? "Yellow" : "White")
        
        # If it's a directory, recurse into it
        if ($item.PSIsContainer) {
            List-Tree -Path $item.FullName -Indent ($Indent + 4)
        }
    }
}

# Alias for the function
Set-Alias -Name lla -Value List-Tree


# Alias
Set-Alias -Name vim -Value nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias rm Remove-Item
Set-Alias rmrf Remove-Item -Force
Set-Alias mv Move-Item
Set-Alias lla eza_func_l
Set-Alias lls eza_func_a
Set-Alias touch New-Item
Set-Alias op opencode

# Functions
function eza_func_l {eza -l}
function eza_func_a {eza -a}

function lv {live-server}


function proj($name) {
    mkdir $name
    cd $name
    git init
  }

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Must be set before starship runs so the prompt + CLI both load the right file
$env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE ".config\starship.toml"
Invoke-Expression (&starship init powershell)
