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
$chkCore = New-Object System.Windows.Forms.CheckBox
$chkCore.Text = "Core Files"; $chkCore.Location = '20,60'; $chkCore.ForeColor = [System.Drawing.Color]::White; $chkCore.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($chkCore)

$chkChairs = New-Object System.Windows.Forms.CheckBox
$chkChairs.Text = "Chairs"; $chkChairs.Location = '150,60'; $chkChairs.ForeColor = [System.Drawing.Color]::White; $chkChairs.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($chkChairs)

$chkTextures = New-Object System.Windows.Forms.CheckBox
$chkTextures.Text = "Textures"; $chkTextures.Location = '280,60'; $chkTextures.ForeColor = [System.Drawing.Color]::White; $chkTextures.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($chkTextures)

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

    $pushCore = $chkCore.Checked
    $pushChairs = $chkChairs.Checked
    $pushTextures = $chkTextures.Checked

    if (-not ($pushCore -or $pushChairs -or $pushTextures)) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one type to push!"); return 
    }

    $log.AppendText("Starting push to $repoUrl ...`r`n")

    try {
        # Max buffer Git
        git config --global http.postBuffer 1572864000
        git config --global http.maxRequestBuffer 1572864000
        $log.AppendText("Git buffer set to ~1.5GB`r`n")

        $currentBranch = git rev-parse --abbrev-ref HEAD
        $log.AppendText("Current branch: $currentBranch`r`n")

        # ==========================
        # 1️⃣ Push plików głównych (Core)
        if ($pushCore) {
            $coreFiles = Get-ChildItem -File
            if ($coreFiles.Count -gt 0) {
                git add .  # dodaj wszystkie nowe pliki w głównym katalogu
                git commit -m "Auto commit core files" -q
                git push $repoUrl $currentBranch --force
                $log.AppendText("Pushed Core Files (main folder)`r`n")
            } else {
                $log.AppendText("No core files found, skipping.`r`n")
            }
        }

        # ==========================
        # 2️⃣ Push folderów (Chairs, Textures)
        $folders = @()
        if ($pushChairs) { $folders += "chairs" }
        if ($pushTextures) { $folders += "textures" }

        foreach ($f in $folders) {
            if (Test-Path $f) {
                git add $f -A
                git commit -m "Auto commit $f" -q
                git push $repoUrl $currentBranch --force
                $log.AppendText("Pushed folder $f (all new files)`r`n")
            } else {
                $log.AppendText("Folder $f not found, skipping.`r`n")
            }
        }

        # ==========================
        # 3️⃣ Push statycznych plików do gh-pages
        $tempDir = Join-Path -Path $env:TEMP -ChildPath "gh-pages-temp"
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        # automatycznie wykryj wszystkie statyczne pliki html/css/js w katalogu
        $staticFiles = Get-ChildItem -File | Where-Object { $_.Extension -match "(\.html|\.css|\.js)$" }
        foreach ($f in $staticFiles) {
            Copy-Item $f.FullName -Destination $tempDir
            $log.AppendText("Copied $($f.Name) to temp folder.`r`n")
        }

        Push-Location $tempDir
        git init
        git remote add origin $repoUrl
        git checkout -b gh-pages
        git add . -A
        git commit -m "Deploy static site" -q
        git push origin gh-pages --force
        Pop-Location
        Remove-Item $tempDir -Recurse -Force
        $log.AppendText("Static site pushed to gh-pages successfully!`r`n")

        $log.AppendText("All selected parts pushed successfully!`r`n")

    } catch {
        $log.AppendText("Error: $_`r`n")
    }
})

[void]$form.ShowDialog()
