Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Git Auto Push + Pages"
$form.Size = New-Object System.Drawing.Size(600,480)
$form.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)

# Repo TextBox
$txtRepo = New-Object System.Windows.Forms.TextBox
$txtRepo.Location = '20,20'; $txtRepo.Size = '540,20'
$txtRepo.BackColor = [System.Drawing.Color]::FromArgb(28,28,28)
$txtRepo.ForeColor = [System.Drawing.Color]::Gray
$txtRepo.Text = "Paste GitHub repository URL here"
$form.Controls.Add($txtRepo)

# Placeholder logic
$txtRepo.Add_Enter({
    if ($txtRepo.Text -eq "Paste GitHub repository URL here") {
        $txtRepo.Text = ""
        $txtRepo.ForeColor = [System.Drawing.Color]::White
    }
})
$txtRepo.Add_Leave({
    if ([string]::IsNullOrWhiteSpace($txtRepo.Text)) {
        $txtRepo.Text = "Paste GitHub repository URL here"
        $txtRepo.ForeColor = [System.Drawing.Color]::Gray
    }
})

# CheckBoxes
$chkPushMain = New-Object System.Windows.Forms.CheckBox
$chkPushMain.Text = "Push local changes to main"; $chkPushMain.Location = '20,60'; $chkPushMain.ForeColor = [System.Drawing.Color]::White; $chkPushMain.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$chkPushMain.Checked = $true
$form.Controls.Add($chkPushMain)

$chkPushPages = New-Object System.Windows.Forms.CheckBox
$chkPushPages.Text = "Push static files to gh-pages"; $chkPushPages.Location = '250,60'; $chkPushPages.ForeColor = [System.Drawing.Color]::White; $chkPushPages.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$chkPushPages.Checked = $true
$form.Controls.Add($chkPushPages)

# Log TextBox
$log = New-Object System.Windows.Forms.TextBox
$log.Location = '20,100'; $log.Size = '540,330'; $log.Multiline = $true; $log.ScrollBars = 'Vertical'
$log.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$log.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($log)

# Push Button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Push"; $btn.Location = '20,440'; $btn.Size = '100,30'
$btn.BackColor = [System.Drawing.Color]::FromArgb(70,70,70)
$btn.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btn)

# Push logic
$btn.Add_Click({
    $repoUrl = $txtRepo.Text.Trim()
    if (-not $repoUrl -or $repoUrl -eq "Paste GitHub repository URL here") { 
        [System.Windows.Forms.MessageBox]::Show("Paste repository URL!"); return 
    }

    $log.AppendText("Starting Git Auto Push...`r`n")

    try {
        # Git buffer
        git config --global http.postBuffer 1572864000
        git config --global http.maxRequestBuffer 1572864000
        $log.AppendText("Git buffer set to ~1.5GB`r`n")

        $currentBranch = git rev-parse --abbrev-ref HEAD
        $log.AppendText("Current branch: $currentBranch`r`n")

        # ==========================
        # 1️⃣ Push lokalnych zmian do main
        if ($chkPushMain.Checked) {
            git add -A
            $status = git status --porcelain
            if (-not [string]::IsNullOrWhiteSpace($status)) {
                git commit -m "Auto commit changes" -q
                git push $repoUrl $currentBranch --force
                $log.AppendText("Local changes pushed to $currentBranch`r`n")
            } else {
                $log.AppendText("No changes detected in local repo.`r`n")
            }
        }

        # ==========================
        # 2️⃣ Push wszystkich plików statycznych + folderów do gh-pages
        if ($chkPushPages.Checked) {
            $tempDir = Join-Path -Path $env:TEMP -ChildPath "gh-pages-temp"
            if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
            New-Item -ItemType Directory -Path $tempDir | Out-Null

            # Kopiujemy wszystkie pliki .html, .css, .js
            Get-ChildItem -File | Where-Object { $_.Extension -match "(\.html|\.css|\.js)$" } | ForEach-Object {
                Copy-Item $_.FullName -Destination $tempDir
                $log.AppendText("Copied $($_.Name) to temp folder.`r`n")
            }

            # Kopiujemy wszystkie foldery w katalogu projektu (np. chairs, textures)
            Get-ChildItem -Directory | ForEach-Object {
                Copy-Item $_.FullName -Destination $tempDir -Recurse
                $log.AppendText("Copied folder $($_.Name) to temp folder.`r`n")
            }

            # Tworzymy folder workflow i plik deploy-pages.yml
            $workflowDir = Join-Path $tempDir ".github\workflows"
            if (-not (Test-Path $workflowDir)) { New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null }
            $workflowFile = Join-Path $workflowDir "deploy-pages.yml"

            $workflowContent = @'
name: GitHub Pages

on:
  push:
    branches:
      - gh-pages

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
'@

            Set-Content -Path $workflowFile -Value $workflowContent -Force
            $log.AppendText("Workflow deploy-pages.yml created/updated.`r`n")

            Push-Location $tempDir
            git init
            git remote add origin $repoUrl
            git checkout -b gh-pages
            git add -A
            $statusPages = git status --porcelain
            if (-not [string]::IsNullOrWhiteSpace($statusPages)) {
                git commit -m "Deploy static site with workflow" -q
                git push origin gh-pages --force
                $log.AppendText("Static site pushed to gh-pages successfully!`r`n")
            } else {
                $log.AppendText("No changes detected in static files.`r`n")
            }
            Pop-Location
            Remove-Item $tempDir -Recurse -Force
        }

        $log.AppendText("Git Auto Push completed successfully!`r`n")

    } catch {
        $log.AppendText("Error: $_`r`n")
    }
})

[void]$form.ShowDialog()
