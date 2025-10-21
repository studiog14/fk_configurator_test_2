# =========================================
# GIT AUTO PUSH SPLIT + GITHUB REPO SELECT
# =========================================

# --- CONFIG ---
$GitHubToken = "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"
$GitHubUser = "TWOJ_LOGIN_GITHUB"  # Twój login GitHub
$MaxFileSizeMB = 100
$MaxFileSizeBytes = $MaxFileSizeMB * 1MB

$FoldersToPush = @(
    @{Name="Project Core"; Path="."},
    @{Name="Chairs"; Path="chairs"},
    @{Name="Textures"; Path="textures"}
)

# --- FUNCTIONS ---
function Get-GitHubRepos {
    Write-Host "[INFO] Fetching repositories from GitHub..."
    $headers = @{ Authorization = "token $GitHubToken" }
    $repos = Invoke-RestMethod -Uri "https://api.github.com/user/repos?per_page=100" -Headers $headers
    return $repos | Select-Object -Property name, ssh_url, clone_url
}

function Choose-Repo {
    $repos = Get-GitHubRepos
    Write-Host "`nSelect repository to push:"
    for ($i=0; $i -lt $repos.Count; $i++) {
        Write-Host "$($i+1)) $($repos[$i].name)"
    }
    Write-Host "$($repos.Count+1)) Create new repository"

    $choice = Read-Host "Enter number"
    if ($choice -eq ($repos.Count+1)) {
        $newName = Read-Host "Enter new repository name"
        $repo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers @{ Authorization = "token $GitHubToken" } -Method POST -Body (@{name=$newName} | ConvertTo-Json)
        Write-Host "[INFO] Created new repository $newName"
        return $repo.clone_url
    } else {
        return $repos[$choice-1].clone_url
    }
}

function Push-WithRetry($Folder, $Msg) {
    $Attempt = 1
    do {
        try {
            Write-Host "[INFO] [$Folder] Pushing: $Msg (Attempt #$Attempt)"
            git add $Folder
            git commit -m "$Msg"
            git push origin main
            return $true
        } catch {
            Write-Host "[WARN] Push failed, retrying..."
            Start-Sleep -Seconds 5
            $Attempt++
        }
    } while ($Attempt -le 5)
    Write-Host "[ERROR] Failed to push $Folder after 5 attempts."
    return $false
}

function Check-LargeFiles {
    Write-Host "[INFO] Checking for files above $MaxFileSizeMB MB..."
    foreach ($Folder in $FoldersToPush) {
        Get-ChildItem -Path $Folder.Path -Recurse -File | ForEach-Object {
            try {
                if ($_.Length -ge $MaxFileSizeBytes) {
                    Write-Host "[WARNING] Large file: $($_.FullName) - $([math]::Round($_.Length/1MB,2)) MB"
                }
            } catch { }
        }
    }
}

# --- SCRIPT START ---
Write-Host "========================================="
Write-Host " GIT AUTO PUSH SPLIT (PROJECT / CHAIRS / TEXTURES)"
Write-Host "========================================="

# 1. Wybór repo
$RepoURL = Choose-Repo
Write-Host "[INFO] Using repository: $RepoURL"

# 2. Sprawdzenie dużych plików
Check-LargeFiles

# 3. Dodawanie remote (jeśli nie istnieje)
if (-not (git remote | Select-String origin)) {
    git remote add origin $RepoURL
}

# 4. Push folderów
foreach ($Folder in $FoldersToPush) {
    Write-Host "[STEP] Pushing $($Folder.Name)..."
    Push-WithRetry $Folder.Path "Push $($Folder.Name) files"
}

Write-Host "========================================="
Write-Host "Git Auto Push finished."
Write-Host "Press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
