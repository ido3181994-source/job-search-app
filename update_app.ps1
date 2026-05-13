# Embed fresh job_matches.json into index.html and push to GitHub Pages
$ErrorActionPreference = 'Stop'

$repoDir   = "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily"
$dataFile  = "D:\CV's\job_matches.json"
$indexFile = Join-Path $repoDir "index.html"

# Read source files
$json = (Get-Content $dataFile -Raw -Encoding UTF8).Trim()
$html = Get-Content $indexFile -Raw -Encoding UTF8

# Replace the DATA line — matches the entire line starting with "const DATA ="
$html = $html -replace '(?m)^const DATA = .+;$', "const DATA = $json;"

# Write back
Set-Content -Path $indexFile -Value $html -Encoding UTF8 -NoNewline

# Commit and push
Set-Location $repoDir
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
git add index.html
git commit -m "Job search update $timestamp"
git push origin main

Write-Host "App updated and pushed to GitHub Pages."
