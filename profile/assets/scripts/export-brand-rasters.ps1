Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
$BrandRoot = Join-Path $RepoRoot 'profile/assets/brand'
$FtnSiteRoot = Join-Path (Split-Path $RepoRoot -Parent) 'ftn-site'

function Export-RasterSet {
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath,
        [Parameter(Mandatory)]
        [string]$DestDir,
        [string]$BaseName = 'foodtrucknerdz'
    )

    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

    $png500 = Join-Path $DestDir "$BaseName.png"
    $png256 = Join-Path $DestDir "$BaseName-256.png"
    $ico = Join-Path $DestDir "$BaseName.ico"

    if ($SourcePath.EndsWith('.svg', [StringComparison]::OrdinalIgnoreCase)) {
        magick -background none -density 300 $SourcePath -resize 500x500 $png500
        magick -background none -density 300 $SourcePath -resize 256x256 $png256
    }
    else {
        magick $SourcePath -resize 500x500 $png500
        magick $SourcePath -resize 256x256 $png256
    }

    magick $png256 -define icon:auto-resize=256,128,64,48,32,16 $ico

    Write-Host "  -> $DestDir ($BaseName.{png,png-256,ico})"
}

function Sync-RevisionToSite {
    param(
        [Parameter(Mandatory)]
        [string]$RevisionDir,
        [Parameter(Mandatory)]
        [string]$SiteImagesDir
    )

    New-Item -ItemType Directory -Force -Path $SiteImagesDir | Out-Null
    foreach ($ext in @('svg', 'png', 'ico')) {
        $name = if ($ext -eq 'png') { 'foodtrucknerdz.png', 'foodtrucknerdz-256.png' } else { "foodtrucknerdz.$ext" }
        foreach ($file in @($name)) {
            $src = Join-Path $RevisionDir $file
            if (Test-Path $src) {
                Copy-Item -Force $src (Join-Path $SiteImagesDir $file)
            }
        }
    }
    Write-Host "Synced $(Split-Path $RevisionDir -Leaf) -> $SiteImagesDir"
}

function Sync-FaviconToNextApp {
    param(
        [Parameter(Mandatory)]
        [string]$RevisionDir,
        [Parameter(Mandatory)]
        [string]$SourceSvg
    )

    $appDir = Join-Path $FtnSiteRoot 'site-nextjs/app'
    $publicRoot = Join-Path $FtnSiteRoot 'site-nextjs/public'
    $ico = Join-Path $RevisionDir 'foodtrucknerdz.ico'

    Copy-Item -Force $ico (Join-Path $appDir 'favicon.ico')
    Copy-Item -Force $ico (Join-Path $publicRoot 'favicon.ico')
    magick -background none -density 300 $SourceSvg -resize 32x32 (Join-Path $appDir 'icon.png')
    magick -background none -density 300 $SourceSvg -resize 180x180 (Join-Path $appDir 'apple-icon.png')
    Write-Host 'Synced favicon -> site-nextjs/app/ (+ public/favicon.ico)'
}

Write-Host "Brand asset root: $BrandRoot"

$revisions = @(
    @{
        Id = 'shaded-production'
        SourceSvg = Join-Path $FtnSiteRoot 'site-nextjs/public/images/foodtrucknerdz.svg'
        Note = 'Canonical production badge (gradients + soft shadow). Used by site-nextjs.'
    },
    @{
        Id = 'flat-illustrator'
        SourceSvg = Join-Path $FtnSiteRoot 'site-solidstart/public/images/foodtrucknerdz.svg'
        Note = 'Flat Illustrator export (.st0/.st1). Used by retired site-solidstart archive.'
    },
    @{
        Id = 'shaded-docs'
        SourceSvg = Join-Path $FtnSiteRoot 'docs/modules/nextjs/images/foodtrucknerdz.svg'
        Note = 'Docs copy; minor diff from shaded-production (no feDropShadow filter block).'
    }
)

foreach ($rev in $revisions) {
    $dest = Join-Path $BrandRoot $rev.Id
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -Force $rev.SourceSvg (Join-Path $dest 'foodtrucknerdz.svg')
    Write-Host "Exporting $($rev.Id)..."
    Export-RasterSet -SourcePath $rev.SourceSvg -DestDir $dest
    Set-Content -Path (Join-Path $dest 'SOURCE.txt') -Value @(
        "revision: $($rev.Id)"
        "note: $($rev.Note)"
        "source_svg: $($rev.SourceSvg)"
        "exported: $(Get-Date -Format o)"
    )
}

# Gemini profile PNG (profile hero + revision archive)
$geminiSrc = Join-Path $RepoRoot 'profile/assets/food-truck-nerdz-gemini-logo.png'
$geminiDest = Join-Path $BrandRoot 'gemini-profile'
if (Test-Path $geminiSrc) {
    New-Item -ItemType Directory -Force -Path $geminiDest | Out-Null
    Copy-Item -Force $geminiSrc (Join-Path $geminiDest 'food-truck-nerdz-gemini-logo.png')
    Write-Host 'Exporting gemini-profile...'
    Export-RasterSet -SourcePath $geminiSrc -DestDir $geminiDest -BaseName 'food-truck-nerdz-gemini-logo'
    Set-Content -Path (Join-Path $geminiDest 'SOURCE.txt') -Value @(
        'revision: gemini-profile'
        'note: Org GitHub profile hero image (Gemini-generated raster).'
        "source_png: $geminiSrc"
        "exported: $(Get-Date -Format o)"
    )
}

# Push rasters (+ SVG) into site public folders
$nextImages = Join-Path $FtnSiteRoot 'site-nextjs/public/images'
$solidImages = Join-Path $FtnSiteRoot 'site-solidstart/public/images'

Write-Host 'Syncing to site packages...'
$productionDir = Join-Path $BrandRoot 'shaded-production'
Sync-RevisionToSite -RevisionDir $productionDir -SiteImagesDir $nextImages
Sync-RevisionToSite -RevisionDir (Join-Path $BrandRoot 'flat-illustrator') -SiteImagesDir $solidImages
Sync-FaviconToNextApp -RevisionDir $productionDir -SourceSvg (Join-Path $FtnSiteRoot 'site-nextjs/public/images/foodtrucknerdz.svg')

Write-Host 'Done.'
