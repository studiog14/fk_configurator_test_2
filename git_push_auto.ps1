Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Git Auto Push"
$form.Size = New-Object System.Drawing.Size(600,400)

# Repo ComboBox
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = '20,20'; $combo.Size = '400,20'
$form.Controls.Add($combo)

# CheckBoxes
$chkCore = New-Object System.Windows.Forms.CheckBox
$chkCore.Text = "Core Files"; $chkCore.Location = '20,60'; $form.Controls.Add($chkCore)
$chkChairs = New-Object System.Windows.Forms.CheckBox
$chkChairs.Text = "Chairs"; $chkChairs.Location = '150,60'; $form.Controls.Add($chkChairs)
$chkTextures = New-Object System.Windows.Forms.CheckBox
$chkTextures.Text = "Textures"; $chkTextures.Location = '280,60'; $form.Controls.Add($chkTextures)

# Log TextBox
$log = New-Object System.Windows.Forms.TextBox
$log.Location = '20,100'; $log.Size = '540,240'; $log.Multiline = $true; $log.ScrollBars = 'Vertical'
$form.Controls.Add($log)

# Push Button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Push"; $btn.Location = '20,350'; $btn.Size = '100,30'
$form.Controls.Add($btn)

# Funkcja pobierająca repo
function Get-Repos {
    $token = $env:GITHUB_TOKEN
    $headers = @{ Authorization = "token $token" }
    $repos = Invoke-RestMethod -Uri "https://api.github.com/user/repos?per_page=100" -Headers $headers
    $combo.Items.Clear()
    foreach ($r in $repos) { $combo.Items.Add($r.name) }
    $combo.Items.Add("Create new repository")
}

# Funkcja push
$btn.Add_Click({
    $repo = $combo.SelectedItem
    if (-not $repo) { [System.Windows.Forms.MessageBox]::Show("Select a repository!") ; return }
    $pushCore = $chkCore.Checked
    $pushChairs = $chkChairs.Checked
    $pushTextures = $chkTextures.Checked
    # tutaj logika pushowania z --force
    $log.AppendText("Pushing to $repo ...`r`n")
})

# Wczytaj repo przy starcie
Get-Repos

[void]$form.ShowDialog()
