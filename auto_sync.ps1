# Auto-sync: push to GitHub Pages whenever the cowork artifact has newer data
$artifactFile = "C:\Users\USER\Documents\Claude\Artifacts\ido-job-search\index.html"
$indexFile    = "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily\index.html"
$updateScript = "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily\update_app.ps1"

# Extract last_run from each file
function Get-LastRun($path) {
    $content = Get-Content $path -Raw -Encoding UTF8
    $m = [regex]::Match($content, '"last_run"\s*:\s*"([^"]+)"')
    if ($m.Success) { return $m.Groups[1].Value } else { return "" }
}

$artifactRun = Get-LastRun $artifactFile
$appRun      = Get-LastRun $indexFile

if ($artifactRun -and ($artifactRun -ne $appRun)) {
    Write-Host "$(Get-Date -Format 'HH:mm') New data detected: $artifactRun (app has: $appRun). Syncing..."
    & powershell -ExecutionPolicy Bypass -File $updateScript
} else {
    Write-Host "$(Get-Date -Format 'HH:mm') Up to date ($appRun). No sync needed."
}
