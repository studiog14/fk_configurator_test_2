Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Git Auto Push + Pages"
$form.Size = New-Object System.Drawing.Size(600,450)
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
$log.Location = '20,100'; $log.Size = '540,300'; $log.Multiline = $true; $log.ScrollBars = 'Vertical'
$log.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$log.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($log)

# Push Button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Push"; $btn.Location = '20,410'; $btn.Size = '100,30'
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
        # Zwiększenie buforów Git
        git config --global http.postBuffer 1572864000
        git config --global http.maxRequestBuffer 1572864000
        $log.AppendText("Git buffer set to ~1.5GB`r`n")

        $currentBranch = git rev-parse --abbrev-ref HEAD
        $log.AppendText("Current branch: $currentBranch`r`n")

        # ==========================
        # 1️⃣ Push lokalnych zmian do main
        if ($chkPushMain.Checked) {
            # git add -A doda wszystkie nowe, zmienione i usunięte pliki
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
        # 2️⃣ Push statycznych plików do gh-pages
        if ($chkPushPages.Checked) {
            $tempDir = Join-Path -Path $env:TEMP -ChildPath "gh-pages-temp"
            if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
            New-Item -ItemType Directory -Path $tempDir | Out-Null

            # Kopiowanie wszystkich plików html/css/js z głównego katalogu
            $staticFiles = Get-ChildItem -File | Where-Object { $_.Extension -match "(\.html|\.css|\.js)$" }
            foreach ($f in $staticFiles) {
                Copy-Item $f.FullName -Destination $tempDir
                $log.AppendText("Copied $($f.Name) to temp folder.`r`n")
            }

            Push-Location $tempDir
            git init
            git remote add origin $repoUrl
            git checkout -b gh-pages
            git add -A
            git commit -m "Deploy static site" -q
            git push origin gh-pages --force
            Pop-Location
            Remove-Item $tempDir -Recurse -Force
            $log.AppendText("Static site pushed to gh-pages successfully!`r`n")
        }

        $log.AppendText("Git Auto Push completed successfully!`r`n")

    } catch {
        $log.AppendText("Error: $_`r`n")
    }
})

[void]$form.ShowDialog()
