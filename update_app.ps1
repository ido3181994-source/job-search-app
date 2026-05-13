# Pull fresh DATA from the cowork artifact and push to GitHub Pages
$ErrorActionPreference = 'Stop'

$artifactFile = "C:\Users\USER\Documents\Claude\Artifacts\ido-job-search\index.html"
$indexFile    = "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily\index.html"
$repoDir      = "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily"

# ── Extract DATA block from cowork artifact ──────────────────────────────────
$artifact = Get-Content $artifactFile -Raw -Encoding UTF8

$match = [regex]::Match($artifact, '(?s)const DATA = (\{.+?\n\};)')
if (-not $match.Success) {
    Write-Error "Could not find DATA block in cowork artifact. Aborting."
    exit 1
}

$jsonStr = $match.Groups[1].Value.TrimEnd(';').Trim()

# Parse and re-serialise as a single compressed line
$obj        = $jsonStr | ConvertFrom-Json
$singleLine = $obj | ConvertTo-Json -Depth 10 -Compress

# ── Embed into index.html ────────────────────────────────────────────────────
$html = Get-Content $indexFile -Raw -Encoding UTF8
$html = $html -replace '(?m)^const DATA = .+;$', "const DATA = $singleLine;"
Set-Content -Path $indexFile -Value $html -Encoding UTF8 -NoNewline

# ── Commit and push ──────────────────────────────────────────────────────────
Set-Location $repoDir
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
git add index.html
git commit -m "Job search update $timestamp"
git push origin main

Write-Host "Done. GitHub Pages will update in ~1 minute."
