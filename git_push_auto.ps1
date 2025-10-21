# =========================================
# GIT AUTO PUSH SPLIT (PROJECT / CHAIRS / TEXTURES) - FORCE
# =========================================

Write-Host "Starting Git Auto Push..." -ForegroundColor Cyan
Write-Host "========================================="

# --- Konfiguracja ---
$RepoURL = Read-Host "Enter repository URL or leave empty to use default"
if (-not $RepoURL) { $RepoURL = "https://github.com/studiog14/cofigurator_test.git" }
$Branch = "main"
$LargeFileLimitMB = 100
$LargeFileLimitBytes = $LargeFileLimitMB * 1MB

# --- Funkcja push z retry ---
function Push-WithRetry {
    param(
        [string]$FolderName,
        [string]$CommitMsg
    )
    $Attempt = 1
    do {
        Write-Host "[$FolderName] Pushing: $CommitMsg (Attempt #$Attempt)"
        try {
            git add $FolderName/* 2>$null
            git commit -m "$CommitMsg" 2>$null
            git push origin $Branch --force
            return $true
        } catch {
            Write-Host "Push failed, retrying in 5s..."
            Start-Sleep -Seconds 5
            $Attempt++
        }
    } while ($Attempt -le 5)
    Write-Host "[ERROR] Push for $FolderName failed after 5 attempts"
    return $false
}

# --- Sprawdzanie dużych plików ---
Write-Host "[INFO] Checking for files above $LargeFileLimitMB MB..."
$Files = git ls-files
foreach ($file in $Files) {
    $fileTrim = $file.Trim()
    if ($fileTrim) {
        try {
            if (Test-Path -LiteralPath $fileTrim) {
                $size = (Get-Item -LiteralPath $fileTrim).length
                if ($size -gt $LargeFileLimitBytes) {
                    Write-Host "[WARNING] Large file detected: $fileTrim ($([math]::Round($size/1MB,2)) MB)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "[WARNING] Skipping file with invalid path: $fileTrim" -ForegroundColor Yellow
        }
    }
}

# --- Kolejne kroki push ---
$Steps = @(
    @{ Name="Project Core"; Path="."; Msg="Push Project Core files" },
    @{ Name="Chairs"; Path="chairs"; Msg="Push Chairs files" },
    @{ Name="Textures"; Path="textures"; Msg="Push Textures files" }
)

foreach ($step in $Steps) {
    Write-Host "-------------------------------------"
    Write-Host "[STEP] Pushing $($step.Name)..."
    Push-WithRetry -FolderName $step.Path -CommitMsg $step.Msg
}

Write-Host "========================================="
Write-Host "Git Auto Push finished."
Write-Host "Press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
